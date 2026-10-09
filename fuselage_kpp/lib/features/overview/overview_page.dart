import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/core/widgets/status_tile.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

/// Status check (状态检测): mirrors JIYI sensor / GPS1 / GPS2 / IMU tiles.
class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  static const int _goodSatellites = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(telemetryProvider);
    final params = ref.watch(paramValuesProvider);
    final connection = ref.watch(fcConnectionProvider);

    return RequiresConnection(
      child: PageScaffold(
        title: 'Status',
        description: 'Live health of the flight controller and its modules (K++ assistant layout).',
        children: [
          AppCard(
            title: 'Sensors',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [for (final sensor in FcSensor.values) _sensorTile(sensor, telemetry.healthOf(sensor))],
            ),
          ),
          AppCard(
            title: 'IMU',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < 3; i++) _sensorTileLabel('IMU${i + 1}', telemetry.imuHealth(i)),
              ],
            ),
          ),
          AppCard(
            title: 'GPS',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatusTile(label: 'GPS1', value: telemetry.gpsFixLabel, level: _fixLevel(telemetry.gpsFixType)),
                StatusTile(
                  label: 'GPS1 sats',
                  value: telemetry.satellites?.toString() ?? '—',
                  level: _satLevel(telemetry.satellites),
                ),
                StatusTile(label: 'GPS2', value: telemetry.gps2FixLabel, level: _fixLevel(telemetry.gps2FixType)),
                StatusTile(
                  label: 'GPS2 sats',
                  value: telemetry.gps2Satellites?.toString() ?? '—',
                  level: _satLevel(telemetry.gps2Satellites),
                ),
                StatusTile(
                  label: 'Position',
                  value: telemetry.latDeg == null || telemetry.lonDeg == null
                      ? '—'
                      : '${telemetry.latDeg!.toStringAsFixed(7)}, ${telemetry.lonDeg!.toStringAsFixed(7)}',
                  level: telemetry.latDeg == null ? StatusLevel.unknown : StatusLevel.good,
                ),
                StatusTile(
                  label: 'Altitude',
                  value: telemetry.altMeters == null ? '—' : '${telemetry.altMeters!.toStringAsFixed(1)} m',
                  level: StatusLevel.unknown,
                ),
                StatusTile(label: 'HDOP', value: telemetry.hdop?.toStringAsFixed(2) ?? '—', level: StatusLevel.unknown),
              ],
            ),
          ),
          AppCard(
            title: 'Power & link',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatusTile(
                  label: 'Battery voltage',
                  value: telemetry.voltage == null ? '—' : '${telemetry.voltage!.toStringAsFixed(2)} V',
                  level: _voltageLevel(telemetry.voltage, params['FS_BATT_WARNING'], params['FS_BATT_VOLTAGE']),
                ),
                StatusTile(
                  label: 'RC signal',
                  value: telemetry.rssi == null ? '—' : '${telemetry.rssi}',
                  level: telemetry.rssi == null ? StatusLevel.unknown : StatusLevel.good,
                ),
                StatusTile(label: 'Link', value: connection.session?.linkLabel ?? '—', level: StatusLevel.good),
                StatusTile(
                  label: 'Firmware version',
                  value: _intOrDash(params['FWVERSION']),
                  level: StatusLevel.unknown,
                ),
                StatusTile(
                  label: 'Software revision',
                  value: _intOrDash(params['SYSID_SW_MREV']),
                  level: StatusLevel.unknown,
                ),
                StatusTile(label: 'Parameters', value: '${params.length}', level: StatusLevel.unknown),
              ],
            ),
          ),
          if (telemetry.lastStatusText != null)
            AppCard(
              title: 'Flight controller message',
              child: Text(telemetry.lastStatusText!),
            ),
        ],
      ),
    );
  }

  static Widget _sensorTile(FcSensor sensor, SensorHealth health) => _sensorTileLabel(sensor.label, health);

  static Widget _sensorTileLabel(String label, SensorHealth health) {
    final (value, level) = switch (health) {
      SensorHealth.healthy => ('Normal', StatusLevel.good),
      SensorHealth.fault => ('Fault', StatusLevel.critical),
      SensorHealth.notConnected => ('Not connected', StatusLevel.unknown),
    };
    return StatusTile(label: label, value: value, level: level);
  }

  static const int _min3dFix = 3;

  static StatusLevel _fixLevel(int? fixType) => switch (fixType) {
    null => StatusLevel.unknown,
    >= _min3dFix => StatusLevel.good,
    _ => StatusLevel.critical,
  };

  static StatusLevel _satLevel(int? satellites) {
    if (satellites == null) {
      return StatusLevel.unknown;
    }
    if (satellites >= _goodSatellites) {
      return StatusLevel.good;
    }
    if (satellites > 0) {
      return StatusLevel.warning;
    }
    return StatusLevel.critical;
  }

  static StatusLevel _voltageLevel(double? voltage, double? level1, double? level2) {
    if (voltage == null) {
      return StatusLevel.unknown;
    }
    if (level2 != null && voltage <= level2) {
      return StatusLevel.critical;
    }
    if (level1 != null && voltage <= level1) {
      return StatusLevel.warning;
    }
    return StatusLevel.good;
  }

  static String _intOrDash(double? value) => value == null ? '—' : value.toStringAsFixed(0);
}
