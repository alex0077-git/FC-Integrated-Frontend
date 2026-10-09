import 'package:fuselage_kpp/core/router/app_destinations.dart';
import 'package:fuselage_kpp/core/router/kpp_routes.dart';
import 'package:go_router/go_router.dart';

/// Standalone Fuselage-K++ entry (also embedded into fc_frontend via [buildKppShellRoute]).
final GoRouter appRouter = GoRouter(
  initialLocation: AppDestinations.overview.path,
  routes: [
    buildKppShellRoute(showConnectionBar: true, showProductLinks: false),
  ],
);
