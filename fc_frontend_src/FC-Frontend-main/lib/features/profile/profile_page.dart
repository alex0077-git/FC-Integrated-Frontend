import 'package:fc_frontend/core/map/map_view.dart';
import 'package:fc_frontend/core/theme/theme_mode_provider.dart';
import 'package:fc_frontend/core/widgets/responsive.dart';
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
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Theme', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ThemeChoice(
                label: 'Light',
                selected: themeMode == ThemeMode.light,
                onPressed: () => ref
                    .read(themeModeProvider.notifier)
                    .setMode(ThemeMode.light),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ThemeChoice(
                label: 'Dark',
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
          decoration: const InputDecoration(
            labelText: 'Units',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Metric', child: Text('Metric')),
            DropdownMenuItem(value: 'Imperial', child: Text('Imperial')),
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
          decoration: const InputDecoration(
            labelText: 'Map style',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: MapViewMode.street, child: Text('Street')),
            DropdownMenuItem(
              value: MapViewMode.satellite,
              child: Text('Satellite'),
            ),
            DropdownMenuItem(
              value: MapViewMode.digitalSky,
              child: Text('Digital Sky'),
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
          title: const Text('K++ tuning'),
          subtitle: const Text('Full flight-controller assistant'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/overview'),
        ),
        const SizedBox(height: 16),
        Text('About', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Fuselage'),
        const Text('Version $appVersion'),
        const SizedBox(height: 4),
        Text(
          'Fly, plan missions, and tune K++ — one app.',
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
    if (selected) {
      return FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
