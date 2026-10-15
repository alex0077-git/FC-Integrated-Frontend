import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/mavlink/payload_buffer.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

void main() {
  test('K++ secondary SYS_STATUS bits detect GPS, compass and gyro', () {
    // Live banner flags: 0x004A001A = GPS2 | MAG2 | GYRO2 | accel | baro | diff
    final telemetry = const FcTelemetry().apply(
      const SysStatus(
        sensorsPresent: 0x004A001A,
        sensorsEnabled: 0x48313610,
        sensorsHealth: 0x5348364B,
        load: 0,
        voltageMillivolts: 48000,
        currentCentiamps: 0,
        batteryRemaining: 80,
      ),
    );

    expect(telemetry.sensorsPresent & FcSensor.gps.bit, 0);
    expect(telemetry.sensorsPresent & FcSensor.compass.bit, 0);
    expect(telemetry.sensorsPresent & FcSensor.gyro.bit, 0);
    // GPS2/MAG2 present bits alone are not enough — puck unplugged ⇒ both off.
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
    expect(telemetry.healthOf(FcSensor.compass), SensorHealth.notConnected);
    expect(telemetry.healthOf(FcSensor.gyro), SensorHealth.healthy);
    expect(telemetry.healthOf(FcSensor.accelerometer), SensorHealth.healthy);
    expect(telemetry.healthOf(FcSensor.barometer), SensorHealth.healthy);
  });

  test('GPS unplugged stays Not connected even if GPS2 present bit is set', () {
    final telemetry = const FcTelemetry(sensorsPresent: FcSensor.gps2Bit);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
  });

  test('GPS fix type 0 with zero sats is Not connected', () {
    final telemetry = const FcTelemetry(
      sensorsPresent: FcSensor.gps2Bit,
      gpsFixType: 0,
      satellites: 0,
      gps2FixType: 0,
      gps2Satellites: 0,
    );
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
  });

  test('GLOBAL_POSITION_INT at 0,0 does not invent a GPS fix or Normal', () {
    final telemetry = const FcTelemetry().apply(
      const GlobalPositionInt(
        latE7: 0,
        lonE7: 0,
        altMm: -17000,
        relativeAltMm: -1900,
        vx: 0,
        vy: 0,
        vz: 0,
        hdgCdeg: 0,
      ),
    );

    expect(telemetry.gpsFixType, isNull);
    expect(telemetry.latDeg, isNull);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
  });

  test('live lat/lon means GPS connected; compass still needs mag + GPS', () {
    final withPosition = const FcTelemetry(
      latDeg: 12.9716,
      lonDeg: 77.5946,
    );
    expect(withPosition.healthOf(FcSensor.gps), SensorHealth.healthy);
    expect(withPosition.healthOf(FcSensor.compass), SensorHealth.notConnected);

    final withMag = const FcTelemetry(
      latDeg: 12.9716,
      lonDeg: 77.5946,
      sensorsPresent: FcSensor.gps2Bit | FcSensor.mag2Bit,
      imus: [
        ImuReading(acc: [0, 0, -1000], gyro: [0, 0, 0], mag: [210, -35, 410]),
        null,
        null,
      ],
    );
    expect(withMag.healthOf(FcSensor.gps), SensorHealth.healthy);
    expect(withMag.healthOf(FcSensor.compass), SensorHealth.healthy);
  });

  test('msgid 203 with real position marks GPS Normal; fix stays No data', () {
    final telemetry = const FcTelemetry().apply(
      const KppGpsPosition(latE7: 100558451, lonE7: 763549900, altMm: -2500),
    );
    expect(telemetry.latDeg, isNotNull);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
    // Coords alone are not a fake fix enum.
    expect(telemetry.gpsFixLabel, 'No data');
  });

  test('msgid 203 with 0,0 alone is Not connected (same zeros when unplugged)', () {
    final telemetry = const FcTelemetry().apply(
      const KppGpsPosition(latE7: 0, lonE7: 0, altMm: -2500),
    );

    expect(telemetry.latDeg, isNull);
    expect(telemetry.gpsAgriLinked, isFalse);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
  });

  test('GLOBAL_POSITION with coords does not invent a fix label', () {
    final telemetry = const FcTelemetry().apply(
      const GlobalPositionInt(
        latE7: 100554956,
        lonE7: 763549000,
        altMm: 0,
        relativeAltMm: 0,
        vx: 0,
        vy: 0,
        vz: 0,
        hdgCdeg: 0,
      ),
    );
    expect(telemetry.latDeg, closeTo(10.0554956, 1e-7));
    expect(telemetry.gpsFixLabel, 'No data');
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
  });

  test('GPS_STATUS does not invent sats or 3D fix', () {
    final telemetry = const FcTelemetry()
        .apply(
          const GlobalPositionInt(
            latE7: 100554956,
            lonE7: 763549000,
            altMm: 0,
            relativeAltMm: 0,
            vx: 0,
            vy: 0,
            vz: 0,
            hdgCdeg: 0,
          ),
        )
        .apply(const GpsStatus(satellitesVisible: 16));
    expect(telemetry.satellites, isNull);
    expect(telemetry.gpsFixLabel, 'No data');
  });

  test('RAW with 0 sats does not stick as 0 sats', () {
    var telemetry = const FcTelemetry().apply(
      const GlobalPositionInt(
        latE7: 100554956,
        lonE7: 763549000,
        altMm: 0,
        relativeAltMm: 0,
        vx: 0,
        vy: 0,
        vz: 0,
        hdgCdeg: 0,
      ),
    );
    expect(telemetry.gpsFixLabel, 'No data');

    telemetry = telemetry.apply(
      const GpsRawInt(latE7: 0, lonE7: 0, altMm: 0, eph: 0xFFFF, fixType: 3, satellites: 0),
    );
    expect(telemetry.gpsFixLabel, 'No data');
    expect(telemetry.satellites, isNull);
  });

  test('206 publishes quality grade while keeping live lat/lon (not sat count)', () {
    final telemetry = const FcTelemetry()
        .apply(
          const GlobalPositionInt(
            latE7: 100554956,
            lonE7: 763549000,
            altMm: 0,
            relativeAltMm: 0,
            vx: 0,
            vy: 0,
            vz: 0,
            hdgCdeg: 0,
          ),
        )
        .apply(const KppGpsStatus(fixType: 0, satellites: 3));

    expect(telemetry.latDeg, isNotNull);
    expect(telemetry.gpsQuality, 3);
    expect(telemetry.satellites, isNull);
    expect(telemetry.gpsFixType, isNull);
    expect(telemetry.gpsQualityLabel, 'Poor');
    expect(telemetry.gpsAgriLinked, isTrue);
  });

  test('live 206 sets quality without wiping RAW sat count; keeps lat/lon', () {
    var telemetry = const FcTelemetry().apply(
      const GpsRawInt(
        latE7: 129716000,
        lonE7: 775946000,
        altMm: 920000,
        eph: 80,
        fixType: 3,
        satellites: 14,
      ),
    );
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);

    telemetry = telemetry
        .apply(const KppGpsStatus(fixType: 0, satellites: 4))
        .apply(
          const GlobalPositionInt(
            latE7: 0,
            lonE7: 0,
            altMm: -17000,
            relativeAltMm: -1900,
            vx: 0,
            vy: 0,
            vz: 0,
            hdgCdeg: 0,
          ),
        );

    expect(telemetry.gpsQuality, 4);
    expect(telemetry.satellites, 14);
    expect(telemetry.gps2Satellites, isNull);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
    expect(telemetry.latDeg, closeTo(12.9716, 1e-6));
    expect(telemetry.lonDeg, closeTo(77.5946, 1e-6));
  });

  test('206 quality does not clear GPS2_RAW slots', () {
    var telemetry = const FcTelemetry().apply(
      const Gps2Raw(latE7: 100558451, lonE7: 763549900, altMm: 920000, eph: 90, fixType: 3, satellites: 16),
    );
    telemetry = telemetry.apply(
      const KppGpsStatus(fixType: 0, satellites: 4),
    );

    expect(telemetry.gpsQuality, 4);
    expect(telemetry.gps2Satellites, 16);
    expect(telemetry.gps2FixType, 3);
  });

  test('plugged 206 shows quality grade from byte[2] (not sat count)', () {
    // Wire 000104020101 → quality=4
    final bytes = Uint8List.fromList([0, 1, 4, 2, 1, 1]);
    final msg = KppGpsStatus.messageSpec.decode(
      PayloadReader(bytes, KppGpsStatus.messageSpec.fullLength),
    ) as KppGpsStatus;
    expect(msg.quality, 4);
    expect(msg.fixType, 0);
    final plugged = const FcTelemetry().apply(msg);
    expect(plugged.gpsAgriLinked, isTrue);
    expect(plugged.healthOf(FcSensor.gps), SensorHealth.healthy);
    expect(plugged.gpsQuality, 4);
    expect(plugged.satellites, isNull);
    expect(plugged.gpsQualityLabel, 'Good');
  });

  test('unplugged 206 stub 00-01-00-00-01-01 is Not connected', () {
    final bytes = Uint8List.fromList([0, 1, 0, 0, 1, 1]);
    final msg = KppGpsStatus.messageSpec.decode(
      PayloadReader(bytes, KppGpsStatus.messageSpec.fullLength),
    ) as KppGpsStatus;
    expect(msg.fixType, 0);
    expect(msg.satellites, 0);

    final telemetry = const FcTelemetry(
      gpsAgriLinked: true,
      latDeg: 12.97,
      lonDeg: 77.59,
      satellites: 14,
      gpsFixType: 3,
    ).apply(msg);
    expect(telemetry.gpsAgriLinked, isFalse);
    expect(telemetry.latDeg, isNull);
    expect(telemetry.satellites, isNull);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
  });

  test('plug then unplug toggles GPS Normal ↔ Not connected with quality', () {
    var telemetry = const FcTelemetry().apply(
      const KppGpsStatus(fixType: 0, satellites: 3),
    );
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
    expect(telemetry.gpsQuality, 3);

    telemetry = telemetry.apply(
      const KppGpsStatus(fixType: 0, satellites: 0),
    );
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
    expect(telemetry.gpsQuality, 0);

    telemetry = telemetry.apply(
      const KppGpsStatus(fixType: 0, satellites: 2),
    );
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
    expect(telemetry.gpsQuality, 2);
  });

  test('wire 206 00-01-01-03-01-01 is quality=1 (not sat count)', () {
    final bytes = Uint8List.fromList([0, 1, 1, 3, 1, 1]);
    final msg = KppGpsStatus.messageSpec.decode(
      PayloadReader(bytes, KppGpsStatus.messageSpec.fullLength),
    ) as KppGpsStatus;
    expect(msg.quality, 1);
    final telemetry = const FcTelemetry().apply(msg);
    expect(telemetry.gpsQuality, 1);
    expect(telemetry.satellites, isNull);
    expect(telemetry.gpsQualityLabel, 'No fix');
  });

  test('K++ msgid 203 sets exact location with 206 quality grade', () {
    final telemetry = const FcTelemetry()
        .apply(const KppGpsStatus(fixType: 0, satellites: 4))
        .apply(const KppGpsPosition(latE7: 100558451, lonE7: 763549900, altMm: -2500));

    expect(telemetry.gpsQuality, 4);
    expect(telemetry.satellites, isNull);
    expect(telemetry.gpsFixLabel, 'No data');
    expect(telemetry.gps2FixLabel, 'No data');
    expect(telemetry.gpsQualityLabel, 'Good');
    expect(telemetry.latDeg, closeTo(10.0558451, 1e-7));
    expect(telemetry.lonDeg, closeTo(76.35499, 1e-5));
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
  });

  test('outdoor RAW with 3 sats shows GPS Normal (not Not connected)', () {
    final telemetry = const FcTelemetry().apply(
      const GpsRawInt(
        latE7: 100558451,
        lonE7: 763549900,
        altMm: 920000,
        eph: 120,
        fixType: 3,
        satellites: 3,
      ),
    );

    expect(telemetry.gpsFixType, 3);
    expect(telemetry.satellites, 3);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
    expect(telemetry.latDeg, isNotNull);
  });

  test('3D fix with sats but zero lat/lon still marks GPS connected', () {
    final telemetry = const FcTelemetry().apply(
      const Gps2Raw(
        latE7: 0,
        lonE7: 0,
        altMm: 0,
        eph: 0xFFFF,
        fixType: 3,
        satellites: 5,
      ),
    );

    expect(telemetry.gps2FixType, 3);
    expect(telemetry.gps2Satellites, 5);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
  });

  test('msgid 203 sat tail ignored until wire capture proves layout', () {
    final telemetry = const FcTelemetry().apply(
      const KppGpsPosition(
        latE7: 100558451,
        lonE7: 763549900,
        altMm: -2500,
        status: 1,
        fixType: 3,
        satellites: 14,
        fixType2: 6,
        satellites2: 18,
      ),
    );

    expect(telemetry.latDeg, closeTo(10.0558451, 1e-7));
    expect(telemetry.gpsFixLabel, 'No data');
    expect(telemetry.satellites, isNull);
    expect(telemetry.gps2Satellites, isNull);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
  });

  test('position does not blink when 203 is followed by 0,0 GLOBAL or dead RAW', () {
    var telemetry = const FcTelemetry()
        .apply(const KppGpsStatus(fixType: 0, satellites: 4))
        .apply(const KppGpsPosition(latE7: 100558451, lonE7: 763549900, altMm: -2500));

    telemetry = telemetry.apply(
      const GlobalPositionInt(
        latE7: 0,
        lonE7: 0,
        altMm: 0,
        relativeAltMm: -2500,
        vx: 0,
        vy: 0,
        vz: 0,
        hdgCdeg: 0,
      ),
    );
    expect(telemetry.latDeg, closeTo(10.0558451, 1e-7));
    expect(telemetry.gpsQuality, 4);

    telemetry = telemetry.apply(
      const Gps2Raw(latE7: 0, lonE7: 0, altMm: 0, eph: 0xFFFF, fixType: 2, satellites: 1),
    );
    expect(telemetry.latDeg, closeTo(10.0558451, 1e-7));
    expect(telemetry.lonDeg, closeTo(76.35499, 1e-5));
    // Impossible 2D·1 RAW must not stick into GPS2 slots.
    expect(telemetry.gps2FixType, isNull);
    expect(telemetry.gps2Satellites, isNull);
  });

  test('plugged searching 206 stays Normal with quality and 0,0 GLOBAL', () {
    final telemetry = const FcTelemetry()
        .apply(const KppGpsStatus(fixType: 0, satellites: 3))
        .apply(
          const GlobalPositionInt(
            latE7: 0,
            lonE7: 0,
            altMm: -17000,
            relativeAltMm: -1900,
            vx: 0,
            vy: 0,
            vz: 0,
            hdgCdeg: 0,
          ),
        );

    expect(telemetry.gpsQuality, 3);
    expect(telemetry.satellites, isNull);
    expect(telemetry.gpsAgriLinked, isTrue);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
  });

  test('unplugged 206 quality=0 stays Not connected', () {
    final live = const FcTelemetry().apply(
      const KppGpsStatus(fixType: 0, satellites: 4),
    );
    expect(live.gpsAgriLinked, isTrue);
    expect(live.gpsQuality, 4);

    final dead = const FcTelemetry().apply(
      const KppGpsStatus(fixType: 0, satellites: 0),
    );
    expect(dead.gpsAgriLinked, isFalse);
    expect(dead.healthOf(FcSensor.gps), SensorHealth.notConnected);
  });

  test('compass follows GPS puck — mag samples alone are not Normal', () {
    final telemetry = const FcTelemetry(
      imus: [
        ImuReading(acc: [0, 0, -1000], gyro: [0, 0, 0], mag: [210, -35, 410]),
        null,
        null,
      ],
    );

    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
    expect(telemetry.healthOf(FcSensor.compass), SensorHealth.notConnected);
  });

  test('compass is Normal only when GPS puck is present and mag reports', () {
    final telemetry = const FcTelemetry(
      gpsFixType: 1,
      satellites: 6,
      imus: [
        ImuReading(acc: [0, 0, -1000], gyro: [0, 0, 0], mag: [210, -35, 410]),
        null,
        null,
      ],
    );

    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
    expect(telemetry.healthOf(FcSensor.compass), SensorHealth.healthy);
  });

  test('GPS_RAW_INT fills fix label and satellite count', () {
    final telemetry = const FcTelemetry().apply(
      const GpsRawInt(latE7: 129716000, lonE7: 775946000, altMm: 920000, eph: 80, fixType: 3, satellites: 14),
    );

    expect(telemetry.gpsFixLabel, '3D fix');
    expect(telemetry.satellites, 14);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
  });

  test('no-fix GPS with enough sats is Normal', () {
    final telemetry = const FcTelemetry(
      sensorsPresent: FcSensor.gps2Bit,
      gpsFixType: 1,
      satellites: 6,
    );

    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
    expect(telemetry.gpsFixLabel, 'No fix');
  });

  test('no-fix GPS with zero sats is Not connected', () {
    final telemetry = const FcTelemetry(
      sensorsPresent: FcSensor.gps2Bit,
      gpsFixType: 1,
      satellites: 0,
    );

    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
    expect(telemetry.gpsFixLabel, 'No fix');
  });

  test('2D fix with sats is Normal', () {
    final telemetry = const FcTelemetry(gpsFixType: 2, satellites: 2);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.healthy);
  });

  test('fix enum alone without sats is Not connected', () {
    final telemetry = const FcTelemetry(gpsFixType: 3);
    expect(telemetry.healthOf(FcSensor.gps), SensorHealth.notConnected);
  });

  test('GPS2_RAW updates GPS2 slots only (agri puck)', () {
    final telemetry = const FcTelemetry().apply(
      const Gps2Raw(latE7: 129716000, lonE7: 775946000, altMm: 920000, eph: 120, fixType: 6, satellites: 18),
    );

    expect(telemetry.gps2FixLabel, 'RTK fixed');
    expect(telemetry.gps2Satellites, 18);
    expect(telemetry.satellites, isNull);
    expect(telemetry.gpsFixType, isNull);
    expect(telemetry.latDeg, closeTo(12.9716, 1e-6));
  });

  test('GPS2_RAW does not overwrite a good GPS1 count', () {
    var telemetry = const FcTelemetry().apply(
      const GpsRawInt(latE7: 129716000, lonE7: 775946000, altMm: 920000, eph: 80, fixType: 3, satellites: 14),
    );
    telemetry = telemetry.apply(
      const Gps2Raw(latE7: 129716100, lonE7: 775946100, altMm: 921000, eph: 120, fixType: 6, satellites: 18),
    );

    expect(telemetry.satellites, 14);
    expect(telemetry.gpsFixType, 3);
    expect(telemetry.gps2Satellites, 18);
    expect(telemetry.gps2FixType, 6);
  });
}
