import 'package:fc_frontend/data/models/telemetry.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

/// Maps K++ [FcTelemetry] into the FC frontend [Telemetry] model.
Telemetry mapFcTelemetry(FcTelemetry source) {
  // Prefer live msgid-207 sats; fall back to RAW GPS1/GPS2 counts.
  final liveSats = source.displaySatellites;
  final sats1 = source.satellites ?? 0;
  final sats2 = source.gps2Satellites ?? 0;
  final bestRawSats = sats1 > sats2 ? sats1 : sats2;
  final bestSats = liveSats ?? bestRawSats;

  final fixType = _bestFixType(source.gpsFixType, source.gps2FixType);
  final quality = source.gpsQuality;

  // K++ agri pucks often omit GPS_RAW (24/124), so fixType stays 0/"No fix"
  // even when msgid 206 quality is Good and 207 reports 15+ sats. Prefer the
  // observed quality label in that case (same scale as Fuselage Status).
  final gpsFixLabel = fixType >= 2
      ? FcTelemetry.fixLabelFor(fixType)
      : (quality != null
          ? FcTelemetry.observedQualityLabel(quality)
          : FcTelemetry.fixLabelFor(fixType));

  final qualityOk = quality != null && quality >= 4;
  final hasFix = (fixType >= 3 || qualityOk) &&
      bestSats >= 6 &&
      source.latDeg != null &&
      source.lonDeg != null;

  final remaining = source.batteryRemaining;
  final remainingOk = remaining != null && remaining >= 0 && remaining <= 100;

  return Telemetry(
    // Keep last known / zero only when no coordinates yet — UI hides marker if !hasFix.
    latitude: source.latDeg ?? 0,
    longitude: source.lonDeg ?? 0,
    altitude: source.altMeters ?? 0,
    speed: source.groundSpeedMps ?? 0,
    heading: source.headingDeg ?? 0,
    // Do not map unknown (−1) or missing remaining to 0% — that falsely shows critical.
    battery: remainingOk ? remaining.toDouble() : null,
    batteryVoltage: source.voltage,
    batteryRemainingRaw: remainingOk ? remaining : null,
    gpsCount: bestSats,
    gpsFixLabel: gpsFixLabel,
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
