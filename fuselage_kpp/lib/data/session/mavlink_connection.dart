import 'dart:async';
import 'dart:typed_data';

import 'package:fuselage_kpp/data/link/fc_link.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_codec.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';

/// Sends and receives K++ serial frames over an [FcLink] and keeps the
/// ground-station heartbeat running.
class MavlinkConnection {
  MavlinkConnection({required this.link})
    : _encoder = MavFrameEncoder(systemId: _gcsSystemId, componentId: _gcsComponentId);

  static const int _gcsSystemId = 255;
  static const int _gcsComponentId = 190;
  static const Duration _heartbeatInterval = Duration(seconds: 1);

  final FcLink link;
  final MavFrameEncoder _encoder;
  final MavFrameParser _parser = MavFrameParser();
  final StreamController<MavPacket> _packets = StreamController.broadcast();
  StreamSubscription<Uint8List>? _linkSubscription;
  Timer? _heartbeatTimer;

  int _bytesReceived = 0;
  int _targetSystem = 1;
  int _targetComponent = 1;
  DateTime? _lastPacketAt;

  Stream<MavPacket> get packets => _packets.stream;

  Stream<MavMessage> get messages => _packets.stream.map((p) => p.message);

  /// Only the messages of type [T], e.g. `messagesOf<ParamValue>()`.
  Stream<T> messagesOf<T extends MavMessage>() => _packets.stream.map((p) => p.message).where((m) => m is T).cast<T>();

  int get targetSystem => _targetSystem;
  int get targetComponent => _targetComponent;
  int get bytesReceived => _bytesReceived;
  int get rejectedFrames => _parser.rejectedFrames;
  DateTime? get lastPacketAt => _lastPacketAt;

  Future<void> start() async {
    await link.open();
    _linkSubscription = link.incoming.listen(_onBytes, onError: _packets.addError);
    _sendHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) => _sendHeartbeat());
  }

  void send(MavMessage message) => link.write(_encoder.encode(message));

  Future<void> close() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    final sub = _linkSubscription;
    _linkSubscription = null;
    // Link close cancels simulator/serial poll timers synchronously.
    await link.close();
    unawaited(sub?.cancel());
    if (!_packets.isClosed) {
      unawaited(_packets.close());
    }
  }

  void _onBytes(Uint8List bytes) {
    _bytesReceived += bytes.length;
    for (final packet in _parser.addBytes(bytes)) {
      _lastPacketAt = DateTime.now();
      if (packet.message is Heartbeat && packet.systemId != _gcsSystemId) {
        _targetSystem = packet.systemId;
        _targetComponent = packet.componentId;
      }
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
