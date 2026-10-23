import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:fuselage_kpp/data/link/serial_fc_link.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_codec.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';

String _hex(Uint8List b) =>
    b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

/// Sniff COM4: raw bytes + clear vs K++ obfuscated parse, then try both TX modes.
Future<void> main(List<String> args) async {
  final portName = args.isNotEmpty ? args.first : 'COM4';
  print('available=${SerialPort.availablePorts}');
  final link = SerialFcLink(portName: portName, baudRate: 57600, resilient: true);
  final clear = MavFrameParser(wireMode: MavWireMode.clearMavlink1);
  final kpp = MavFrameParser(wireMode: MavWireMode.kppObfuscated);
  final clearEnc = MavFrameEncoder(
    systemId: 255,
    componentId: 190,
    wireMode: MavWireMode.clearMavlink1,
  );
  final kppEnc = MavFrameEncoder(
    systemId: 255,
    componentId: 190,
    wireMode: MavWireMode.kppObfuscated,
  );
  const hb = Heartbeat(type: Heartbeat.typeGcs, autopilot: Heartbeat.autopilotInvalid);

  var bytes = 0;
  var clearN = 0;
  var kppN = 0;
  final sub = link.incoming.listen((chunk) {
    bytes += chunk.length;
    final preview = chunk.length > 48 ? chunk.sublist(0, 48) : chunk;
    print('RX ${chunk.length}B hex=${_hex(preview)}${chunk.length > 48 ? "…" : ""}');
    for (final p in clear.addBytes(chunk)) {
      clearN++;
      print(
        '  CLEAR msgid=${p.messageId} sys=${p.systemId} '
        'msg=${p.message.runtimeType}',
      );
    }
    for (final p in kpp.addBytes(chunk)) {
      kppN++;
      print(
        '  KPP   msgid=${p.messageId} sys=${p.systemId} '
        'msg=${p.message.runtimeType}',
      );
    }
  });

  print('opening $portName…');
  await link.open();
  print('open ok; listen 3s idle…');
  await Future<void>.delayed(const Duration(seconds: 3));
  print('TX clear FE heartbeat');
  link.write(clearEnc.encode(hb));
  await Future<void>.delayed(const Duration(seconds: 3));
  print('TX K++ A1 heartbeat');
  link.write(kppEnc.encode(hb));
  await Future<void>.delayed(const Duration(seconds: 4));
  print('TX K++ PARAM_REQUEST_LIST + KppLinkSetup');
  link.write(kppEnc.encode(const ParamRequestList(targetSystem: 0, targetComponent: 0)));
  link.write(kppEnc.encode(const KppLinkSetup()));
  await Future<void>.delayed(const Duration(seconds: 5));
  print('SUMMARY bytes=$bytes clearPkts=$clearN kppPkts=$kppN '
      'clearReject=${clear.rejectedFrames} kppReject=${kpp.rejectedFrames}');
  await sub.cancel();
  await link.close();
}
