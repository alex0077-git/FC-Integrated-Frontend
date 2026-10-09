import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/link/simulated_fc_link.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/mission/mission_item.dart';
import 'package:fuselage_kpp/data/mission/waypoint_file.dart';
import 'package:fuselage_kpp/data/session/command_service.dart';
import 'package:fuselage_kpp/data/session/mavlink_connection.dart';
import 'package:fuselage_kpp/data/session/mission_service.dart';

void main() {
  group('CommandService', () {
    test('motor test is acknowledged by the simulator', () async {
      final link = SimulatedFcLink();
      final connection = MavlinkConnection(link: link);
      await connection.start();
      // Wait for first heartbeat so target ids settle.
      await connection.packets.first;
      final commands = CommandService(connection);
      final ack = await commands.motorTest(motorIndex: 1, throttlePercent: 10, seconds: 1);
      expect(ack.command, MavCmd.doMotorTest);
      expect(ack.result, MavResult.accepted);
      await commands.dispose();
      await connection.close();
    });

    test('set mode updates simulator heartbeat customMode', () async {
      final link = SimulatedFcLink();
      final connection = MavlinkConnection(link: link);
      await connection.start();
      await connection.packets.first;
      final commands = CommandService(connection);
      await commands.setMode(5);
      final hb = await connection.messagesOf<Heartbeat>().firstWhere((h) => h.type != Heartbeat.typeGcs);
      expect(hb.customMode, 5);
      await commands.dispose();
      await connection.close();
    });

    test('arm takeoff and start mission are acknowledged', () async {
      final link = SimulatedFcLink();
      final connection = MavlinkConnection(link: link);
      await connection.start();
      await connection.packets.first;
      final commands = CommandService(connection);
      expect((await commands.arm()).result, MavResult.accepted);
      expect((await commands.takeoff(altitudeMeters: 12)).result, MavResult.accepted);
      expect((await commands.startMission()).result, MavResult.accepted);
      await commands.dispose();
      await connection.close();
    });
  });

  group('MissionService', () {
    test('upload then download round-trips waypoints', () async {
      final link = SimulatedFcLink();
      final connection = MavlinkConnection(link: link);
      await connection.start();
      await connection.packets.first;
      final missions = MissionService(connection);
      final items = [
        const MissionItem(
          seq: 0,
          command: MavCmd.navTakeoff,
          frame: MavFrame.globalRelativeAltInt,
          lat: 12.97,
          lon: 77.59,
          alt: 15,
        ),
        const MissionItem(
          seq: 1,
          command: MavCmd.navWaypoint,
          frame: MavFrame.globalRelativeAltInt,
          lat: 12.971,
          lon: 77.591,
          alt: 20,
        ),
      ];
      await missions.upload(items);
      final downloaded = await missions.download();
      expect(downloaded, hasLength(2));
      expect(downloaded[1].command, MavCmd.navWaypoint);
      expect(downloaded[1].lat, closeTo(12.971, 1e-6));
      await connection.close();
    });
  });

  group('WaypointFile', () {
    test('encode/decode preserves items', () {
      final items = [
        const MissionItem(
          seq: 0,
          command: MavCmd.navWaypoint,
          frame: MavFrame.globalRelativeAltInt,
          lat: 1.25,
          lon: 2.5,
          alt: 30,
        ),
      ];
      final text = WaypointFile.encode(items);
      expect(text, contains('QGC WPL 110'));
      final decoded = WaypointFile.decode(text);
      expect(decoded.single.lat, 1.25);
      expect(decoded.single.lon, 2.5);
      expect(decoded.single.alt, 30);
    });

    test('AB generator creates takeoff, lanes and RTL', () {
      final mission = generateAbSprayMission(
        latA: 12.0,
        lonA: 77.0,
        latB: 12.001,
        lonB: 77.0,
        swathMeters: 5,
        altitude: 20,
        speedMps: 4,
        legs: 4,
      );
      expect(mission.first.command, MavCmd.navTakeoff);
      expect(mission.last.command, MavCmd.navReturnToLaunch);
      expect(mission.where((m) => m.command == MavCmd.navWaypoint).length, greaterThan(4));
    });
  });
}
