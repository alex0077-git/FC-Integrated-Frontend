import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/params/param_catalog.dart';
import 'package:fuselage_kpp/data/session/fc_session.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';
import 'package:fuselage_kpp/data/session/parameter_service.dart';

void main() {
  late FcSession session;

  setUp(() async {
    session = await FcSession.open(const ConnectionSettings(useSimulator: true));
  });

  tearDown(() => session.close());

  test('downloads every K++ parameter with progress', () async {
    final progress = <int>[];

    await session.parameters.downloadAll(onProgress: (received, _) => progress.add(received));

    expect(session.parameters.values.keys, containsAll(ParamCatalog.all.map((s) => s.id)));
    expect(session.parameters.values['RTL_ALT'], 1500);
    expect(progress.last, ParamCatalog.all.length);
  });

  test('writes a parameter and returns the echoed value', () async {
    await session.parameters.downloadAll();

    final stored = await session.parameters.setParam('GAIN_BASIC_R_PI', 135);

    expect(stored, 135);
    expect(session.parameters.values['GAIN_BASIC_R_PI'], 135);
  });

  test('reports a read-only parameter the FC refuses to change', () async {
    await session.parameters.downloadAll();

    expect(
      () => session.parameters.setParam('FWVERSION', 1),
      throwsA(isA<ParameterException>().having((e) => e.message, 'message', contains('rejected'))),
    );
  });

  test('lists and downloads a flight log completely', () async {
    final logs = await session.logs.listLogs();
    final fractions = <double>[];

    final bytes = await session.logs.download(logs[1], onProgress: fractions.add);

    expect(logs.map((l) => l.id), [1, 2, 3]);
    expect(bytes.length, logs[1].size);
    expect(bytes[1000], 1000 & 0xFF);
    expect(fractions.last, 1.0);
  });

  test('telemetry fills in sensors, IMUs and RC channels (no mock GPS)', () async {
    final telemetry = await session.telemetry.updates.firstWhere(
      (t) => t.rcChannels.length >= 16 && t.imus.every((i) => i != null),
    );

    // Simulator must not invent GPS / compass Normal.
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
    expect(telemetry.healthOf(FcSensor.compass), SensorHealth.notConnected);
    expect(telemetry.latDeg, isNull);
    expect(telemetry.satellites, isNull);
    expect(telemetry.voltage, closeTo(48.2, 0.5));
    expect(telemetry.rcChannels[10], 1100);
  });
}
