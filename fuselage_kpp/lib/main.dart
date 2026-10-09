import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/router/app_router.dart';
import 'package:fuselage_kpp/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: FuselageKppApp()));
}

class FuselageKppApp extends StatelessWidget {
  const FuselageKppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fuselage-K++',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
