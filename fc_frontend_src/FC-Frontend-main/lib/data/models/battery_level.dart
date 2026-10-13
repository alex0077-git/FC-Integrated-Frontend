import 'package:fc_frontend/data/models/battery_settings.dart';

/// Live battery readout from the flight controller only — no estimated %.
class BatteryDisplay {
  const BatteryDisplay._({this.percent, this.voltage});

  /// Exact MAVLink remaining % (0–100) from the FC.
  factory BatteryDisplay.fromFc({
    required int? remaining,
    required double? voltage,
  }) {
    final remainingOk = remaining != null && remaining >= 0 && remaining <= 100;
    final volts = voltage;
    final voltageOk = volts != null && volts > 0 && volts < 60;
    return BatteryDisplay._(
      percent: remainingOk ? remaining.toDouble() : null,
      voltage: voltageOk ? volts : null,
    );
  }

  /// FC-reported remaining percent, or null when the FC does not estimate it.
  final double? percent;

  /// FC-reported pack voltage in volts, when available.
  final double? voltage;

  bool get hasPercent => percent != null;
  bool get hasVoltage => voltage != null;
}

/// Warning level from real FC values only (exact % preferred, else pack volts).
enum BatteryAlertLevel { warning, critical }

BatteryAlertLevel? batteryAlertLevel(
  BatteryDisplay battery,
  BatterySettings settings,
) {
  final percent = battery.percent;
  if (percent != null) {
    if (percent < settings.secondWarningPercent) {
      return BatteryAlertLevel.critical;
    }
    if (percent < settings.firstWarningPercent) {
      return BatteryAlertLevel.warning;
    }
    return null;
  }

  final volts = battery.voltage;
  if (volts == null) {
    return null;
  }
  if (volts <= settings.criticalVoltageThreshold) {
    return BatteryAlertLevel.critical;
  }
  if (volts <= settings.lowVoltageThreshold) {
    return BatteryAlertLevel.warning;
  }
  return null;
}
