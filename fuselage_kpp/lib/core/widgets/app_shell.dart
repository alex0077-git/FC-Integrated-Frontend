import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/connection_bar.dart';
import 'package:fuselage_kpp/core/widgets/side_nav.dart';

/// Desktop layout: sidebar on the left, optional connection bar on top, page below.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentPath,
    required this.child,
    this.showConnectionBar = true,
    this.showProductLinks = false,
  });

  final String currentPath;
  final Widget child;
  final bool showConnectionBar;

  /// When embedded in the unified Fuselage app, show Fly / Ground Plan shortcuts.
  final bool showProductLinks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNav(currentPath: currentPath, showProductLinks: showProductLinks),
          Expanded(
            child: Column(
              children: [
                if (showConnectionBar) const ConnectionBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
