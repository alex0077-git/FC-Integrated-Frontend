class Telemetry {
  const Telemetry({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.heading,
    this.battery,
    this.batteryVoltage,
    this.batteryRemainingRaw,
    required this.gpsCount,
    required this.gpsFixLabel,
    required this.hasGpsFix,
    required this.mode,
    required this.armed,
    this.flowRateLpm,
    this.liquidLevelPercent,
    this.sprayedLiters,
  });

  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double heading;

  /// Resolved display percent when known; prefer [resolveBatteryPercent] with settings.
  final double? battery;

  /// Pack voltage from SYS_STATUS (volts), when the FC reports it.
  final double? batteryVoltage;

  /// Raw MAVLink remaining % (0–100), or null when unknown / not estimated (−1).
  final int? batteryRemainingRaw;

  final int gpsCount;
  final String gpsFixLabel;
  final bool hasGpsFix;
  final String mode;
  final bool armed;

  /// Flow meter (K1) rate in L/min when the FC reports it.
  final double? flowRateLpm;

  /// Liquid level 0–100 when reported.
  final double? liquidLevelPercent;

  /// Cumulative sprayed liters when reported.
  final double? sprayedLiters;
}
