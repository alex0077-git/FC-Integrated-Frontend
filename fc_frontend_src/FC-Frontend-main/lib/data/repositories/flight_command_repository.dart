import 'package:fc_frontend/data/kpp/mission_upload.dart';
import 'package:fc_frontend/data/models/waypoint.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/session/command_service.dart';
import 'package:fuselage_kpp/data/session/fc_session.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

class FlightCommandException implements Exception {
  const FlightCommandException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Live flight commands for a real K++ — rejects simulator / disconnected sessions.
class FlightCommandRepository {
  FlightCommandRepository(this._ref);

  final Ref _ref;

  FcSession? get _session => _ref.read(fcSessionProvider);

  bool get isConnected => _session != null && !_session!.isSimulated;

  Future<void> arm() => _run((session) async {
        _requireFlyReady(session, needGps: true);
        await session.commands.arm();
      });

  Future<void> disarm() => _run((session) => session.commands.disarm());

  Future<void> takeoff({double altitudeMeters = 10}) {
    return _run((session) async {
      _requireFlyReady(session, needGps: true);
      if (!session.telemetry.current.armed) {
        await session.commands.arm();
      }
      await session.commands.takeoff(altitudeMeters: altitudeMeters);
    });
  }

  Future<void> returnToLaunch() {
    return _run((session) async {
      _requireLiveSession(session);
      await session.commands.returnToLaunch();
    });
  }

  Future<void> land() {
    return _run((session) async {
      _requireLiveSession(session);
      await session.commands.land();
    });
  }

  Future<void> setAutoMode() {
    return _run((session) => session.commands.setMode(CopterMode.auto));
  }

  /// Uploads the planned coverage mission and starts Auto on the real aircraft.
  Future<void> uploadAndStartMission(
    List<Waypoint> waypoints, {
    double takeoffAltitude = 10,
  }) async {
    final session = _requireLiveSession(_session);
    _requireFlyReady(session, needGps: true);
    final items = waypointsToMissionItems(
      waypoints,
      takeoffAltitude: takeoffAltitude,
    );
    if (items.isEmpty) {
      throw const FlightCommandException('No waypoints to upload.');
    }
    try {
      await session.missions.upload(items);
      if (!session.telemetry.current.armed) {
        await session.commands.arm();
      }
      await session.commands.setMode(CopterMode.auto);
      try {
        await session.commands.startMission();
      } on CommandException {
        // Auto mode alone starts the mission on many K++ / ArduCopter builds.
      }
    } on CommandException catch (error) {
      throw FlightCommandException(error.message);
    } catch (error) {
      throw FlightCommandException(error.toString());
    }
  }

  Future<void> _run(Future<void> Function(FcSession session) action) async {
    final session = _requireLiveSession(_session);
    try {
      await action(session);
    } on FlightCommandException {
      rethrow;
    } on CommandException catch (error) {
      throw FlightCommandException(error.message);
    } catch (error) {
      throw FlightCommandException(error.toString());
    }
  }

  FcSession _requireLiveSession(FcSession? session) {
    if (session == null) {
      throw const FlightCommandException(
        'Not connected to a live K++. Open Connect and link over USB or wireless MAVLink.',
      );
    }
    if (session.isSimulated) {
      throw const FlightCommandException(
        'Simulator link is disabled for flying. Connect the real K++ over USB or wireless MAVLink.',
      );
    }
    return session;
  }

  void _requireFlyReady(FcSession session, {required bool needGps}) {
    _requireLiveSession(session);
    if (!needGps) {
      return;
    }
    final telemetry = session.telemetry.current;
    if (!_hasNavFix(telemetry)) {
      throw const FlightCommandException(
        'No GPS 3D fix yet. Wait for a live lock before arming or flying.',
      );
    }
  }

  static bool _hasNavFix(FcTelemetry telemetry) {
    final fix = telemetry.gpsFixType ?? 0;
    final sats = telemetry.satellites ?? 0;
    final hasPosition = telemetry.latDeg != null && telemetry.lonDeg != null;
    return fix >= 3 && sats >= 6 && hasPosition;
  }
}

final flightCommandRepositoryProvider = Provider<FlightCommandRepository>((ref) {
  return FlightCommandRepository(ref);
});
