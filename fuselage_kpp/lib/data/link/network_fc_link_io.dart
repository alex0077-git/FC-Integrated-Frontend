import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fuselage_kpp/data/link/fc_link.dart';

/// MAVLink over UDP — typical telemetry-radio / WiFi bridge path for airborne GCS.
///
/// - If [remoteHost] is empty: listen on [localPort] and reply to the last peer
///   (QGroundControl-style GCS bind on 14550).
/// - If [remoteHost] is set: also send to that host:[remotePort] immediately.
class UdpFcLink implements FcLink {
  UdpFcLink({
    required this.localPort,
    this.remoteHost,
    this.remotePort = 14550,
  });

  final int localPort;
  final String? remoteHost;
  final int remotePort;

  RawDatagramSocket? _socket;
  InternetAddress? _peerAddress;
  int? _peerPort;
  StreamSubscription<RawSocketEvent>? _subscription;
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
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, localPort);
      socket.broadcastEnabled = true;
      _socket = socket;
      final host = remoteHost?.trim();
      if (host != null && host.isNotEmpty) {
        _peerAddress = InternetAddress(host);
        _peerPort = remotePort;
      }
      _subscription = socket.listen(_onEvent, onError: _onError, onDone: close);
    } on SocketException catch (error) {
      throw FcLinkException(
        'Could not open UDP :$localPort — ${error.message}. '
        'Another GCS may already be listening on this port.',
      );
    }
  }

  @override
  void write(Uint8List bytes) {
    final socket = _socket;
    final peer = _peerAddress;
    final port = _peerPort;
    if (socket == null) {
      throw const FcLinkException('UDP link is not open.');
    }
    if (peer == null || port == null) {
      // No peer yet — drop outbound until the radio sends the first packet.
      return;
    }
    socket.send(bytes, peer, port);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    _socket?.close();
    _socket = null;
    _peerAddress = null;
    _peerPort = null;
    if (!_incoming.isClosed) {
      await _incoming.close();
    }
  }

  void _onEvent(RawSocketEvent event) {
    final socket = _socket;
    if (socket == null || event != RawSocketEvent.read) {
      return;
    }
    final datagram = socket.receive();
    if (datagram == null) {
      return;
    }
    _peerAddress = datagram.address;
    _peerPort = datagram.port;
    if (!_incoming.isClosed) {
      _incoming.add(Uint8List.fromList(datagram.data));
    }
  }

  void _onError(Object error) {
    if (!_incoming.isClosed) {
      _incoming.addError(FcLinkException('UDP read error: $error'));
    }
    unawaited(close());
  }
}

/// MAVLink over TCP client — WiFi modules / serial-to-TCP bridges / SITL.
class TcpFcLink implements FcLink {
  TcpFcLink({required this.host, required this.port});

  final String host;
  final int port;

  Socket? _socket;
  StreamSubscription<List<int>>? _subscription;
  final StreamController<Uint8List> _incoming = StreamController.broadcast();

  @override
  String get label => 'TCP $host:$port';

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  @override
  Future<void> open() async {
    try {
      final socket = await Socket.connect(host.trim(), port, timeout: const Duration(seconds: 5));
      _socket = socket;
      _subscription = socket.listen(
        (data) {
          if (!_incoming.isClosed) {
            _incoming.add(Uint8List.fromList(data));
          }
        },
        onError: (Object error) {
          if (!_incoming.isClosed) {
            _incoming.addError(FcLinkException('TCP read error: $error'));
          }
          unawaited(close());
        },
        onDone: () => unawaited(close()),
        cancelOnError: true,
      );
    } on SocketException catch (error) {
      throw FcLinkException(
        'Could not connect TCP $host:$port — ${error.message}. '
        'Check the WiFi/telemetry bridge IP and that MAVLink TCP is enabled.',
      );
    } on TimeoutException {
      throw FcLinkException(
        'Timed out connecting TCP $host:$port. Check the wireless bridge is powered and reachable.',
      );
    }
  }

  @override
  void write(Uint8List bytes) {
    final socket = _socket;
    if (socket == null) {
      throw const FcLinkException('TCP link is not open.');
    }
    socket.add(bytes);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    final socket = _socket;
    _socket = null;
    if (socket != null) {
      try {
        await socket.close();
      } catch (_) {}
    }
    if (!_incoming.isClosed) {
      await _incoming.close();
    }
  }
}
