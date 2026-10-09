import 'dart:math' as math;

import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/mission/mission_item.dart';

/// QGroundControl / Mission Planner WPL 110 waypoint file helpers.
abstract final class WaypointFile {
  static String encode(List<MissionItem> items) {
    final buffer = StringBuffer('QGC WPL 110\n');
    for (final item in items) {
      buffer.writeln(
        [
          item.seq,
          item.seq == 0 ? 1 : 0,
          item.frame,
          item.command,
          item.param1,
          item.param2,
          item.param3,
          item.param4,
          item.lat,
          item.lon,
          item.alt,
          item.autocontinue,
        ].join('\t'),
      );
    }
    return buffer.toString();
  }

  static List<MissionItem> decode(String text) {
    final lines = text.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      return const [];
    }
    var start = 0;
    if (lines.first.toUpperCase().startsWith('QGC WPL')) {
      start = 1;
    }
    final items = <MissionItem>[];
    for (var i = start; i < lines.length; i++) {
      final parts = lines[i].split(RegExp(r'\s+'));
      if (parts.length < 12) {
        continue;
      }
      items.add(
        MissionItem(
          seq: int.parse(parts[0]),
          frame: int.parse(parts[2]),
          command: int.parse(parts[3]),
          param1: double.parse(parts[4]),
          param2: double.parse(parts[5]),
          param3: double.parse(parts[6]),
          param4: double.parse(parts[7]),
          lat: double.parse(parts[8]),
          lon: double.parse(parts[9]),
          alt: double.parse(parts[10]),
          autocontinue: int.parse(parts[11]),
        ),
      );
    }
    return items;
  }
}

/// Builds a simple lawnmower AB spray pattern between two points.
List<MissionItem> generateAbSprayMission({
  required double latA,
  required double lonA,
  required double latB,
  required double lonB,
  required double swathMeters,
  required double altitude,
  required double speedMps,
  int legs = 6,
}) {
  final midLat = (latA + latB) / 2;
  const metersPerDegLat = 111320.0;
  final metersPerDegLon = 111320.0 * math.cos(midLat * math.pi / 180);

  final dx = (lonB - lonA) * metersPerDegLon;
  final dy = (latB - latA) * metersPerDegLat;
  final len = math.max(1.0, math.sqrt(dx * dx + dy * dy));
  final ux = dx / len;
  final uy = dy / len;
  final px = -uy;
  final py = ux;

  final items = <MissionItem>[
    MissionItem(
      seq: 0,
      command: MavCmd.navTakeoff,
      frame: MavFrame.globalRelativeAltInt,
      lat: latA,
      lon: lonA,
      alt: altitude,
    ),
    MissionItem(
      seq: 1,
      command: MavCmd.doChangeSpeed,
      frame: MavFrame.globalRelativeAltInt,
      lat: 0,
      lon: 0,
      alt: 0,
      param1: 1,
      param2: speedMps,
    ),
  ];

  var seq = 2;
  for (var i = 0; i < legs; i++) {
    final offset = (i - (legs - 1) / 2) * swathMeters;
    final latOff = (py * offset) / metersPerDegLat;
    final lonOff = (px * offset) / metersPerDegLon;
    final startLat = (i.isEven ? latA : latB) + latOff;
    final startLon = (i.isEven ? lonA : lonB) + lonOff;
    final endLat = (i.isEven ? latB : latA) + latOff;
    final endLon = (i.isEven ? lonB : lonA) + lonOff;
    items.add(
      MissionItem(
        seq: seq++,
        command: MavCmd.navWaypoint,
        frame: MavFrame.globalRelativeAltInt,
        lat: startLat,
        lon: startLon,
        alt: altitude,
      ),
    );
    items.add(
      MissionItem(
        seq: seq++,
        command: MavCmd.navWaypoint,
        frame: MavFrame.globalRelativeAltInt,
        lat: endLat,
        lon: endLon,
        alt: altitude,
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
