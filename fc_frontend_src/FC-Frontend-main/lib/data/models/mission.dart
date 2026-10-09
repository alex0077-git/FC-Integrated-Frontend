import 'package:fc_frontend/data/models/waypoint.dart';

/// How a mission entered the local database.
enum MissionOrigin { saved, uploaded }

class Mission {
  const Mission({
    required this.id,
    required this.name,
    required this.waypoints,
    this.origin = MissionOrigin.saved,
    this.savedAt,
  });

  final String id;
  final String name;
  final List<Waypoint> waypoints;
  final MissionOrigin origin;
  final DateTime? savedAt;

  Mission copyWith({
    String? name,
    List<Waypoint>? waypoints,
    MissionOrigin? origin,
    DateTime? savedAt,
  }) {
    return Mission(
      id: id,
      name: name ?? this.name,
      waypoints: waypoints ?? this.waypoints,
      origin: origin ?? this.origin,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin.name,
      'savedAt': (savedAt ?? DateTime.now()).toIso8601String(),
      'waypoints': [for (final waypoint in waypoints) waypoint.toJson()],
    };
  }

  factory Mission.fromJson(Map<String, dynamic> json) {
    final originName = json['origin'] as String? ?? MissionOrigin.saved.name;
    final origin = MissionOrigin.values.firstWhere(
      (value) => value.name == originName,
      orElse: () => MissionOrigin.saved,
    );
    final rawWaypoints = json['waypoints'] as List<dynamic>? ?? const [];
    return Mission(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Mission',
      origin: origin,
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? ''),
      waypoints: [
        for (final item in rawWaypoints)
          Waypoint.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
    );
  }
}
