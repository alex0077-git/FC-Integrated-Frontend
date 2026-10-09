import 'package:fc_frontend/data/models/mission.dart';
import 'package:fc_frontend/data/models/waypoint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mission JSON round-trips waypoints for database storage', () {
    const mission = Mission(
      id: 'mission-1',
      name: 'Field A',
      origin: MissionOrigin.uploaded,
      savedAt: null,
      waypoints: [
        Waypoint(
          id: 'wp-1',
          latitude: 12.97,
          longitude: 77.59,
          altitude: 12,
          speed: 5,
          action: WaypointAction.waypoint,
          sectionIndex: 0,
          pumpOn: true,
        ),
        Waypoint(
          id: 'wp-2',
          latitude: 12.98,
          longitude: 77.60,
          altitude: 12,
          speed: 5,
          action: WaypointAction.land,
          sectionIndex: 1,
          pumpOn: false,
        ),
      ],
    );

    final restored = Mission.fromJson(mission.toJson());
    expect(restored.id, 'mission-1');
    expect(restored.name, 'Field A');
    expect(restored.origin, MissionOrigin.uploaded);
    expect(restored.waypoints, hasLength(2));
    expect(restored.waypoints[0].latitude, 12.97);
    expect(restored.waypoints[1].action, WaypointAction.land);
    expect(restored.waypoints[1].pumpOn, isFalse);
  });
}
