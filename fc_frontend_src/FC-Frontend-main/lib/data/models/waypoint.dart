enum WaypointAction { waypoint, loiter, land }

class Waypoint {
  const Waypoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.action,
    this.sectionIndex = 0,
    this.pumpOn = true,
  });

  final String id;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final WaypointAction action;
  final int sectionIndex;

  /// False while this point is on the straight detour around a no-fly zone.
  /// The sprayer stays on for ordinary coverage.
  final bool pumpOn;

  Waypoint copyWith({
    double? altitude,
    double? speed,
    WaypointAction? action,
    bool? pumpOn,
  }) {
    return Waypoint(
      id: id,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      action: action ?? this.action,
      sectionIndex: sectionIndex,
      pumpOn: pumpOn ?? this.pumpOn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'action': action.name,
      'sectionIndex': sectionIndex,
      'pumpOn': pumpOn,
    };
  }

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    final actionName = json['action'] as String? ?? WaypointAction.waypoint.name;
    final action = WaypointAction.values.firstWhere(
      (value) => value.name == actionName,
      orElse: () => WaypointAction.waypoint,
    );
    return Waypoint(
      id: json['id'] as String? ?? 'wp',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0,
      action: action,
      sectionIndex: (json['sectionIndex'] as num?)?.toInt() ?? 0,
      pumpOn: json['pumpOn'] as bool? ?? true,
    );
  }
}
