import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';

/// One editable mission waypoint / command.
class MissionItem {
  const MissionItem({
    required this.seq,
    required this.command,
    required this.frame,
    required this.lat,
    required this.lon,
    required this.alt,
    this.param1 = 0,
    this.param2 = 0,
    this.param3 = 0,
    this.param4 = 0,
    this.autocontinue = 1,
  });

  final int seq;
  final int command;
  final int frame;
  final double lat;
  final double lon;
  final double alt;
  final double param1;
  final double param2;
  final double param3;
  final double param4;
  final int autocontinue;

  MissionItem copyWith({
    int? seq,
    int? command,
    int? frame,
    double? lat,
    double? lon,
    double? alt,
    double? param1,
    double? param2,
    double? param3,
    double? param4,
    int? autocontinue,
  }) {
    return MissionItem(
      seq: seq ?? this.seq,
      command: command ?? this.command,
      frame: frame ?? this.frame,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      alt: alt ?? this.alt,
      param1: param1 ?? this.param1,
      param2: param2 ?? this.param2,
      param3: param3 ?? this.param3,
      param4: param4 ?? this.param4,
      autocontinue: autocontinue ?? this.autocontinue,
    );
  }

  factory MissionItem.fromMav(MissionItemInt item) {
    return MissionItem(
      seq: item.seq,
      command: item.command,
      frame: item.frame,
      lat: item.latDeg,
      lon: item.lonDeg,
      alt: item.z,
      param1: item.param1,
      param2: item.param2,
      param3: item.param3,
      param4: item.param4,
      autocontinue: item.autocontinue,
    );
  }

  MissionItemInt toMav({required int targetSystem, required int targetComponent, int current = 0}) {
    return MissionItemInt(
      seq: seq,
      command: command,
      targetSystem: targetSystem,
      targetComponent: targetComponent,
      frame: frame,
      x: (lat * 1e7).round(),
      y: (lon * 1e7).round(),
      z: alt,
      param1: param1,
      param2: param2,
      param3: param3,
      param4: param4,
      current: current,
      autocontinue: autocontinue,
    );
  }

  String get commandLabel => switch (command) {
    MavCmd.navWaypoint => 'Waypoint',
    MavCmd.navTakeoff => 'Takeoff',
    MavCmd.navLand => 'Land',
    MavCmd.navReturnToLaunch => 'RTL',
    MavCmd.doChangeSpeed => 'Change speed',
    MavCmd.doSetServo => 'Set servo',
    _ => 'CMD $command',
  };
}
