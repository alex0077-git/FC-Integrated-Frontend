import 'package:fc_frontend/core/l10n/app_locale.dart';
import 'package:fc_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compact language dropdown used on the landing page and profile.
/// Always shows the active language name in the selected locale.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key, this.compact = true});

  final bool compact;

  static String languageName(AppLocalizations l10n, Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return l10n.langArabic;
      case 'de':
        return l10n.langGerman;
      case 'es':
        return l10n.langSpanish;
      case 'hi':
        return l10n.langHindi;
      case 'en':
      default:
        return l10n.langEnglish;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final scheme = Theme.of(context).colorScheme;
    final currentName = languageName(l10n, locale);

    return Material(
      color: scheme.surface.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentLanguage(currentName),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, size: compact ? 18 : 20, color: scheme.primary),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<Locale>(
                    value: locale,
                    isDense: true,
                    borderRadius: BorderRadius.circular(10),
                    dropdownColor: scheme.surface,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    items: [
                      DropdownMenuItem(
                        value: AppLocales.en,
                        child: Text(l10n.langEnglish),
                      ),
                      DropdownMenuItem(
                        value: AppLocales.ar,
                        child: Text(l10n.langArabic),
                      ),
                      DropdownMenuItem(
                        value: AppLocales.de,
                        child: Text(l10n.langGerman),
                      ),
                      DropdownMenuItem(
                        value: AppLocales.es,
                        child: Text(l10n.langSpanish),
                      ),
                      DropdownMenuItem(
                        value: AppLocales.hi,
                        child: Text(l10n.langHindi),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      ref.read(localeProvider.notifier).setLocale(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
