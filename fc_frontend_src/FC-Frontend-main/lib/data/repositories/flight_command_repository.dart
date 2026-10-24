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
        // Already armed from TX or a previous app arm — both are valid.
        if (session.telemetry.current.armed) {
          return;
        }
        await session.commands.arm(force: true);
        if (!session.telemetry.current.armed) {
          throw const FlightCommandException(
            'Not armed yet. Tap Arm again in the app, or arm on the transmitter '
            '(throttle low + yaw right) — both work in parallel.',
          );
        }
      });

  Future<void> disarm() => _run((session) => session.commands.disarm());

  Future<void> takeoff({double altitudeMeters = 10}) {
    return _run((session) async {
      _requireFlyReady(session, needGps: true);
      if (!session.telemetry.current.armed) {
        try {
          await session.commands.arm(force: true);
        } on CommandException {
          // TX may arm in parallel — wait briefly for either path.
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
      if (!session.telemetry.current.armed) {
        throw const FlightCommandException(
          'Not armed for takeoff. Arm from the app or the transmitter, then Takeoff.',
        );
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

  /// Instant land on the live K++ (USB serial or wireless). Rejects simulator.
  Future<void> land() {
    return _run((session) async {
      _requireLiveSession(session);
      await session.commands.land();
    });
  }

  Future<void> setAutoMode() {
    return _run((session) async {
      await _putAutoOnRepeatedSwitchPosition(session);
      if (session.telemetry.current.customMode != CopterMode.auto) {
        throw const FlightCommandException(
          'Flip the switch to the position that was Mode 23. That position is now Auto. AltHold and Loiter stay.',
        );
      }
    });
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
      await _putAutoOnRepeatedSwitchPosition(session);
      // Prefer app arm; TX stick-arm is equally valid if the craft is already armed
      // or the pilot arms on the transmitter in parallel.
      if (!session.telemetry.current.armed) {
        try {
          await session.commands.arm(force: true);
        } on CommandException {
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
      }
      if (!session.telemetry.current.armed) {
        throw const FlightCommandException(
          'Mission uploaded. Arm from the app or the transmitter '
          '(throttle low + yaw right), then flip to Auto (former Mode 23).',
        );
      }
      if (session.telemetry.current.customMode != CopterMode.auto) {
        throw const FlightCommandException(
          'Mission uploaded and armed. Flip the switch to the position that was Mode 23. That position is now Auto. AltHold and Loiter stay.',
        );
      }
      try {
        await session.commands.startMission();
      } on CommandException {
        // Auto mode alone starts the mission on many K++ / ArduCopter builds.
      }
    } on FlightCommandException {
      rethrow;
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
    final reason = _gpsNotReadyReason(telemetry);
    if (reason != null) {
      throw FlightCommandException(reason);
    }
  }

  /// The transmitter's third position is custom mode 23. Leave AltHold and
  /// Loiter alone and store Auto in every mode-23 slot that is not selected.
  Future<void> _putAutoOnRepeatedSwitchPosition(FcSession session) async {
    const thirdMode = 23;
    final saved = <int, int>{};
    for (var slot = 1; slot <= 6; slot++) {
      final raw = session.parameters.values['FLTMODE$slot'];
      if (raw != null) {
        saved[slot] = raw.round();
      }
    }
    if (saved.isEmpty || !saved.values.contains(thirdMode)) {
      if (saved.values.contains(CopterMode.auto)) {
        return;
      }
      throw const FlightCommandException(
        'Mode 23 was not found on the switch, so Auto was not written.',
      );
    }

    final active = _activeModeSlot(session);
    final targets = <int>[
      for (final entry in saved.entries)
        if (entry.value == thirdMode && entry.key != active) entry.key,
    ];
    if (targets.isEmpty) {
      throw const FlightCommandException(
        'Move the switch to AltHold or Loiter, then upload again. The Mode 23 position will be set to Auto.',
      );
    }
    for (final slot in targets) {
      await session.parameters.setParam('FLTMODE$slot', CopterMode.auto.toDouble());
    }
  }

  /// PWM band of the flight-mode switch, or null when the stick position is unknown.
  int? _activeModeSlot(FcSession session) {
    final channel = session.parameters.values['FLTMODE_CH']?.round() ?? 5;
    final channels = session.telemetry.current.rcChannels;
    if (channel < 1 || channel > channels.length) {
      return null;
    }
    final pwm = channels[channel - 1];
    if (pwm < 900 || pwm > 2200) {
      return null;
    }
    if (pwm < 1231) {
      return 1;
    }
    if (pwm < 1361) {
      return 2;
    }
    if (pwm < 1491) {
      return 3;
    }
    if (pwm < 1621) {
      return 4;
    }
    if (pwm < 1750) {
      return 5;
    }
    return 6;
  }

  /// Same bar as the UI: RAW 3D+ or K++ quality Good/RTK, ≥6 sats, live lat/lon.
  static String? _gpsNotReadyReason(FcTelemetry telemetry) {
    final fix = _max(telemetry.gpsFixType, telemetry.gps2FixType);
    final liveSats = telemetry.displaySatellites;
    final sats = liveSats ?? _max(telemetry.satellites, telemetry.gps2Satellites);
    final hasPosition = telemetry.latDeg != null && telemetry.lonDeg != null;
    final quality = telemetry.gpsQuality;
    final qualityOk = quality != null && quality >= 4;
    final label = fix >= 2
        ? FcTelemetry.fixLabelFor(fix)
        : (quality != null
            ? FcTelemetry.observedQualityLabel(quality)
            : FcTelemetry.fixLabelFor(fix == 0 ? null : fix));

    if (fix < 3 && !qualityOk) {
      return 'GPS is $label · $sats sats. Need Good GPS quality (or a 3D fix) before arming.';
    }
    if (sats < 6) {
      return 'GPS is $label with only $sats satellites. Need at least 6 sats outdoors before arming.';
    }
    if (!hasPosition) {
      return 'GPS fix looks up but no live position yet. Wait a few seconds and try again.';
    }
    return null;
  }

  static int _max(int? a, int? b) {
    final left = a ?? 0;
    final right = b ?? 0;
    return left > right ? left : right;
  }
}

final flightCommandRepositoryProvider = Provider<FlightCommandRepository>((ref) {
  return FlightCommandRepository(ref);
});
