import 'package:fuselage_kpp/data/session/fc_session.dart';

/// Live check: FcSession.open + parameter download over BT COM4.
Future<void> main() async {
  const settings = ConnectionSettings.bluetooth(portName: 'COM4', baudRate: 57600);
  print('opening via FcSession...');
  try {
    final session = await FcSession.open(settings);
    print(
      'OPEN OK target=${session.connection.targetSystem} '
      'bytes=${session.connection.bytesReceived} '
      'radio=${session.connection.radioStatusFrames}',
    );
    await session.parameters.downloadAll(
      onProgress: (r, t) => print('params $r/$t'),
    );
    print('PARAMS OK count=${session.parameters.values.length}');
    await session.close();
  } catch (e) {
    print('FAIL $e');
  }
}
