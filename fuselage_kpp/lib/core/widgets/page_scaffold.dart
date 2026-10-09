import 'package:flutter/material.dart';

/// Scrollable page body with a title and evenly spaced sections.
class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.title, required this.children, this.description});

  static const double maxContentWidth = 960;

  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(description!, style: theme.textTheme.bodySmall),
            ],
            for (final child in children) ...[const SizedBox(height: 20), child],
          ],
        ),
      ),
    );
  }
}
