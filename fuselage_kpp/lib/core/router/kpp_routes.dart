import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/router/app_destinations.dart';
import 'package:fuselage_kpp/core/widgets/app_shell.dart';
import 'package:fuselage_kpp/features/channels/channels_page.dart';
import 'package:fuselage_kpp/features/equipment/liquid_page.dart';
import 'package:fuselage_kpp/features/equipment/pump_page.dart';
import 'package:fuselage_kpp/features/extensions/extensions_page.dart';
import 'package:fuselage_kpp/features/fence/fence_page.dart';
import 'package:fuselage_kpp/features/firmware/firmware_page.dart';
import 'package:fuselage_kpp/features/flight/flight_page.dart';
import 'package:fuselage_kpp/features/gains/gains_page.dart';
import 'package:fuselage_kpp/features/installation/installation_page.dart';
import 'package:fuselage_kpp/features/logs/logs_page.dart';
import 'package:fuselage_kpp/features/mission/mission_page.dart';
import 'package:fuselage_kpp/features/overview/overview_page.dart';
import 'package:fuselage_kpp/features/parameters/parameters_page.dart';
import 'package:fuselage_kpp/features/protection/protection_page.dart';
import 'package:fuselage_kpp/features/remote_control/remote_control_page.dart';
import 'package:fuselage_kpp/features/sensors/sensors_page.dart';
import 'package:fuselage_kpp/features/spraying/spraying_page.dart';
import 'package:go_router/go_router.dart';

final Map<AppDestination, Widget Function()> kppPages = {
  AppDestinations.overview: OverviewPage.new,
  AppDestinations.installation: InstallationPage.new,
  AppDestinations.remoteControl: RemoteControlPage.new,
  AppDestinations.sensors: SensorsPage.new,
  AppDestinations.flight: FlightPage.new,
  AppDestinations.gains: GainsPage.new,
  AppDestinations.protection: ProtectionPage.new,
  AppDestinations.pump: PumpPage.new,
  AppDestinations.liquid: LiquidPage.new,
  AppDestinations.spraying: SprayingPage.new,
  AppDestinations.fence: FencePage.new,
  AppDestinations.extensions: ExtensionsPage.new,
  AppDestinations.channels: ChannelsPage.new,
  AppDestinations.mission: MissionPage.new,
  AppDestinations.logs: LogsPage.new,
  AppDestinations.parameters: ParametersPage.new,
  AppDestinations.firmware: FirmwarePage.new,
};

/// K++ tuning shell + pages for embedding in a host [GoRouter].
ShellRoute buildKppShellRoute({
  bool showConnectionBar = true,
  bool showProductLinks = false,
}) {
  return ShellRoute(
    builder: (context, state, child) => AppShell(
      currentPath: state.uri.path,
      showConnectionBar: showConnectionBar,
      showProductLinks: showProductLinks,
      child: child,
    ),
    routes: [
      for (final destination in AppDestinations.all)
        GoRoute(
          path: destination.path,
          pageBuilder: (context, state) => NoTransitionPage(child: kppPages[destination]!()),
        ),
    ],
  );
}
