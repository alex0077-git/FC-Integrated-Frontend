import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/link/network_fc_link.dart';
import 'package:fuselage_kpp/data/link/serial_fc_link.dart';
import 'package:fuselage_kpp/data/link/transmitter_devices.dart';
import 'package:fuselage_kpp/data/session/fc_session.dart';

void main() {
  test('USB ConnectionSettings still resolves to serial', () {
    const settings = ConnectionSettings(
      useSimulator: false,
      portName: 'COM3',
      baudRate: 115200,
    );
    expect(settings.resolvedKind, FcLinkKind.serial);
    expect(settings.isNetwork, isFalse);
    expect(settings.createLink().label, 'COM3 @ 115200');
  });

  test('udpListen / udpHost / tcpHost / bluetooth factory settings', () {
    expect(const ConnectionSettings.udpListen().resolvedKind, FcLinkKind.udp);
    expect(const ConnectionSettings.udpListen().isNetwork, isTrue);
    expect(
      const ConnectionSettings.udpHost(host: '10.0.0.2').createLink().label,
      contains('UDP 10.0.0.2'),
    );
    expect(
      const ConnectionSettings.tcpHost(host: '10.0.0.3').createLink().label,
      'TX WiFi TCP 10.0.0.3:5760',
    );
    expect(const ConnectionSettings.bluetooth(portName: 'COM9').isTransmitter, isTrue);
    expect(
      const ConnectionSettings.bluetooth(portName: 'COM9').createLink().label,
      'BT COM9 @ 57600',
    );
  });

  test('Bluetooth port filter matches SPP descriptions', () {
    final ports = [
      const SerialPortInfo(name: 'COM3', description: 'USB-SERIAL CH340'),
      const SerialPortInfo(name: 'COM7', description: 'Standard Serial over Bluetooth link'),
    ];
    final bt = listBluetoothTransmitterPorts(() => ports);
    expect(bt.map((d) => d.id), ['COM7']);
  });

  test('UdpFcLink listen receives peer datagrams and can reply', () async {
    final probe = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final listenPort = probe.port;
    probe.close();

    final peer = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(peer.close);

    final gcs = UdpFcLink(localPort: listenPort);
    await gcs.open();
    addTearDown(gcs.close);

    final received = gcs.incoming.first.timeout(const Duration(seconds: 2));
    peer.send(Uint8List.fromList([0xFE, 1, 2, 3]), InternetAddress.loopbackIPv4, listenPort);
    expect(await received, [0xFE, 1, 2, 3]);

    final replyFuture = peer
        .where((event) => event == RawSocketEvent.read)
        .map((_) => peer.receive())
        .firstWhere((datagram) => datagram != null)
        .timeout(const Duration(seconds: 2));
    gcs.write(Uint8List.fromList([0xAA, 0xBB]));
    final datagram = await replyFuture;
    expect(datagram!.data, [0xAA, 0xBB]);
  });
}
