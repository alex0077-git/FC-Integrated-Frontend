import 'package:fc_frontend/core/theme/app_theme.dart';
import 'package:fc_frontend/core/widgets/bottom_nav_bar.dart';
import 'package:fc_frontend/core/widgets/connect_panel.dart';
import 'package:fc_frontend/core/widgets/settings_hub.dart';
import 'package:fc_frontend/data/models/battery_level.dart';
import 'package:fc_frontend/data/models/battery_settings.dart';
import 'package:fc_frontend/data/repositories/settings_repository.dart';
import 'package:fc_frontend/data/repositories/telemetry_repository.dart';
import 'package:fc_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FlightStatusBar extends ConsumerWidget {
  const FlightStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(telemetryStreamProvider).asData?.value;
    final settings = ref.watch(batterySettingsProvider);
    final connected = ref.watch(telemetryConnectionProvider);
    final statusColors =
        Theme.of(context).extension<AppStatusColors>() ?? AppStatusColors.dark;
    final battery = telemetry == null
        ? null
        : BatteryDisplay.fromFc(
            remaining: telemetry.batteryRemainingRaw,
            voltage: telemetry.batteryVoltage,
            settings: settings,
          );
    final batteryColor = _batteryColor(battery, settings, statusColors);
    final location = GoRouterState.of(context).uri.path;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: AppTheme.surface,
      child: SizedBox(
        height: 32,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _BatteryReadout(battery: battery, color: batteryColor),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusChip(
                  icon: Icons.satellite_alt,
                  label: telemetry == null
                      ? l10n.gpsUnknown
                      : l10n.gpsStatus(
                          telemetry.gpsFixLabel,
                          '${telemetry.gpsCount}',
                        ),
                ),
              ),
              Expanded(
                child: _StatusChip(
                  icon: Icons.flight,
                  label: telemetry == null ? l10n.modeUnknown : telemetry.mode,
                ),
              ),
              _TopBarIcon(
                tooltip: l10n.profile,
                icon: Icons.person_outline,
                selected: location == '/profile',
                onPressed: () => context.go('/profile'),
              ),
              _TopBarIcon(
                tooltip: l10n.settings,
                icon: Icons.settings_outlined,
                selected: location.startsWith('/settings'),
                onPressed: () => showSettingsHub(context),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 24),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 12, height: 1),
                ),
                onPressed: () => _openConnectPanel(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.connect),
                    const SizedBox(width: 4),
                    Semantics(
                      label: connected ? l10n.connected : l10n.disconnected,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: connected
                              ? statusColors.statusGood
                              : const Color(0xFF6B7280),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openConnectPanel(BuildContext context) {
    final navigatorContext = shellNavigatorKey.currentContext ?? context;
    showModalBottomSheet<void>(
      context: navigatorContext,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(navigatorContext).colorScheme.surface,
      showDragHandle: true,
      builder: (context) => const ConnectPanel(),
    );
  }
}

class _TopBarIcon extends StatelessWidget {
  const _TopBarIcon({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 16,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      icon: Icon(icon, color: selected ? scheme.primary : scheme.onSurface),
    );
  }
}

class _BatteryReadout extends StatelessWidget {
  const _BatteryReadout({required this.battery, required this.color});

  final BatteryDisplay? battery;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Attached aircraft pack only: charge % + live pack volts for verification.
    final label = battery?.hudLabel ?? '--';
    final fraction = battery?.percent == null ? null : battery!.percent! / 100;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.battery_std, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, height: 1, color: color),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fraction ?? 0,
              minHeight: 3,
              backgroundColor: const Color(0xFF2A3548),
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    const itemColor = AppTheme.text;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: itemColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, height: 1.1, color: itemColor),
          ),
        ),
      ],
    );
  }
}

Color _batteryColor(
  BatteryDisplay? battery,
  BatterySettings settings,
  AppStatusColors statusColors,
) {
  if (battery == null) {
    return statusColors.statusGood;
  }
  return switch (batteryAlertLevel(battery, settings)) {
    BatteryAlertLevel.second => statusColors.statusCritical,
    BatteryAlertLevel.first => statusColors.statusWarning,
    null => statusColors.statusGood,
  };
}
