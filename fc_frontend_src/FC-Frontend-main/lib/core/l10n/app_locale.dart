import 'package:fc_frontend/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app languages (English, Arabic, German, Spanish, Hindi).
abstract final class AppLocales {
  static const en = Locale('en');
  static const ar = Locale('ar');
  static const de = Locale('de');
  static const es = Locale('es');
  static const hi = Locale('hi');

  static const List<Locale> supported = [en, ar, de, es, hi];

  static Locale resolve(String? code) {
    switch (code) {
      case 'ar':
        return ar;
      case 'de':
        return de;
      case 'es':
        return es;
      case 'hi':
        return hi;
      case 'en':
      default:
        return en;
    }
  }
}

const _localeKey = 'app.locale';

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._preferences)
      : super(AppLocales.resolve(_preferences.getString(_localeKey)));

  final SharedPreferences _preferences;

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _preferences.setString(_localeKey, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref.watch(sharedPreferencesProvider));
});
