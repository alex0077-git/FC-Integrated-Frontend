import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:fuselage_kpp/data/link/fc_link.dart';
import 'package:fuselage_kpp/data/link/transmitter_devices.dart';

/// Android stand-in for a Windows Bluetooth COM port.
///
/// The phone has no COM4/COM5. After the transmitter is paired in Android
/// Bluetooth settings, this opens the standard SPP serial channel. The host
/// app's Android code serves the [channel] methods.
class AndroidBluetoothFcLink implements FcLink {
  AndroidBluetoothFcLink({required this.address});

  static const MethodChannel channel = MethodChannel('fuselage_kpp/bluetooth');
  static const EventChannel bytes = EventChannel('fuselage_kpp/bluetooth_bytes');

  final String address;

  late final StreamController<Uint8List> _incoming =
      StreamController<Uint8List>.broadcast(onListen: _flushEarly);
  StreamSubscription<dynamic>? _events;
  Timer? _pullTimer;
  final List<Uint8List> _early = <Uint8List>[];
  static const int _maxEarlyBytes = 256 * 1024;
  int _earlyBytes = 0;
  Map<String, Object?> _lastStats = const {};

  /// Same style as Windows `COMx @ 57600` (SPP has no real baud; T12 telem is 57600).
  @override
  String get label => 'BT $address @ 57600';

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  /// Last native SPP counters (read/write). Useful in connect-error text.
  Map<String, Object?> get lastStats => Map<String, Object?>.unmodifiable(_lastStats);

  Future<void> refreshStats() async {
    _lastStats = await nativeStats();
  }

  String statsSummary() {
    if (_lastStats.isEmpty) {
      return '';
    }
    final read = _lastStats['bytesRead'] ?? 0;
    final written = _lastStats['bytesWritten'] ?? 0;
    final errors = _lastStats['writeErrors'] ?? 0;
    final path = _lastStats['socketPath'];
    final err = _lastStats['lastWriteError'];
    return ' Native SPP read=$read write=$written writeErrors=$errors'
        '${path == null ? '' : ' path=$path'}'
        '${err == null || '$err'.isEmpty ? '' : ' lastWriteError=$err'}.';
  }

  /// Paired Bluetooth devices. [id] is the MAC address used as the port name.
  static Future<List<TransmitterBluetoothDevice>> pairedDevices() async {
    final raw = await channel.invokeMethod<List<dynamic>>('list');
    if (raw == null) {
      return const [];
    }
    return [
      for (final item in raw)
        if (item is Map)
          TransmitterBluetoothDevice(
            id: '${item['id']}',
            name: '${item['name']}',
            detail: '${item['detail'] ?? item['id']}',
            outgoing: true,
          ),
    ];
  }

  static Future<Map<String, Object?>> nativeStats() async {
    try {
      final raw = await channel.invokeMethod<dynamic>('stats');
      return _asStringKeyMap(raw);
    } on PlatformException {
      return const {};
    }
  }

  /// Re-send CoolFly UART pass-through (needed again before param download).
  static Future<void> enableUartPassThrough() async {
    try {
      await channel.invokeMethod<dynamic>('enablePassThrough');
    } on PlatformException catch (error) {
      throw FcLinkException(error.message ?? 'UART pass-through failed.');
    }
  }

  void _flushEarly() {
    if (_incoming.isClosed || _early.isEmpty) {
      return;
    }
    for (final buffered in _early) {
      _incoming.add(buffered);
    }
    _early.clear();
    _earlyBytes = 0;
  }

  void _emit(Uint8List chunk) {
    if (_incoming.isClosed || chunk.isEmpty) {
      return;
    }
    if (_incoming.hasListener) {
      _flushEarly();
      _incoming.add(chunk);
      return;
    }
    if (_earlyBytes + chunk.length > _maxEarlyBytes) {
      return;
    }
    _early.add(chunk);
    _earlyBytes += chunk.length;
  }

  void _onPlatformEvent(dynamic event) {
    final chunk = _asBytes(event);
    if (chunk != null) {
      _emit(chunk);
    }
  }

  Future<void> _pullOnce() async {
    try {
      final raw = await channel.invokeMethod<dynamic>('pull');
      final chunk = _asBytes(raw);
      if (chunk != null) {
        _emit(chunk);
      }
    } on PlatformException {
      // Link may be closing.
    }
  }

  @override
  Future<void> open() async {
    // EventChannel + pull: some Android builds deliver SPP bytes on only one path.
    _events = bytes.receiveBroadcastStream().listen(_onPlatformEvent, onError: _incoming.addError);
    try {
      final connected = await channel.invokeMethod<dynamic>('connect', {'address': address});
      _lastStats = _asStringKeyMap(connected);
    } on PlatformException catch (error) {
      await _events?.cancel();
      _events = null;
      final detail = (error.message ?? error.code).trim();
      throw FcLinkException(
        detail.isEmpty
            ? 'Bluetooth connect failed.'
            : detail,
      );
    }
    _pullTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      unawaited(_pullOnce());
    });
    await _pullOnce();
  }

  @override
  void write(Uint8List data) {
    unawaited(
      channel.invokeMethod<void>('write', {'data': data}).then((_) {
        // Keep write counter fresh for diagnosis without an extra round-trip each beat.
      }).catchError((Object error) {
        if (!_incoming.isClosed) {
          _incoming.addError(error);
        }
      }),
    );
  }

  @override
  Future<void> close() async {
    _pullTimer?.cancel();
    _pullTimer = null;
    await _events?.cancel();
    _events = null;
    _early.clear();
    _earlyBytes = 0;
    try {
      _lastStats = await nativeStats();
    } catch (_) {}
    try {
      await channel.invokeMethod<void>('close');
    } on PlatformException {
      // Already closed.
    }
    if (!_incoming.isClosed) {
      await _incoming.close();
    }
  }

  static Uint8List? _asBytes(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is Uint8List) {
      return raw.isEmpty ? null : raw;
    }
    if (raw is ByteBuffer) {
      final view = raw.asUint8List();
      return view.isEmpty ? null : view;
    }
    if (raw is List) {
      if (raw.isEmpty) {
        return null;
      }
      return Uint8List.fromList(raw.cast<int>());
    }
    return null;
  }

  static Map<String, Object?> _asStringKeyMap(dynamic raw) {
    if (raw is Map) {
      return {
        for (final entry in raw.entries) '${entry.key}': entry.value,
      };
    }
    return const {};
  }
}
