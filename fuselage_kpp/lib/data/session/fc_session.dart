import 'dart:async';

import 'package:fuselage_kpp/data/link/fc_link.dart';
import 'package:fuselage_kpp/data/link/network_fc_link.dart';
import 'package:fuselage_kpp/data/link/serial_fc_link.dart';
import 'package:fuselage_kpp/data/link/simulated_fc_link.dart';
import 'package:fuselage_kpp/data/link/transmitter_devices.dart';
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

  /// Port dropdown: Bluetooth SPP COMs use the resilient TX path (not USB).
  ///
  /// When several BT COMs exist, prefers the higher COM (usually Outgoing) so
  /// Connect does not hang on Incoming with "semaphore timeout".
  factory ConnectionSettings.forAvailablePort(
    SerialPortInfo port, {
    int baudRate = defaultBaudRate,
    List<SerialPortInfo> allPorts = const [],
  }) {
    if (isBluetoothSerialPort(port)) {
      final preferred = allPorts.isEmpty
          ? port
          : preferredBluetoothSerialPort(port, allPorts);
      return ConnectionSettings.bluetooth(
        portName: preferred.name,
        baudRate: baudRate,
      );
    }
    return ConnectionSettings(
      useSimulator: false,
      portName: port.name,
      baudRate: baudRate,
    );
  }

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

  /// Other Windows SPP COM for the same paired TX (Incoming ↔ Outgoing).
  ConnectionSettings? alternateBluetoothPort([
    List<SerialPortInfo> Function()? portLister,
  ]) {
    if (resolvedKind != FcLinkKind.bluetooth) {
      return null;
    }
    final failed = portName;
    if (failed == null) {
      return null;
    }
    final other = alternateBluetoothComName(failed, portLister);
    if (other == null) {
      return null;
    }
    return ConnectionSettings.bluetooth(portName: other, baudRate: baudRate);
  }

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
          SerialFcLink(portName: port, baudRate: baudRate, resilient: true),
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

  /// Exact stream table captured from JIYI K++ assistant APP→FC traffic,
  /// plus EXTRA1–3 so GPS_RAW_INT / GPS2_RAW keep flowing on K++ builds that
  /// park sat counts on those streams instead of RAW_SENSORS alone.
  static const List<(int rateHz, int streamId)> _jiyiStreams = [
    (5, RequestDataStream.rawSensors),
    (2, RequestDataStream.extendedStatus),
    (2, RequestDataStream.rcChannels),
    (2, RequestDataStream.extra1),
    (2, RequestDataStream.extra2),
    (2, RequestDataStream.extra3),
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

  /// Open USB/BT serial port name, if this session is a [SerialFcLink].
  String? get openSerialPortName {
    final link = _rawLink;
    return link is SerialFcLink ? link.portName : null;
  }

  /// Baud rate of the open serial link, if any.
  int? get openSerialBaudRate {
    final link = _rawLink;
    return link is SerialFcLink ? link.baudRate : null;
  }

  FcLink get _rawLink {
    final link = connection.link;
    return link is LabeledFcLink ? link.inner : link;
  }

  bool get isNetworkLink => _rawLink is UdpFcLink || _rawLink is TcpFcLink;

  bool get isTransmitterLink {
    final label = connection.link.label;
    return isNetworkLink || label.startsWith('BT ') || label.startsWith('TX WiFi');
  }

  /// Opens the link and waits for the first valid K++ serial frame.
  ///
  /// Subscribe to [packets] *before* [MavlinkConnection.start] — the packet
  /// stream is broadcast, and the TX often replies within milliseconds.
  ///
  /// Same sequence as the working Oct-12 setup / commit 4e565e6: open → first
  /// A1 frame → JIYI stream handshake → caller downloads parameters.
  static Future<FcSession> open(ConnectionSettings settings) async {
    final connection = MavlinkConnection(link: settings.createLink());
    final session = FcSession._(connection);
    final firstPacketTimeout = settings.isTransmitter
        ? const Duration(seconds: 12)
        : _firstPacketTimeout;
    try {
      // Listen before start so the first reply is not lost on a broadcast stream.
      final ready = connection.packets.first.timeout(firstPacketTimeout);
      await connection.start();
      await ready;
      session.requestTelemetryStreams();
      return session;
    } on TimeoutException {
      final diagnosis = session._noReplyDiagnosis(settings);
      await session.close();
      throw FcConnectException(diagnosis);
    } catch (error) {
      if (error is StateError && error.message.contains('No element')) {
        final diagnosis = session._noReplyDiagnosis(settings);
        await session.close();
        throw FcConnectException(diagnosis);
      }
      await session.close();
      rethrow;
    }
  }

  /// Replays the JIYI assistant telemetry handshake (msgs 211 → streams → 220).
  void requestTelemetryStreams({bool broadcast = false}) {
    final system = broadcast ? 0 : connection.targetSystem;
    connection.send(const KppLinkSetup());
    // JIYI targets component 0 (broadcast) on REQUEST_DATA_STREAM.
    for (final (rateHz, streamId) in _jiyiStreams) {
      connection.send(
        RequestDataStream(
          targetSystem: system,
          targetComponent: 0,
          rateHz: rateHz,
          streamId: streamId,
        ),
      );
    }
    // Also ask for fused position — useful for the map when agri GPS locks.
    connection.send(
      RequestDataStream(
        targetSystem: system,
        targetComponent: 0,
        rateHz: 2,
        streamId: RequestDataStream.position,
      ),
    );
    // Broad request so GPS_STATUS / RAW variants the assistant uses still flow.
    connection.send(
      RequestDataStream(
        targetSystem: system,
        targetComponent: 0,
        rateHz: 2,
        streamId: RequestDataStream.allStreams,
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
    final radioOnly = connection.radioStatusFrames > 0 &&
        connection.radioStatusFrames * 20 >= bytes; // mostly msgid-109 sized traffic
    if (bytes == 0) {
      if (settings.isNetwork) {
        return 'No data at all from $where. Power the aircraft and telemetry/WiFi bridge, '
            'confirm the host/port, and that no other GCS is using the same link.';
      }
      if (settings.resolvedKind == FcLinkKind.bluetooth || settings.isTransmitter) {
        return 'No data at all from $where (Bluetooth). Keep Windows → TX Connected, '
            'power the aircraft and radio link, baud 57600.';
      }
      return 'No data at all from $where. Check the flight battery is connected and the cable is in the FC data port.';
    }
    if (settings.resolvedKind == FcLinkKind.bluetooth || settings.isTransmitter) {
      if (radioOnly || connection.radioStatusFrames > 0) {
        final rem = connection.lastRemRssi;
        if (rem != null && rem > 0) {
          return 'TX↔aircraft radio is up (remote RSSI=$rem on $where) but no K++ FC '
              'frames on this COM (${connection.radioStatusFrames} radio-status, '
              '$bytes bytes). The working Oct-12 setup used Bluetooth COM5 @ 57600 '
              'with aircraft battery on. In Windows Bluetooth, remove T12_055 and pair '
              'again so both Incoming + Outgoing COMs appear, pick the Outgoing '
              '(often the higher COM), aircraft powered, baud 57600, then Connect.';
        }
        return 'Bluetooth reached the transmitter ($where) but no K++ FC frames '
            '(${connection.radioStatusFrames} radio-status, $bytes bytes'
            '${rem == null ? '' : ', remote RSSI=$rem'}). '
            'Power the aircraft, confirm T12↔aircraft RF, try the other BT COM, baud 57600.';
      }
      return 'Received $bytes bytes from $where but no valid K++ serial frames '
          '(${connection.rejectedFrames} rejected). '
          'Power the aircraft and confirm baud 57600. For Bluetooth try the sibling COM.';
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
