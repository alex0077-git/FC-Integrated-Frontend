import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Explains a K++ function that is disabled until its JIYI-specific
/// command has been confirmed from a traffic recording of the original app.
class PendingFeatureCard extends StatelessWidget {
  const PendingFeatureCard({super.key, required this.title, required this.description, this.actionLabel});

  final String title;
  final String description;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    return AppCard(
      title: title,
      subtitle: l10n.waitingForProtocolConfirmation,
      trailing: const Icon(Icons.hourglass_empty),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          const SizedBox(height: 8),
          Text(
            l10n.pendingFeatureBody,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: null, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
