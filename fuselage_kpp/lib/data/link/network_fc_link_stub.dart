import 'dart:async';
import 'dart:typed_data';

import 'package:fuselage_kpp/data/link/fc_link.dart';

/// Stub when `dart:io` sockets are unavailable (e.g. web).
class UdpFcLink implements FcLink {
  UdpFcLink({
    required this.localPort,
    this.remoteHost,
    this.remotePort = 14550,
  });

  final int localPort;
  final String? remoteHost;
  final int remotePort;

  final StreamController<Uint8List> _incoming = StreamController.broadcast();

  @override
  String get label {
    final host = remoteHost;
    if (host == null || host.isEmpty) {
      return 'UDP listen :$localPort';
    }
    return 'UDP $host:$remotePort (local :$localPort)';
  }

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  @override
  Future<void> open() async {
    throw const FcLinkException(
      'Wireless MAVLink needs the Windows or Android build — web cannot open UDP/TCP sockets.',
    );
  }

  @override
  void write(Uint8List bytes) {
    throw const FcLinkException('UDP link is not open.');
  }

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) {
      await _incoming.close();
    }
  }
}

/// Stub TCP link for platforms without sockets.
class TcpFcLink implements FcLink {
  TcpFcLink({required this.host, required this.port});

  final String host;
  final int port;

  final StreamController<Uint8List> _incoming = StreamController.broadcast();

  @override
  String get label => 'TCP $host:$port';

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  @override
  Future<void> open() async {
    throw const FcLinkException(
      'Wireless MAVLink needs the Windows or Android build — web cannot open UDP/TCP sockets.',
    );
  }

  @override
  void write(Uint8List bytes) {
    throw const FcLinkException('TCP link is not open.');
  }

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) {
      await _incoming.close();
    }
  }
}
