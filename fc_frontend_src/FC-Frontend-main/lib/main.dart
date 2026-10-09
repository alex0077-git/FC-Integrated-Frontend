import 'package:fc_frontend/core/router/app_router.dart';
import 'package:fc_frontend/core/theme/app_theme.dart' as host_theme;
import 'package:fc_frontend/core/theme/theme_mode_provider.dart';
import 'package:fc_frontend/core/widgets/phone_landscape_gate.dart';
import 'package:fc_frontend/data/database/mission_database.dart';
import 'package:fc_frontend/data/repositories/mission_repository.dart';
import 'package:fc_frontend/data/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/theme/app_theme.dart' as kpp_theme;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _lockPhoneLandscape();
  final preferences = await SharedPreferences.getInstance();
  final missionDatabase = await MissionDatabase.open();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        missionDatabaseProvider.overrideWithValue(missionDatabase),
      ],
      child: const FcApp(),
    ),
  );
}

class FcApp extends ConsumerWidget {
  const FcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Fuselage',
      debugShowCheckedModeBanner: false,
      // Register both host and K++ AppStatusColors — they are different Dart types.
      theme: host_theme.AppTheme.light.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          host_theme.AppStatusColors.light,
          kpp_theme.AppStatusColors.light,
        ],
      ),
      darkTheme: host_theme.AppTheme.dark.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          host_theme.AppStatusColors.dark,
          kpp_theme.AppStatusColors.dark,
        ],
      ),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return PhoneLandscapeGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

Future<void> _lockPhoneLandscape() async {
  if (kIsWeb) {
    return;
  }
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
