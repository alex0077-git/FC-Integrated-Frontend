import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

FcTelemetry _withQualityAndSats({
  required int quality,
  required int sats,
  DateTime? satsAt,
  double? latDeg,
  double? lonDeg,
}) {
  return FcTelemetry(
    gpsQuality: quality,
    satellites: sats,
    gpsSatsReceivedAt: satsAt ?? DateTime.now(),
    gpsAgriLinked: quality > 0,
    latDeg: latDeg,
    lonDeg: lonDeg,
  );
}

void main() {
  test('(206[2]=1, 207[73]=0) → No fix, grey, position not green', () {
    final t = _withQualityAndSats(quality: 1, sats: 0);
    expect(t.statusGpsSensorValue, 'No fix');
    expect(t.gpsQualityLabel, 'No fix');
    expect(t.statusGpsSensorTone, GpsQualityTone.grey);
    expect(t.statusSatellitesValue, '0');
    expect(t.statusPositionValue, 'No fix');
    expect(t.statusPositionLive, isFalse);
    expect(t.statusPositionTone, GpsQualityTone.grey);
  });

  test('(206[2]=2, 207[73]=8) → Poor, amber', () {
    final t = _withQualityAndSats(
      quality: 2,
      sats: 8,
      latDeg: 12.97,
      lonDeg: 77.59,
    );
    expect(t.statusGpsSensorValue, 'Poor');
    expect(t.gpsQualityLabel, 'Poor');
    expect(t.statusGpsSensorTone, GpsQualityTone.amber);
    expect(t.statusSatellitesValue, '8');
    expect(t.statusPositionLive, isTrue);
    expect(t.statusPositionTone, GpsQualityTone.green);
    expect(t.statusPositionValue, contains('12.97'));
  });

  test('(206[2]=4, 207[73]=14) → Good, green', () {
    final t = _withQualityAndSats(
      quality: 4,
      sats: 14,
      latDeg: 10.05,
      lonDeg: 76.35,
    );
    expect(t.statusGpsSensorValue, 'Good');
    expect(t.gpsQualityLabel, 'Good');
    expect(t.statusGpsSensorTone, GpsQualityTone.green);
    expect(t.statusSatellitesValue, '14');
    expect(t.statusPositionLive, isTrue);
    expect(t.statusPositionTone, GpsQualityTone.green);
  });

  test('fresh versus stale 207 for satellites and position', () {
    final fresh = _withQualityAndSats(
      quality: 4,
      sats: 14,
      latDeg: 10.0,
      lonDeg: 76.0,
    );
    expect(fresh.statusSatellitesValue, '14');
    expect(fresh.statusPositionLive, isTrue);

    final stale = FcTelemetry(
      gpsQuality: 4,
      satellites: 14,
      gpsSatsReceivedAt: DateTime.now().subtract(const Duration(seconds: 4)),
      gpsAgriLinked: true,
      latDeg: 10.0,
      lonDeg: 76.0,
    );
    expect(stale.statusSatellitesValue, '—');
    expect(stale.statusPositionLive, isFalse);
    expect(stale.statusPositionTone, GpsQualityTone.grey);
    expect(stale.statusPositionValue, startsWith('last known:'));
  });

  test('24/124 absent shows muted line (no fresh standard GPS detail)', () {
    final t = _withQualityAndSats(quality: 4, sats: 14);
    expect(t.hasFreshStandardGpsDetail, isFalse);
  });

  test('24 present shows standard GPS detail tiles', () {
    final t = const FcTelemetry().apply(
      const GpsRawInt(
        latE7: 129716000,
        lonE7: 775946000,
        altMm: 920000,
        eph: 80,
        fixType: 3,
        satellites: 14,
      ),
    );
    expect(t.hasFreshStandardGpsDetail, isTrue);
    expect(t.gpsRawIntReceivedAt, isNotNull);
    expect(t.gpsFixLabel, '3D fix');
  });

  test('124 alone is enough for standard GPS detail', () {
    final t = const FcTelemetry().apply(
      const Gps2Raw(
        latE7: 100558451,
        lonE7: 763549900,
        altMm: 920000,
        eph: 90,
        fixType: 3,
        satellites: 16,
      ),
    );
    expect(t.hasFreshStandardGpsDetail, isTrue);
    expect(t.gps2RawReceivedAt, isNotNull);
  });

  test('stale 24/124 (>5s) hides standard GPS detail', () {
    final t = FcTelemetry(
      gpsFixType: 3,
      satellites: 14,
      gpsRawIntReceivedAt: DateTime.now().subtract(const Duration(seconds: 6)),
      hdop: 0.8,
    );
    expect(t.hasFreshStandardGpsDetail, isFalse);
  });

  test('Normal green only for grade 4 or 5 on Sensors GPS', () {
    expect(_withQualityAndSats(quality: 3, sats: 9).statusGpsSensorTone, GpsQualityTone.amber);
    expect(_withQualityAndSats(quality: 4, sats: 14).statusGpsSensorTone, GpsQualityTone.green);
    expect(_withQualityAndSats(quality: 5, sats: 14).statusGpsSensorTone, GpsQualityTone.blue);
    expect(_withQualityAndSats(quality: 1, sats: 0).statusGpsSensorTone, GpsQualityTone.grey);
  });
}
