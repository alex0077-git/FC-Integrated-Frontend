import 'package:fuselage_kpp/data/mavlink/mavlink_codec.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';

void main() {
  final a1 = MavFrameEncoder(
    systemId: 255,
    componentId: 190,
    wireMode: MavWireMode.kppObfuscated,
  );
  final fe = MavFrameEncoder(
    systemId: 255,
    componentId: 190,
    wireMode: MavWireMode.clearMavlink1,
  );
  const msg = Heartbeat(
    type: Heartbeat.typeGcs,
    autopilot: Heartbeat.autopilotInvalid,
  );
  String hex(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  print('A1 ${hex(a1.encode(msg))}');
  print('FE ${hex(fe.encode(msg))}');
}
