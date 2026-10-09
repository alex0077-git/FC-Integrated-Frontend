import 'package:flutter/material.dart';

/// Sidebar groups, matching the K++ assistant's 基础 / 高级 / 工具 tabs.
enum DestinationGroup {
  basic('Basic'),
  advanced('Advanced'),
  tools('Tools');

  const DestinationGroup(this.label);

  final String label;
}

class AppDestination {
  const AppDestination(this.path, this.label, this.icon, this.group);

  final String path;
  final String label;
  final IconData icon;
  final DestinationGroup group;
}

abstract final class AppDestinations {
  static const overview = AppDestination('/overview', 'Status', Icons.monitor_heart_outlined, DestinationGroup.basic);
  static const installation = AppDestination('/installation', 'Installation', Icons.straighten, DestinationGroup.basic);
  static const remoteControl = AppDestination(
    '/remote-control',
    'Remote control',
    Icons.sports_esports_outlined,
    DestinationGroup.basic,
  );
  static const sensors = AppDestination('/sensors', 'Sensors', Icons.sensors, DestinationGroup.basic);
  static const flight = AppDestination('/flight', 'Motors & flight', Icons.speed, DestinationGroup.basic);
  static const gains = AppDestination('/gains', 'Gains', Icons.tune, DestinationGroup.advanced);
  static const protection = AppDestination(
    '/protection',
    'Protection',
    Icons.shield_outlined,
    DestinationGroup.advanced,
  );
  static const pump = AppDestination('/pump', 'Pump', Icons.water_drop_outlined, DestinationGroup.advanced);
  static const liquid = AppDestination('/liquid', 'Liquid level', Icons.opacity, DestinationGroup.advanced);
  static const spraying = AppDestination(
    '/spraying',
    'AB spraying',
    Icons.agriculture_outlined,
    DestinationGroup.advanced,
  );
  static const fence = AppDestination('/fence', 'Fence', Icons.fence, DestinationGroup.advanced);
  static const extensions = AppDestination(
    '/extensions',
    'Extensions',
    Icons.extension_outlined,
    DestinationGroup.advanced,
  );
  static const channels = AppDestination('/channels', 'Channel mapping', Icons.alt_route, DestinationGroup.advanced);
  static const mission = AppDestination('/mission', 'Mission', Icons.map_outlined, DestinationGroup.tools);
  static const logs = AppDestination('/logs', 'Flight logs', Icons.receipt_long_outlined, DestinationGroup.tools);
  static const parameters = AppDestination('/parameters', 'All parameters', Icons.list_alt, DestinationGroup.tools);
  static const firmware = AppDestination(
    '/firmware',
    'Firmware & about',
    Icons.system_update_alt,
    DestinationGroup.tools,
  );

  static const List<AppDestination> all = [
    overview,
    installation,
    remoteControl,
    sensors,
    flight,
    gains,
    protection,
    pump,
    liquid,
    spraying,
    fence,
    extensions,
    channels,
    mission,
    logs,
    parameters,
    firmware,
  ];
}
