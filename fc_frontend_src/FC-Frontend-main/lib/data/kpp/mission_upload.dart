import 'package:fc_frontend/data/models/waypoint.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/mission/mission_item.dart';

/// Converts FC frontend coverage waypoints into MAVLink mission items for K++.
List<MissionItem> waypointsToMissionItems(
  List<Waypoint> waypoints, {
  double takeoffAltitude = 10,
}) {
  if (waypoints.isEmpty) {
    return const [];
  }

  final first = waypoints.first;
  final items = <MissionItem>[
    MissionItem(
      seq: 0,
      command: MavCmd.navTakeoff,
      frame: MavFrame.globalRelativeAltInt,
      lat: first.latitude,
      lon: first.longitude,
      alt: takeoffAltitude > 0 ? takeoffAltitude : first.altitude,
    ),
  ];

  var seq = 1;
  double? lastSpeed;
  for (final waypoint in waypoints) {
    if (lastSpeed == null || (waypoint.speed - lastSpeed).abs() > 0.05) {
      items.add(
        MissionItem(
          seq: seq++,
          command: MavCmd.doChangeSpeed,
          frame: MavFrame.globalRelativeAltInt,
          lat: 0,
          lon: 0,
          alt: 0,
          param1: 1,
          param2: waypoint.speed,
        ),
      );
      lastSpeed = waypoint.speed;
    }

    final command = switch (waypoint.action) {
      WaypointAction.land => MavCmd.navLand,
      WaypointAction.loiter => MavCmd.navWaypoint,
      WaypointAction.waypoint => MavCmd.navWaypoint,
    };
    items.add(
      MissionItem(
        seq: seq++,
        command: command,
        frame: MavFrame.globalRelativeAltInt,
        lat: waypoint.latitude,
        lon: waypoint.longitude,
        alt: waypoint.altitude,
        param1: waypoint.action == WaypointAction.loiter ? 1 : 0,
      ),
    );
  }

  items.add(
    MissionItem(
      seq: seq,
      command: MavCmd.navReturnToLaunch,
      frame: MavFrame.globalRelativeAltInt,
      lat: 0,
      lon: 0,
      alt: 0,
    ),
  );
  return items;
}
