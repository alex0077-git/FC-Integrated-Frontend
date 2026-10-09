// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/link/serial_fc_link.dart';
import 'package:fuselage_kpp/data/session/fc_session.dart';
import 'package:fuselage_kpp/main.dart';
import 'package:integration_test/integration_test.dart';

/// Runs on the real Windows build: native serial plugin, real COM ports.
///
///   flutter test integration_test -d windows
///
/// Live probe: parameter download, FRAME same-value echo, mission download.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const fcPort = String.fromEnvironment('FC_PORT', defaultValue: 'COM3');
  const probeBauds = [57600, 115200, 38400, 230400, 460800, 921600];

  testWidgets('desktop app lists real COM ports and runs against the simulator', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FuselageKppApp()));
    await tester.pumpAndSettle();

    final ports = SerialPortInfo.available();
    print('COM ports seen by the app: ${ports.map((p) => '${p.name} (${p.description})').join(', ')}');
    expect(ports.map((p) => p.name), contains(fcPort));

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulator (no hardware)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connect'));
    for (var i = 0; i < 50 && find.text('Connected · Simulator').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Connected · Simulator'), findsOneWidget);
    await tester.tap(find.text('Disconnect'));
    await tester.pumpAndSettle();
  });

  testWidgets('live probe: params, FRAME echo, mission download on $fcPort', (tester) async {
    final results = <String>[];
    var ok = false;
    for (final baud in probeBauds) {
      final settings = ConnectionSettings(useSimulator: false, portName: fcPort, baudRate: baud);
      FcSession? session;
      try {
        session = await FcSession.open(settings);
        // CH340 often toggles DTR on open and reboots the FC; wait for boot.
        await Future<void>.delayed(const Duration(seconds: 2));
        results.add('$baud: link up sys=${session.connection.targetSystem} comp=${session.connection.targetComponent}');

        await session.parameters.downloadAll();
        final values = session.parameters.values;
        results.add('$baud: CONNECTED, ${values.length} parameters');
        expect(values.length, greaterThan(100));

        for (final id in const ['FRAME', 'SHAPE', 'FENCE_ENABLE', 'FENCE_RADIUS', 'BATT_VOLT_MULT']) {
          results.add('  $id=${values[id]}');
        }
        expect(values.containsKey('FRAME'), isTrue);
        expect(values.containsKey('SHAPE'), isTrue);

        final frame = values['FRAME']!;
        final echoed = await session.parameters.setParam('FRAME', frame);
        results.add('  FRAME write echo=$echoed');
        expect(echoed, frame);

        try {
          final mission = await session.missions.download();
          results.add('  mission items=${mission.length}');
        } catch (error) {
          results.add('  mission download: $error');
        }

        ok = true;
        break;
      } catch (error) {
        final conn = session?.connection;
        results.add(
          '$baud: $error'
          '${conn != null ? ' (bytes=${conn.bytesReceived}, rejected=${conn.rejectedFrames})' : ''}',
        );
      } finally {
        await session?.close();
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
    print('LIVE PROBE RESULTS\n${results.join('\n')}');
    expect(ok, isTrue, reason: 'Expected a successful COM3 parameter download on one baud rate.');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
