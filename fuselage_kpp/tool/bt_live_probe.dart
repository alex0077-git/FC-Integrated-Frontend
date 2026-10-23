import 'dart:async';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:fuselage_kpp/data/link/fc_link.dart';
import 'package:fuselage_kpp/data/link/serial_fc_link.dart';
import 'package:fuselage_kpp/data/session/mavlink_connection.dart';

/// Live check: open COM4 with the same stack as the app (clear MAVLink on BT).
Future<void> main() async {
  print('ports=${SerialPort.availablePorts}');
  final link = LabeledFcLink(
    SerialFcLink(portName: 'COM4', baudRate: 57600, resilient: true),
    'BT COM4 @ 57600',
  );
  final conn = MavlinkConnection(link: link);
  print('wireMode=${conn.wireMode}');
  final first = conn.packets.first.timeout(const Duration(seconds: 8));
  await conn.start();
  print('started, waiting for packet...');
  try {
    final p = await first;
    print(
      'GOT msgid=${p.messageId} sys=${p.systemId} '
      'bytes=${conn.bytesReceived} rejected=${conn.rejectedFrames}',
    );
  } catch (e) {
    print(
      'TIMEOUT/ERR $e bytes=${conn.bytesReceived} rejected=${conn.rejectedFrames}',
    );
  }
  await conn.close();
  print('done');
}
