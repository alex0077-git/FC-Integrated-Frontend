import 'dart:async';

import 'package:fuselage_kpp/data/link/fc_link.dart';
import 'package:fuselage_kpp/data/link/network_fc_link.dart';
import 'package:fuselage_kpp/data/link/serial_fc_link.dart';
import 'package:fuselage_kpp/data/link/simulated_fc_link.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/session/command_service.dart';
import 'package:fuselage_kpp/data/session/log_service.dart';
import 'package:fuselage_kpp/data/session/mavlink_connection.dart';
import 'package:fuselage_kpp/data/session/mission_service.dart';
import 'package:fuselage_kpp/data/session/parameter_service.dart';
import 'package:fuselage_kpp/data/session/telemetry_service.dart';

/// How bytes reach the flight controller. USB serial stays the default path.
enum FcLinkKind { serial, simulator, udp, tcp, bluetooth }

/// What the user picked on the connect panel.
class ConnectionSettings {
  const ConnectionSettings({
    required this.useSimulator,
    this.portName,
    this.baudRate = defaultBaudRate,
    this.kind,
    this.host,
    this.remotePort,
    this.localPort = defaultUdpListenPort,
  });

  /// Wireless UDP listen (GCS binds [localPort], replies to last peer).
  const ConnectionSettings.udpListen({this.localPort = defaultUdpListenPort})
    : useSimulator = false,
      portName = null,
      baudRate = defaultBaudRate,
      kind = FcLinkKind.udp,
      host = null,
      remotePort = null;

  /// Wireless UDP to a known radio / WiFi bridge address.
  const ConnectionSettings.udpHost({
    required String host,
    int remotePort = defaultUdpListenPort,
    int localPort = 14551,
  }) : this(
         useSimulator: false,
         kind: FcLinkKind.udp,
         host: host,
         remotePort: remotePort,
         localPort: localPort,
       );

  /// Wireless TCP client to a bridge / module.
  const ConnectionSettings.tcpHost({
    required String host,
    int remotePort = defaultTcpPort,
  }) : this(
         useSimulator: false,
         kind: FcLinkKind.tcp,
         host: host,
         remotePort: remotePort,
       );

  /// Transmitter over Bluetooth serial (paired SPP / BT COM port).
  const ConnectionSettings.bluetooth({
    required String portName,
    int baudRate = defaultBaudRate,
  }) : this(
         useSimulator: false,
         kind: FcLinkKind.bluetooth,
         portName: portName,
         baudRate: baudRate,
       );

  static const int defaultBaudRate = 57600;
  static const int defaultUdpListenPort = 14550;
  static const int defaultTcpPort = 5760;
  static const List<int> baudRates = [9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600];

  final bool useSimulator;
  final String? portName;
  final int baudRate;

  /// When null, derived from [useSimulator] (keeps existing USB/simulator callers).
  final FcLinkKind? kind;
  final String? host;
  final int? remotePort;
  final int localPort;

  FcLinkKind get resolvedKind {
    if (kind != null) {
      return kind!;
    }
    return useSimulator ? FcLinkKind.simulator : FcLinkKind.serial;
  }

  bool get isNetwork => resolvedKind == FcLinkKind.udp || resolvedKind == FcLinkKind.tcp;

  /// Transmitter path (Bluetooth serial or WiFi AP) — not the USB FC cable.
  bool get isTransmitter =>
      resolvedKind == FcLinkKind.bluetooth ||
      resolvedKind == FcLinkKind.udp ||
      resolvedKind == FcLinkKind.tcp;

  FcLink createLink() {
    switch (resolvedKind) {
      case FcLinkKind.simulator:
        return SimulatedFcLink();
      case FcLinkKind.serial:
        final port = portName;
        if (port == null) {
          throw const FcLinkException('Choose a COM port first.');
        }
        return SerialFcLink(portName: port, baudRate: baudRate);
      case FcLinkKind.bluetooth:
        final port = portName;
        if (port == null) {
          throw const FcLinkException('Choose a Bluetooth transmitter port first.');
        }
        return LabeledFcLink(
          SerialFcLink(portName: port, baudRate: baudRate),
          'BT $port @ $baudRate',
        );
      case FcLinkKind.udp:
        return UdpFcLink(
          localPort: localPort,
          remoteHost: host,
          remotePort: remotePort ?? defaultUdpListenPort,
        );
      case FcLinkKind.tcp:
        final target = host?.trim();
        if (target == null || target.isEmpty) {
          throw const FcLinkException('Enter the transmitter WiFi host / IP first.');
        }
        return LabeledFcLink(
          TcpFcLink(host: target, port: remotePort ?? defaultTcpPort),
          'TX WiFi TCP $target:${remotePort ?? defaultTcpPort}',
        );
    }
  }
}

class FcConnectException implements Exception {
  const FcConnectException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One open connection to a flight controller and the services that use it.
class FcSession {
  FcSession._(this.connection)
    : parameters = ParameterService(connection),
      telemetry = TelemetryService(connection),
      logs = LogService(connection),
      commands = CommandService(connection),
      missions = MissionService(connection);

  static const Duration _firstPacketTimeout = Duration(seconds: 5);

  /// Exact stream table captured from JIYI K++ assistant APP→FC traffic.
  static const List<(int rateHz, int streamId)> _jiyiStreams = [
    (5, RequestDataStream.rawSensors),
    (2, RequestDataStream.extendedStatus),
    (2, RequestDataStream.rcChannels),
    (1, RequestDataStream.kppAgri1),
    (2, RequestDataStream.kppAgri2),
  ];

  final MavlinkConnection connection;
  final ParameterService parameters;
  final TelemetryService telemetry;
  final LogService logs;
  final CommandService commands;
  final MissionService missions;

  String get linkLabel => connection.link.label;

  bool get isSimulated => connection.link is SimulatedFcLink;

  FcLink get _rawLink {
    final link = connection.link;
    return link is LabeledFcLink ? link.inner : link;
  }

  bool get isNetworkLink => _rawLink is UdpFcLink || _rawLink is TcpFcLink;

  bool get isTransmitterLink {
    final label = connection.link.label;
    return isNetworkLink || label.startsWith('BT ') || label.startsWith('TX WiFi');
  }

  /// Opens the link and waits for the first valid MAVLink frame.
  static Future<FcSession> open(ConnectionSettings settings) async {
    final connection = MavlinkConnection(link: settings.createLink());
    final session = FcSession._(connection);
    final firstPacketTimeout =
        settings.isNetwork ? const Duration(seconds: 12) : _firstPacketTimeout;
    try {
      await connection.start();
      await connection.packets.first.timeout(firstPacketTimeout);
      session.requestTelemetryStreams();
      return session;
    } on TimeoutException {
      final diagnosis = session._noReplyDiagnosis(settings);
      await session.close();
      throw FcConnectException(diagnosis);
    } catch (_) {
      await session.close();
      rethrow;
    }
  }

  /// Replays the JIYI assistant telemetry handshake (msgs 211 → streams → 220).
  void requestTelemetryStreams() {
    connection.send(const KppLinkSetup());
    // JIYI targets component 0 (broadcast) on REQUEST_DATA_STREAM.
    for (final (rateHz, streamId) in _jiyiStreams) {
      connection.send(
        RequestDataStream(
          targetSystem: connection.targetSystem,
          targetComponent: 0,
          rateHz: rateHz,
          streamId: streamId,
        ),
      );
    }
    // Also ask for fused position — useful for the map when agri GPS locks.
    connection.send(
      RequestDataStream(
        targetSystem: connection.targetSystem,
        targetComponent: 0,
        rateHz: 2,
        streamId: RequestDataStream.position,
      ),
    );
    connection.send(const KppAppReady());
  }

  /// Ensures SR0_* rates are non-zero (K++ defaults them to 0), then re-sends
  /// the JIYI stream handshake once parameters are known.
  Future<void> ensureTelemetryRates() async {
    const rates = <String, double>{
      'SR0_POSITION': 2,
      'SR0_EXT_STAT': 2,
      'SR0_RAW_SENS': 5,
      'SR0_RC_CHAN': 2,
      'SR0_EXTRA1': 2,
      'SR0_EXTRA2': 2,
      'SR0_EXTRA3': 2,
    };
    for (final entry in rates.entries) {
      final current = parameters.values[entry.key];
      if (current == null) {
        continue;
      }
      if (current < 1) {
        try {
          await parameters.setParam(entry.key, entry.value);
        } catch (_) {
          // Non-fatal: stream request may still work on some firmwares.
        }
      }
    }
    requestTelemetryStreams();
  }

  Future<void> close() async {
    // Stop heartbeats / sim timers first so widget tests never see pending timers
    // if a later dispose await is delayed by FakeAsync.
    await connection.close();
    await parameters.dispose();
    await telemetry.dispose();
    await commands.dispose();
  }

  String _noReplyDiagnosis(ConnectionSettings settings) {
    final bytes = connection.bytesReceived;
    final where = connection.link.label;
    if (bytes == 0) {
      if (settings.isNetwork) {
        return 'No data at all from $where. Power the aircraft and telemetry/WiFi bridge, '
            'confirm the host/port, and that no other GCS is using the same link.';
      }
      return 'No data at all from $where. Check the flight battery is connected and the cable is in the FC data port.';
    }
    if (settings.isNetwork) {
      return 'Received $bytes bytes from $where but no valid MAVLink frames '
          '(${connection.rejectedFrames} rejected). '
          'Confirm the bridge is forwarding MAVLink (not a different protocol).';
    }
    return 'Received $bytes bytes from $where but no valid serial frames '
        '(${connection.rejectedFrames} rejected). '
        'The baud rate does not match this flight controller.';
  }
}
