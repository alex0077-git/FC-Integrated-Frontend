import 'dart:convert';
import 'dart:io';

import 'package:fc_frontend/data/models/mission.dart';
import 'package:fc_frontend/data/models/waypoint.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactoryFfi, sqfliteFfiInit;

/// Local SQLite store for Ground Plan saved / uploaded missions.
class MissionDatabase {
  MissionDatabase._(this._db);

  final Database _db;

  static const _dbName = 'fuselage_missions.db';
  static const _table = 'missions';

  /// Prepare platform SQLite (FFI on desktop, plugin on mobile).
  static void ensureInitialized() {
    if (kIsWeb) {
      return;
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Open (or create) the missions database. Returns null on web.
  static Future<MissionDatabase?> open() async {
    if (kIsWeb) {
      return null;
    }
    ensureInitialized();
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, _dbName);
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
CREATE TABLE $_table (
  id TEXT PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  origin TEXT NOT NULL,
  saved_at TEXT NOT NULL,
  waypoints_json TEXT NOT NULL
)
''');
      },
    );
    return MissionDatabase._(db);
  }

  Future<List<Mission>> loadAll() async {
    final rows = await _db.query(
      _table,
      orderBy: 'saved_at DESC',
    );
    return [
      for (final row in rows) _fromRow(row),
    ];
  }

  Future<void> upsert(Mission mission) async {
    final savedAt = mission.savedAt ?? DateTime.now();
    await _db.insert(
      _table,
      {
        'id': mission.id,
        'name': mission.name,
        'origin': mission.origin.name,
        'saved_at': savedAt.toIso8601String(),
        'waypoints_json': jsonEncode([
          for (final waypoint in mission.waypoints) waypoint.toJson(),
        ]),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() => _db.close();

  Mission _fromRow(Map<String, Object?> row) {
    final originName = row['origin'] as String? ?? MissionOrigin.saved.name;
    final origin = MissionOrigin.values.firstWhere(
      (value) => value.name == originName,
      orElse: () => MissionOrigin.saved,
    );
    final decoded = jsonDecode(row['waypoints_json'] as String) as List<dynamic>;
    return Mission(
      id: row['id'] as String,
      name: row['name'] as String,
      origin: origin,
      savedAt: DateTime.tryParse(row['saved_at'] as String? ?? ''),
      waypoints: [
        for (final item in decoded)
          Waypoint.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
    );
  }
}
