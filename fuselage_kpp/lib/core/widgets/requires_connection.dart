import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Shows [child] only while a flight-controller session is open.
class RequiresConnection extends ConsumerWidget {
  const RequiresConnection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSession = ref.watch(fcConnectionProvider.select((s) => s.hasSession));
    if (hasSession) {
      return child;
    }
    final l10n = KppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.usb_off, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(l10n.notConnected, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            l10n.notConnectedHint,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
