import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:fuselage_kpp/data/link/fc_link.dart';

/// A COM port the user can pick, e.g. "COM3 — USB-SERIAL CH340".
class SerialPortInfo {
  const SerialPortInfo({required this.name, required this.description});

  final String name;
  final String description;

  static List<SerialPortInfo> available() {
    return [for (final name in SerialPort.availablePorts) _describe(name)];
  }

  static SerialPortInfo _describe(String name) {
    final port = SerialPort(name);
    try {
      return SerialPortInfo(name: name, description: port.description ?? '');
    } finally {
      port.dispose();
    }
  }
}

/// Real flight-controller link over a serial port, 8 data bits, no parity,
/// one stop bit, no flow control.
///
/// Reads by polling with non-blocking reads on the calling isolate instead
/// of using `SerialPortReader`: that reader keeps the native port pointer in
/// a background isolate which can outlive `close()`, so freeing the port
/// afterwards is a use-after-free.
class SerialFcLink implements FcLink {
  SerialFcLink({required this.portName, required this.baudRate});

  static const Duration _pollInterval = Duration(milliseconds: 10);
  static const int _writeTimeoutMs = 200;

  final String portName;
  final int baudRate;

  SerialPort? _port;
  Timer? _pollTimer;
  final StreamController<Uint8List> _incoming = StreamController.broadcast();

  @override
  String get label => '$portName @ $baudRate';

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  @override
  Future<void> open() async {
    final port = SerialPort(portName);
    if (!port.openReadWrite()) {
      final error = SerialPort.lastError;
      port.dispose();
      throw FcLinkException(
        'Could not open $portName: ${error?.message ?? 'unknown error'}. '
        'Close any other app using this port (e.g. the original K++ assistant).',
      );
    }
    // The port takes ownership of the config and frees it in dispose().
    port.config = SerialPortConfig()
      ..baudRate = baudRate
      ..bits = 8
      ..parity = SerialPortParity.none
      ..stopBits = 1
      ..setFlowControl(SerialPortFlowControl.none);

    _port = port;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  @override
  void write(Uint8List bytes) {
    final port = _port;
    if (port == null) {
      throw const FcLinkException('Serial link is not open.');
    }
    final written = port.write(bytes, timeout: _writeTimeoutMs);
    if (written != bytes.length) {
      throw FcLinkException('Only $written of ${bytes.length} bytes were sent on $portName.');
    }
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    final port = _port;
    _port = null;
    if (port != null) {
      try {
        port.close();
      } catch (_) {}
      try {
        port.dispose();
      } catch (_) {}
    }
    if (!_incoming.isClosed) {
      unawaited(_incoming.close());
    }
    // Windows CH340 needs a beat before the next openReadWrite succeeds.
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  void _poll() {
    final port = _port;
    if (port == null) {
      return;
    }
    try {
      final available = port.bytesAvailable;
      if (available > 0) {
        _incoming.add(port.read(available));
      }
    } on SerialPortError catch (error) {
      _incoming.addError(FcLinkException('$portName read error: ${error.message}'));
      close();
    }
  }
}
