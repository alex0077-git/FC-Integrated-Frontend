import 'package:fc_frontend/data/kpp/mission_upload.dart';
import 'package:fc_frontend/data/kpp/telemetry_mapper.dart';
import 'package:fc_frontend/data/models/waypoint.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/link/simulated_fc_link.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/session/command_service.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';
import 'package:fuselage_kpp/data/session/mavlink_connection.dart';
import 'package:fuselage_kpp/data/session/mission_service.dart';

void main() {
  test('mapFcTelemetry copies armed GPS and mode', () {
    const source = FcTelemetry(
      latDeg: 12.97,
      lonDeg: 77.59,
      altMeters: 18,
      groundSpeedMps: 4.5,
      headingDeg: 90,
      batteryRemaining: 77,
      gpsFixType: 3,
      satellites: 14,
      customMode: CopterMode.auto,
      baseMode: FcTelemetry.baseModeArmed,
    );
    final mapped = mapFcTelemetry(source);
    expect(mapped.latitude, 12.97);
    expect(mapped.gpsCount, 14);
    expect(mapped.hasGpsFix, isTrue);
    expect(mapped.mode, 'Auto');
    expect(mapped.armed, isTrue);
    expect(mapped.battery, 77);
  });

  test('mapFcTelemetry uses best of GPS1/GPS2 and marks no-fix', () {
    const source = FcTelemetry(
      gpsFixType: 1,
      satellites: 1,
      gps2FixType: 1,
      gps2Satellites: 3,
      batteryRemaining: 50,
      customMode: 0,
    );
    final mapped = mapFcTelemetry(source);
    expect(mapped.gpsCount, 3);
    expect(mapped.hasGpsFix, isFalse);
    expect(mapped.gpsFixLabel, 'No fix');
  });

  test('mapFcTelemetry uses K++ quality when RAW fix is absent (agri)', () {
    final source = FcTelemetry(
      latDeg: 12.97,
      lonDeg: 77.59,
      gpsQuality: 4,
      satellites: 16,
      gpsSatsReceivedAt: DateTime.now(),
      gpsAgriLinked: true,
      batteryRemaining: 80,
      customMode: 0,
    );
    final mapped = mapFcTelemetry(source);
    expect(mapped.gpsCount, 16);
    expect(mapped.gpsFixLabel, 'Good');
    expect(mapped.hasGpsFix, isTrue);
  });

  test('waypointsToMissionItems uses home takeoff path RTL (no speed cmds)', () {
    final items = waypointsToMissionItems(const [
      Waypoint(
        id: 'a',
        latitude: 12.97,
        longitude: 77.59,
        altitude: 12,
        speed: 5,
        action: WaypointAction.waypoint,
      ),
      Waypoint(
        id: 'b',
        latitude: 12.971,
        longitude: 77.591,
        altitude: 12,
        speed: 5,
        action: WaypointAction.waypoint,
      ),
    ]);
    expect(items[0].command, MavCmd.navWaypoint);
    expect(items[0].frame, MavFrame.globalRelativeAlt);
    expect(items[1].command, MavCmd.navTakeoff);
    expect(items.any((i) => i.command == MavCmd.doChangeSpeed), isFalse);
    // Home + two path waypoints.
    expect(items.where((i) => i.command == MavCmd.navWaypoint), hasLength(3));
    expect(items.last.command, MavCmd.navReturnToLaunch);
  });

  test('MAVLink arm takeoff rtl and mission upload round-trip on link fixture', () async {
    final link = SimulatedFcLink();
    final connection = MavlinkConnection(link: link);
    await connection.start();
    await connection.packets.first;
    final commands = CommandService(connection);
    final missions = MissionService(connection);

    await commands.arm();
    await commands.takeoff(altitudeMeters: 10);
    await commands.returnToLaunch();

    final items = waypointsToMissionItems(const [
      Waypoint(
        id: 'a',
        latitude: 12.97,
        longitude: 77.59,
        altitude: 12,
        speed: 4,
        action: WaypointAction.waypoint,
      ),
    ]);
    await missions.upload(items);
    await commands.setMode(CopterMode.auto);
    await commands.startMission();

    await commands.dispose();
    await connection.close();
  });
}
