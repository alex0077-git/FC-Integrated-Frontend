import 'dart:async';
import 'dart:typed_data';

import 'package:fuselage_kpp/data/link/fc_link.dart';

/// Stub when native serial is unavailable (e.g. web).
class SerialPortInfo {
  const SerialPortInfo({required this.name, required this.description});

  final String name;
  final String description;

  static List<SerialPortInfo> available() => const [];
}

/// Stub serial link — open always fails on platforms without libserialport.
class SerialFcLink implements FcLink {
  SerialFcLink({required this.portName, required this.baudRate});

  final String portName;
  final int baudRate;

  final StreamController<Uint8List> _incoming = StreamController.broadcast();

  @override
  String get label => '$portName @ $baudRate';

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  @override
  Future<void> open() async {
    throw const FcLinkException(
      'USB serial is not available on this platform. Use the Simulator, or run on Windows/Android.',
    );
  }

  @override
  void write(Uint8List bytes) {
    throw const FcLinkException('Serial link is not open.');
  }

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) {
      await _incoming.close();
    }
  }
}
