import 'package:fc_frontend/core/map/map_view.dart';
import 'package:fc_frontend/core/theme/theme_mode_provider.dart';
import 'package:fc_frontend/core/widgets/language_selector.dart';
import 'package:fc_frontend/core/widgets/responsive.dart';
import 'package:fc_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const appVersion = '1.0.0';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  String _units = 'Metric';

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final mapView = ref.watch(mapViewModeProvider);
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final phone = Responsive.isPhone(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        phone ? 16 : 24,
        phone ? 16 : 32,
        phone ? 16 : 24,
        24,
      ),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: scheme.primary.withValues(alpha: 0.15),
            child: Icon(Icons.person, size: 40, color: scheme.primary),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: l10n.username,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: LanguageSelector(compact: false),
        ),
        const SizedBox(height: 24),
        Text(l10n.theme, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ThemeChoice(
                label: l10n.themeLight,
                selected: themeMode == ThemeMode.light,
                onPressed: () => ref
                    .read(themeModeProvider.notifier)
                    .setMode(ThemeMode.light),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ThemeChoice(
                label: l10n.themeDark,
                selected: themeMode == ThemeMode.dark,
                onPressed: () => ref
                    .read(themeModeProvider.notifier)
                    .setMode(ThemeMode.dark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _units,
          decoration: InputDecoration(
            labelText: l10n.units,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 'Metric', child: Text(l10n.unitsMetric)),
            DropdownMenuItem(value: 'Imperial', child: Text(l10n.unitsImperial)),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() => _units = value);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<MapViewMode>(
          key: ValueKey(mapView),
          initialValue: mapView,
          decoration: InputDecoration(
            labelText: l10n.mapStyle,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: MapViewMode.street, child: Text(l10n.mapStreet)),
            DropdownMenuItem(
              value: MapViewMode.satellite,
              child: Text(l10n.mapSatellite),
            ),
            DropdownMenuItem(
              value: MapViewMode.digitalSky,
              child: Text(l10n.mapDigitalSky),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }
            ref.read(mapViewModeProvider.notifier).setMode(value);
          },
        ),
        const SizedBox(height: 24),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.tune),
          title: Text(l10n.kppTuningTitle),
          subtitle: Text(l10n.kppTuningSubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/overview'),
        ),
        const SizedBox(height: 16),
        Text(l10n.about, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(l10n.appTitle),
        Text(l10n.versionLabel(appVersion)),
        const SizedBox(height: 4),
        Text(
          l10n.appTagline,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? scheme.primary : scheme.onSurface,
        side: BorderSide(color: selected ? scheme.primary : scheme.outline),
      ),
      child: Text(label),
    );
  }
}
