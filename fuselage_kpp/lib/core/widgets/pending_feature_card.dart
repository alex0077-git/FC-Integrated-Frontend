import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';

/// Explains a K++ function that is disabled until its JIYI-specific
/// command has been confirmed from a traffic recording of the original app.
class PendingFeatureCard extends StatelessWidget {
  const PendingFeatureCard({super.key, required this.title, required this.description, this.actionLabel});

  final String title;
  final String description;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: title,
      subtitle: 'Waiting for protocol confirmation',
      trailing: const Icon(Icons.hourglass_empty),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          const SizedBox(height: 8),
          Text(
            'The K++ assistant uses a JIYI-specific command for this, not standard MAVLink. '
            'It stays disabled until a recording of the original app confirms the exact message, '
            'so nothing unverified is ever sent to the flight controller.',
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
