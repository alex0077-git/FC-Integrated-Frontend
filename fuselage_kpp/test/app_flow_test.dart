import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/features/params/param_field.dart';
import 'package:fuselage_kpp/main.dart';

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
}

void main() {
  testWidgets('connect to simulator, read status, edit a gain, disconnect', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [serialPortListerProvider.overrideWithValue(() => const [])],
        child: const FuselageKppApp(),
      ),
    );
    expect(find.text('Not connected'), findsOneWidget);

    await tester.tap(find.text('Connect'));
    await _pumpUntilFound(tester, find.text('Connected · Simulator'));

    await _pumpUntilFound(tester, find.text('Normal'));
    expect(find.text('RTK fixed'), findsOneWidget);
    expect(find.text('221014'), findsOneWidget);

    await tester.tap(find.text('Gains'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    final rollCorrection = find.descendant(
      of: find.byWidgetPredicate((w) => w is ParamField && w.spec.id == 'GAIN_BASIC_R_PI'),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(rollCorrection).controller!.text, '100');

    await tester.enterText(rollCorrection, '150');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpUntilFound(tester, find.text('GAIN_BASIC_R_PI saved: 150'));

    await tester.enterText(rollCorrection, '250');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('Maximum is 200'), findsOneWidget);

    await tester.tap(find.text('Disconnect'));
    await _pumpUntilFound(tester, find.text('Not connected'));
    // Allow async session.close() to cancel simulator timers.
    await tester.pump(const Duration(seconds: 1));
  });
}
