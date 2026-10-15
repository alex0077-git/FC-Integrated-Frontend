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
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Status check (状态检测): mirrors JIYI sensor / GPS1 / GPS2 / IMU tiles.
class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final telemetry = ref.watch(telemetryProvider);
    final params = ref.watch(paramValuesProvider);
    final connection = ref.watch(fcConnectionProvider);

    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destOverview,
        description: l10n.overviewDescription,
        children: [
          AppCard(
            title: l10n.sensors,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final sensor in FcSensor.values)
                  if (sensor == FcSensor.gps)
                    StatusTile(
                      label: _sensorName(l10n, sensor),
                      value: telemetry.statusGpsSensorValue,
                      level: _gpsQualityToneLevel(telemetry.statusGpsSensorTone),
                    )
                  else
                    _sensorTile(l10n, sensor, telemetry.healthOf(sensor)),
              ],
            ),
          ),
          AppCard(
            title: l10n.imu,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < 3; i++) _sensorTileLabel(l10n, 'IMU${i + 1}', telemetry.imuHealth(i)),
              ],
            ),
          ),
          AppCard(
            title: l10n.gps,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatusTile(
                  label: 'GPS quality',
                  value: telemetry.gpsQualityLabel,
                  level: _gpsQualityToneLevel(telemetry.statusGpsSensorTone),
                ),
                StatusTile(
                  label: 'Satellites',
                  value: telemetry.statusSatellitesValue,
                  level: _gpsQualityToneLevel(telemetry.statusSatellitesTone),
                ),
                StatusTile(
                  label: l10n.position,
                  value: telemetry.statusPositionValue,
                  level: _gpsQualityToneLevel(telemetry.statusPositionTone),
                ),
                StatusTile(
                  label: l10n.altitude,
                  value: telemetry.altMeters == null ? '—' : '${telemetry.altMeters!.toStringAsFixed(1)} m',
                  level: StatusLevel.unknown,
                ),
                if (telemetry.hasFreshStandardGpsDetail) ...[
                  StatusTile(label: l10n.gps1, value: telemetry.gpsFixLabel, level: _fixLevel(telemetry.gpsFixType)),
                  StatusTile(
                    label: l10n.gps1Sats,
                    value: _satText(telemetry.gpsRawIntReceivedAt == null ? null : telemetry.satellites),
                    level: _satLevel(telemetry.gpsRawIntReceivedAt == null ? null : telemetry.satellites),
                  ),
                  StatusTile(label: l10n.gps2, value: telemetry.gps2FixLabel, level: _fixLevel(telemetry.gps2FixType)),
                  StatusTile(
                    label: l10n.gps2Sats,
                    value: _satText(telemetry.gps2Satellites),
                    level: _satLevel(telemetry.gps2Satellites),
                  ),
                  StatusTile(
                    label: l10n.hdop,
                    value: telemetry.hdop?.toStringAsFixed(2) ?? '—',
                    level: StatusLevel.unknown,
                  ),
                ] else
                  SizedBox(
                    width: StatusTile.width * 2 + 12,
                    child: Text(
                      'GPS1/GPS2 detail not reported by this firmware',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                          ),
                    ),
                  ),
              ],
            ),
          ),
          AppCard(
            title: l10n.powerAndLink,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatusTile(
                  label: l10n.batteryVoltage,
                  value: telemetry.voltage == null ? '—' : '${telemetry.voltage!.toStringAsFixed(2)} V',
                  level: _voltageLevel(telemetry.voltage, params['FS_BATT_WARNING'], params['FS_BATT_VOLTAGE']),
                ),
                StatusTile(
                  label: l10n.rcSignal,
                  value: telemetry.rssi == null ? '—' : '${telemetry.rssi}',
                  level: telemetry.rssi == null ? StatusLevel.unknown : StatusLevel.good,
                ),
                StatusTile(label: l10n.link, value: connection.session?.linkLabel ?? '—', level: StatusLevel.good),
                StatusTile(
                  label: l10n.firmwareVersion,
                  value: _intOrDash(params['FWVERSION']),
                  level: StatusLevel.unknown,
                ),
                StatusTile(
                  label: l10n.softwareRevision,
                  value: _intOrDash(params['SYSID_SW_MREV']),
                  level: StatusLevel.unknown,
                ),
                StatusTile(label: l10n.parameters, value: '${params.length}', level: StatusLevel.unknown),
              ],
            ),
          ),
          if (telemetry.lastStatusText != null)
            AppCard(
              title: l10n.fcMessage,
              child: Text(telemetry.lastStatusText!),
            ),
        ],
      ),
    );
  }

  static String _sensorName(KppLocalizations l10n, FcSensor sensor) => switch (sensor) {
        FcSensor.gyro => l10n.sensorGyroscope,
        FcSensor.accelerometer => l10n.sensorAccelerometer,
        FcSensor.compass => l10n.sensorCompass,
        FcSensor.barometer => l10n.sensorBarometer,
        FcSensor.gps => l10n.sensorGps,
      };

  static Widget _sensorTile(KppLocalizations l10n, FcSensor sensor, SensorHealth health) =>
      _sensorTileLabel(l10n, _sensorName(l10n, sensor), health);

  static Widget _sensorTileLabel(KppLocalizations l10n, String label, SensorHealth health) {
    final (value, level) = switch (health) {
      SensorHealth.healthy => (l10n.statusNormal, StatusLevel.good),
      SensorHealth.fault => (l10n.statusFault, StatusLevel.critical),
      SensorHealth.notConnected => (l10n.statusNotConnected, StatusLevel.unknown),
    };
    return StatusTile(label: label, value: value, level: level);
  }

  static const int _min3dFix = 3;

  static StatusLevel _fixLevel(int? fixType) => switch (fixType) {
        null => StatusLevel.unknown,
        >= _min3dFix => StatusLevel.good,
        _ => StatusLevel.critical,
      };

  /// null → "—" (stale / no value).
  static String _satText(int? satellites) => satellites == null ? '—' : satellites.toString();

  static StatusLevel _satLevel(int? satellites) {
    if (satellites == null) {
      return StatusLevel.unknown;
    }
    if (satellites >= 6) {
      return StatusLevel.good;
    }
    if (satellites > 0) {
      return StatusLevel.warning;
    }
    return StatusLevel.unknown;
  }

  static StatusLevel _gpsQualityToneLevel(GpsQualityTone tone) => switch (tone) {
        GpsQualityTone.grey => StatusLevel.unknown,
        GpsQualityTone.amber => StatusLevel.warning,
        GpsQualityTone.green => StatusLevel.good,
        GpsQualityTone.blue => StatusLevel.info,
      };

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
