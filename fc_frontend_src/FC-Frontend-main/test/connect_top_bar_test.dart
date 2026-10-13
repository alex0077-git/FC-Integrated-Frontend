import "package:fc_frontend/core/theme/app_theme.dart";
import "package:fc_frontend/core/widgets/connect_panel.dart";
import "package:fc_frontend/core/widgets/flight_status_bar.dart";
import "package:fc_frontend/data/repositories/settings_repository.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:fuselage_kpp/data/link/serial_fc_link.dart";
import "package:fuselage_kpp/data/repositories/connection_repository.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("narrow connect panel does not overflow", (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final errors = <FlutterErrorDetails>[];
    final old = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = old);

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          serialPortListerProvider.overrideWithValue(
            () => const [SerialPortInfo(name: "COM3", description: "USB-SERIAL CH340")],
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ConnectPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Connect live K++"), findsOneWidget);
    expect(
      errors.where((e) => e.exceptionAsString().contains("overflowed")),
      isEmpty,
      reason: errors.map((e) => e.exceptionAsString()).join("\n"),
    );
  });

  testWidgets("Connect from top bar opens without crash", (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (_, __) => Scaffold(
            body: Column(
              children: const [
                FlightStatusBar(),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ],
    );
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          serialPortListerProvider.overrideWithValue(
            () => const [SerialPortInfo(name: "COM3", description: "USB Serial")],
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark.copyWith(
            extensions: const <ThemeExtension<dynamic>>[AppStatusColors.dark],
          ),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text("Connect"));
    await tester.pumpAndSettle();
    expect(find.byType(ConnectPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("Connect survives serial lister failure", (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          serialPortListerProvider.overrideWithValue(
            () => throw StateError("serialport.dll missing"),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ConnectPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Connect live K++"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}