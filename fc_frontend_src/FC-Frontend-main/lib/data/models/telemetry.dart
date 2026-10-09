class Telemetry {
  const Telemetry({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.battery,
    required this.gpsCount,
    required this.gpsFixLabel,
    required this.hasGpsFix,
    required this.mode,
    required this.armed,
  });

  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double heading;
  final double battery;
  final int gpsCount;
  final String gpsFixLabel;
  final bool hasGpsFix;
  final String mode;
  final bool armed;
}
