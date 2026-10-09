import 'package:fc_frontend/data/models/telemetry.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

/// Maps K++ [FcTelemetry] into the FC frontend [Telemetry] model.
Telemetry mapFcTelemetry(FcTelemetry source) {
  final sats1 = source.satellites ?? 0;
  final sats2 = source.gps2Satellites ?? 0;
  final bestSats = sats1 > sats2 ? sats1 : sats2;
  final fixType = _bestFixType(source.gpsFixType, source.gps2FixType);
  final hasFix = fixType >= 3 &&
      bestSats >= 6 &&
      source.latDeg != null &&
      source.lonDeg != null;

  return Telemetry(
    // Keep last known / zero only when no coordinates yet — UI hides marker if !hasFix.
    latitude: source.latDeg ?? 0,
    longitude: source.lonDeg ?? 0,
    altitude: source.altMeters ?? 0,
    speed: source.groundSpeedMps ?? 0,
    heading: source.headingDeg ?? 0,
    battery: (source.batteryRemaining ?? 0).clamp(0, 100).toDouble(),
    gpsCount: bestSats,
    gpsFixLabel: FcTelemetry.fixLabelFor(fixType),
    hasGpsFix: hasFix,
    mode: CopterMode.label(source.customMode),
    armed: source.armed,
  );
}

int _bestFixType(int? a, int? b) {
  final left = a ?? 0;
  final right = b ?? 0;
  return left > right ? left : right;
}
