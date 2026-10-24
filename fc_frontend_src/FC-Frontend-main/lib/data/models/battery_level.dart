import 'package:fc_frontend/data/models/battery_settings.dart';

/// Live battery readout for the **aircraft pack attached to the K++**.
///
/// Source of truth order:
/// 1. FC remaining % when the flight controller reports it (0–100).
/// 2. Otherwise charge % of **that same pack** from its live FC pack voltage,
///    using Battery settings cell count / range when they match the pack.
///
/// Never uses phone battery. Voltage is always the FC PMU pack reading.
class BatteryDisplay {
  const BatteryDisplay._({
    this.percent,
    this.voltage,
    this.percentFromVoltage = false,
    this.cellCount,
  });

  /// Charge of the attached pack: FC % if reported, else voltage-based estimate.
  factory BatteryDisplay.fromFc({
    required int? remaining,
    required double? voltage,
    BatterySettings settings = const BatterySettings(),
  }) {
    final remainingOk = remaining != null && remaining >= 0 && remaining <= 100;
    final volts = voltage;
    // Up to ~14S agri packs (~58 V).
    final voltageOk = volts != null && volts > 0 && volts < 60;

    if (remainingOk) {
      return BatteryDisplay._(
        percent: remaining.toDouble(),
        voltage: voltageOk ? volts : null,
        cellCount: voltageOk ? resolvePackCellCount(volts, settings) : null,
      );
    }

    if (!voltageOk) {
      return const BatteryDisplay._();
    }

    final cells = resolvePackCellCount(volts, settings);
    final estimated = estimateChargePercent(volts, settings, cells: cells);
    return BatteryDisplay._(
      percent: estimated,
      voltage: volts,
      percentFromVoltage: estimated != null,
      cellCount: cells,
    );
  }

  /// Charge of the attached pack (0–100), or null when unknown.
  final double? percent;

  /// Live FC pack voltage (volts) of that same battery.
  final double? voltage;

  /// True when [percent] came from pack voltage (FC did not send remaining %).
  final bool percentFromVoltage;

  /// Cell count used for the attached pack (settings or inferred).
  final int? cellCount;

  bool get hasPercent => percent != null;
  bool get hasVoltage => voltage != null;

  /// Compact HUD label: charge first, pack volts beside it for verification.
  String get hudLabel {
    if (percent != null && voltage != null) {
      return '${percent!.toStringAsFixed(0)}% · ${voltage!.toStringAsFixed(1)}V';
    }
    if (percent != null) {
      return '${percent!.toStringAsFixed(0)}%';
    }
    if (voltage != null) {
      return '${voltage!.toStringAsFixed(2)}V';
    }
    return '--';
  }
}

/// Cell count for the pack currently on the craft.
///
/// Prefers Battery settings when per-cell voltage is in a valid LiPo window
/// (so the % tracks *your* attached pack). Otherwise infers S-count from volts.
int resolvePackCellCount(double volts, BatterySettings settings) {
  final configured = settings.cellCount.clamp(1, 18);
  final perConfigured = volts / configured;
  // Allow empty packs (~3.3 V/cell) so settings still track the attached pack.
  if (perConfigured >= 3.30 && perConfigured <= 4.3) {
    return configured;
  }
  return _inferCellCount(volts, configured);
}

/// Charge % of the attached pack from its FC pack voltage.
///
/// Uses a LiPo per-cell curve (not a straight line), so mid-pack voltages map
/// closer to real remaining capacity than min/max linear scaling alone.
double? estimateChargePercent(
  double volts,
  BatterySettings settings, {
  int? cells,
}) {
  final cellCount = cells ?? resolvePackCellCount(volts, settings);
  final perCell = volts / cellCount;
  return _lipoChargePercentFromCellVolts(perCell);
}

/// Resting / light-load LiPo SoC curve (V/cell → %). Interpolated.
double _lipoChargePercentFromCellVolts(double cellVolts) {
  // Typical LiPo open-circuit / light-load points (V → %).
  const table = <(double, double)>[
    (4.20, 100),
    (4.15, 95),
    (4.11, 90),
    (4.08, 85),
    (4.02, 80),
    (3.98, 75),
    (3.95, 70),
    (3.91, 65),
    (3.87, 60),
    (3.85, 55),
    (3.84, 50),
    (3.82, 45),
    (3.80, 40),
    (3.79, 35),
    (3.77, 30),
    (3.75, 25),
    (3.73, 20),
    (3.71, 15),
    (3.69, 10),
    (3.61, 5),
    (3.50, 0),
  ];

  if (cellVolts >= table.first.$1) {
    return 100;
  }
  if (cellVolts <= table.last.$1) {
    return 0;
  }

  for (var i = 0; i < table.length - 1; i++) {
    final (highV, highPct) = table[i];
    final (lowV, lowPct) = table[i + 1];
    if (cellVolts <= highV && cellVolts >= lowV) {
      final t = (cellVolts - lowV) / (highV - lowV);
      return (lowPct + (highPct - lowPct) * t).clamp(0.0, 100.0);
    }
  }
  return 0;
}

/// Pick S-count where per-cell voltage sits nearest a typical LiPo ~3.9 V.
int _inferCellCount(double volts, int configuredCells) {
  var best = configuredCells.clamp(1, 18);
  var bestDist = double.infinity;
  for (var cells = 1; cells <= 18; cells++) {
    final perCell = volts / cells;
    if (perCell < 3.45 || perCell > 4.3) {
      continue;
    }
    final dist = (perCell - 3.9).abs();
    if (dist < bestDist) {
      bestDist = dist;
      best = cells;
    }
  }
  return best;
}

/// Pack charge warnings from Battery settings.
///
/// [first] = first warning threshold (warn only).
/// [second] = second warning threshold (warn + auto RTL while armed).
enum BatteryAlertLevel { first, second }

BatteryAlertLevel? batteryAlertLevel(
  BatteryDisplay battery,
  BatterySettings settings,
) {
  final percent = battery.percent;
  if (percent != null) {
    if (percent < settings.secondWarningPercent) {
      return BatteryAlertLevel.second;
    }
    if (percent < settings.firstWarningPercent) {
      return BatteryAlertLevel.first;
    }
    return null;
  }

  final volts = battery.voltage;
  if (volts == null) {
    return null;
  }
  if (volts <= settings.criticalVoltageThreshold) {
    return BatteryAlertLevel.second;
  }
  if (volts <= settings.lowVoltageThreshold) {
    return BatteryAlertLevel.first;
  }
  return null;
}
