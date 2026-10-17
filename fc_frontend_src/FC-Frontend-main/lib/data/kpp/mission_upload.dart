import 'package:fc_frontend/data/models/waypoint.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/mission/mission_item.dart';

/// Converts FC frontend coverage waypoints into MAVLink mission items for K++.
///
/// Shape matches Mission Planner / ArduCopter expectations so the FC accepts
/// the upload (home WP → takeoff → path → RTL). Frame 3 only; no DO_CHANGE_SPEED
/// on the first pass — those were a common source of MAV_MISSION_INVALID (5).
List<MissionItem> waypointsToMissionItems(
  List<Waypoint> waypoints, {
  double takeoffAltitude = 10,
}) {
  if (waypoints.isEmpty) {
    return const [];
  }

  final first = waypoints.first;
  final homeAlt = first.altitude > 0 ? first.altitude : 0.0;
  final takeoffAlt = takeoffAltitude > 0 ? takeoffAltitude : (homeAlt > 0 ? homeAlt : 10.0);
  // Relative-alt frame used by Mission Planner-style uploads over MISSION_ITEM_INT.
  const frame = MavFrame.globalRelativeAlt;

  final items = <MissionItem>[
    // Seq 0 must be a home / position waypoint — not takeoff.
    MissionItem(
      seq: 0,
      command: MavCmd.navWaypoint,
      frame: frame,
      lat: first.latitude,
      lon: first.longitude,
      alt: homeAlt,
    ),
    MissionItem(
      seq: 1,
      command: MavCmd.navTakeoff,
      frame: frame,
      lat: first.latitude,
      lon: first.longitude,
      alt: takeoffAlt,
    ),
  ];

  var seq = 2;
  for (final waypoint in waypoints) {
    final command = switch (waypoint.action) {
      WaypointAction.land => MavCmd.navLand,
      WaypointAction.loiter => MavCmd.navWaypoint,
      WaypointAction.waypoint => MavCmd.navWaypoint,
    };
    items.add(
      MissionItem(
        seq: seq++,
        command: command,
        frame: frame,
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
      frame: frame,
      lat: 0,
      lon: 0,
      alt: 0,
    ),
  );
  return items;
}
