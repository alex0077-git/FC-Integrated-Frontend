import 'dart:async';
import 'dart:typed_data';

import 'package:fuselage_kpp/data/link/fc_link.dart';
import 'package:fuselage_kpp/data/link/network_fc_link.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_codec.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/session/gps_capture_log.dart';

/// Sends and receives K++ / MAVLink frames over an [FcLink] and keeps the
/// ground-station heartbeat running.
///
/// Bluetooth matches the working Oct-12 / commit 4e565e6 path: same K++
/// obfuscated wire as USB. Clear FE on BT is radio-status only (side-counted).
class MavlinkConnection {
  MavlinkConnection({required this.link, MavWireMode? wireMode})
    : wireMode = wireMode ?? wireModeForLink(link),
      _encoder = MavFrameEncoder(
        systemId: _gcsSystemId,
        componentId: _gcsComponentId,
        wireMode: wireMode ?? wireModeForLink(link),
      ),
      _parser = MavFrameParser(wireMode: wireMode ?? wireModeForLink(link)),
      _radioParser = _isBluetoothLabel(link)
          ? MavFrameParser(wireMode: MavWireMode.clearMavlink1)
          : null;

  /// USB + Bluetooth → K++ obfuscated. WiFi TCP/UDP → clear MAVLink-1.
  static MavWireMode wireModeForLink(FcLink link) {
    if (link is UdpFcLink || link is TcpFcLink) {
      return MavWireMode.clearMavlink1;
    }
    final raw = link is LabeledFcLink ? link.inner : link;
    if (raw is UdpFcLink || raw is TcpFcLink) {
      return MavWireMode.clearMavlink1;
    }
    if (link.label.startsWith('TX WiFi')) {
      return MavWireMode.clearMavlink1;
    }
    return MavWireMode.kppObfuscated;
  }

  static bool _isBluetoothLabel(FcLink link) => link.label.startsWith('BT ');

  static const int radioStatusMsgid = 109;
  static const int _gcsSystemId = 255;
  static const int _gcsComponentId = 190;
  static const Duration _heartbeatInterval = Duration(seconds: 1);
  static const int _baseModeArmed = 128;

  final FcLink link;
  final MavWireMode wireMode;
  final MavFrameEncoder _encoder;
  final MavFrameParser _parser;
  final MavFrameParser? _radioParser;
  final StreamController<MavPacket> _packets = StreamController.broadcast();
  StreamSubscription<Uint8List>? _linkSubscription;
  Timer? _heartbeatTimer;

  int _bytesReceived = 0;
  int _targetSystem = 1;
  int _targetComponent = 1;
  int _lastBaseMode = 0;
  int _lastCustomMode = 0;
  DateTime? _lastPacketAt;
  int _radioStatusFrames = 0;
  int? _lastRemRssi;
  int? _lastLocalRssi;

  Stream<MavPacket> get packets => _packets.stream;

  Stream<MavMessage> get messages => _packets.stream.map((p) => p.message);

  Stream<T> messagesOf<T extends MavMessage>() =>
      _packets.stream.map((p) => p.message).where((m) => m is T).cast<T>();

  int get targetSystem => _targetSystem;
  int get targetComponent => _targetComponent;
  int get lastBaseMode => _lastBaseMode;
  int get lastCustomMode => _lastCustomMode;
  bool get heartbeatArmed => (_lastBaseMode & _baseModeArmed) != 0;
  int get bytesReceived => _bytesReceived;
  int get rejectedFrames => _parser.rejectedFrames;
  int get radioStatusFrames => _radioStatusFrames;
  int? get lastRemRssi => _lastRemRssi;
  int? get lastLocalRssi => _lastLocalRssi;
  DateTime? get lastPacketAt => _lastPacketAt;

  Future<void> start() async {
    GpsCaptureLog.ensureStarted();
    await link.open();
    _linkSubscription = link.incoming.listen(_onBytes, onError: _packets.addError);
    _sendHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) => _sendHeartbeat());
  }

  void send(MavMessage message) {
    link.write(_encoder.encode(message));
  }

  Future<void> close() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    final sub = _linkSubscription;
    _linkSubscription = null;
    await link.close();
    unawaited(sub?.cancel());
    await GpsCaptureLog.close();
    if (!_packets.isClosed) {
      unawaited(_packets.close());
    }
  }

  void _onBytes(Uint8List bytes) {
    _bytesReceived += bytes.length;
    // Side-channel only: clear FE RADIO_STATUS for diagnosis (never drives open).
    final radio = _radioParser;
    if (radio != null) {
      for (final packet in radio.addBytes(bytes)) {
        final msg = packet.message;
        if (msg is RadioStatus) {
          _radioStatusFrames++;
          _lastRemRssi = msg.remrssi;
          _lastLocalRssi = msg.rssi;
        } else if (msg is UnknownMavMessage && msg.messageId == radioStatusMsgid) {
          _radioStatusFrames++;
          if (msg.payload.length >= 6) {
            _lastLocalRssi = msg.payload[4];
            _lastRemRssi = msg.payload[5];
          }
        }
      }
    }
    for (final packet in _parser.addBytes(bytes)) {
      _lastPacketAt = DateTime.now();
      if (packet.message is Heartbeat && packet.systemId != _gcsSystemId) {
        final hb = packet.message as Heartbeat;
        _targetSystem = packet.systemId;
        _targetComponent = packet.componentId;
        _lastBaseMode = hb.baseMode;
        _lastCustomMode = hb.customMode;
      }
      GpsCaptureLog.logPacket('fc', packet);
      _packets.add(packet);
    }
  }

  void _sendHeartbeat() {
    try {
      send(const Heartbeat(type: Heartbeat.typeGcs, autopilot: Heartbeat.autopilotInvalid));
    } on FcLinkException {
      // Bluetooth/WiFi can stall a write; keep the session and retry next tick.
    }
  }
}
