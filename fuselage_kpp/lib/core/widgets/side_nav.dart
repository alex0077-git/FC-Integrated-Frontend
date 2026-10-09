import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/router/app_destinations.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:go_router/go_router.dart';

/// Left sidebar listing every screen under Basic / Advanced / Tools.
class SideNav extends StatelessWidget {
  const SideNav({super.key, required this.currentPath, this.showProductLinks = false});

  static const double width = 220;

  final String currentPath;
  final bool showProductLinks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Material(
        color: theme.colorScheme.surface,
        shape: const Border(right: BorderSide(color: AppCard.borderColor)),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/fuselage_logo.jpeg',
                      package: 'fuselage_kpp',
                      width: 32,
                      height: 32,
                      errorBuilder: (_, _, _) => Image.asset(
                        'assets/images/fuselage_logo.jpeg',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Fuselage-K++',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            if (showProductLinks) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 16, 4),
                child: Text(
                  'FLY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              _LinkTile(
                icon: Icons.flight,
                label: 'Map / fly',
                selected: currentPath == '/map',
                onTap: () => context.go('/map'),
              ),
              _LinkTile(
                icon: Icons.architecture,
                label: 'Ground plan',
                selected: currentPath == '/ground-plan',
                onTap: () => context.go('/ground-plan'),
              ),
              _LinkTile(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: currentPath == '/',
                onTap: () => context.go('/'),
              ),
              const SizedBox(height: 8),
            ],
            for (final group in DestinationGroup.values) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
                child: Text(
                  group.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, color: theme.colorScheme.primary),
                ),
              ),
              for (final destination in AppDestinations.all.where((d) => d.group == group))
                _NavTile(destination: destination, selected: currentPath == destination.path),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.destination, required this.selected});

  final AppDestination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return _LinkTile(
      icon: destination.icon,
      label: destination.label,
      selected: selected,
      onTap: () => context.go(destination.path),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        dense: true,
        selected: selected,
        selectedColor: primary,
        selectedTileColor: const Color(0xFF1A2740),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(icon, size: 20),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}
