import 'package:fc_frontend/core/widgets/bottom_nav_bar.dart';
import 'package:fc_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showSettingsHub(BuildContext context) {
  final navigatorContext = shellNavigatorKey.currentContext ?? context;
  showModalBottomSheet<void>(
    context: navigatorContext,
    useRootNavigator: false,
    isScrollControlled: true,
    backgroundColor: Theme.of(navigatorContext).colorScheme.surface,
    showDragHandle: true,
    builder: (sheetContext) {
      return _SettingsHub(
        onSelect: (path) {
          Navigator.of(sheetContext).pop();
          context.go(path);
        },
      );
    },
  );
}

class _SettingsHub extends StatelessWidget {
  const _SettingsHub({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(l10n.calibration),
          onTap: () => onSelect('/settings/calibration'),
        ),
        ListTile(
          title: Text(l10n.battery),
          onTap: () => onSelect('/settings/battery'),
        ),
        ListTile(
          title: Text(l10n.flightParameters),
          onTap: () => onSelect('/settings/flight-parameters'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.tune),
          title: Text(l10n.kppTuningFull),
          subtitle: Text(l10n.kppTuningFullSubtitle),
          onTap: () => onSelect('/overview'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
