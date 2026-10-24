import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/session/spray_telem.dart';

/// UI colour for observed GPS quality grades (206[2] / 207[65]).
enum GpsQualityTone { grey, amber, green, blue }

/// SYS_STATUS sensor bits shown on the K++ status page.
///
/// K++ often sets the *secondary* IMU/GPS bits (GYRO2 / MAG2 / GPS2) and leaves
/// the primary bits clear — the same pattern JIYI's assistant uses.
enum FcSensor {
  gyro(1, 'Gyroscope'),
  accelerometer(2, 'Accelerometer'),
  compass(4, 'Compass'),
  barometer(8, 'Barometer'),
  gps(32, 'GPS');

  const FcSensor(this.bit, this.label);

  final int bit;
  final String label;

  static const int gyro2Bit = 0x20000;
  static const int accel2Bit = 0x40000;
  static const int mag2Bit = 0x80000;
  static const int gps2Bit = 0x400000;

  /// Primary bit plus the K++ secondary bit for this sensor, if any.
  int get presentMask => switch (this) {
    FcSensor.gyro => bit | gyro2Bit,
    FcSensor.accelerometer => bit | accel2Bit,
    FcSensor.compass => bit | mag2Bit,
    FcSensor.gps => bit | gps2Bit,
    FcSensor.barometer => bit,
  };
}

enum SensorHealth { notConnected, healthy, fault }

class ImuReading {
  const ImuReading({required this.acc, required this.gyro, required this.mag});

  final List<int> acc;
  final List<int> gyro;
  final List<int> mag;
}

/// Latest live values from the flight controller.
class FcTelemetry {
  const FcTelemetry({
    this.voltage,
    this.batteryRemaining,
    this.sensorsPresent = 0,
    this.sensorsHealth = 0,
    this.gpsFixType,
    this.satellites,
    this.gps2FixType,
    this.gps2Satellites,
    this.gpsQuality,
    this.gpsSatsReceivedAt,
    this.gpsRawIntReceivedAt,
    this.gps2RawReceivedAt,
    this.hdop,
    this.latDeg,
    this.lonDeg,
    this.gpsAgriLinked = false,
    this.altMeters,
    this.groundSpeedMps,
    this.headingDeg,
    this.customMode,
    this.baseMode = 0,
    this.systemStatus,
    this.imus = const [null, null, null],
    this.pressureHpa,
    this.temperatureC,
    this.rcChannels = const [],
    this.rssi,
    this.lastStatusText,
    this.flowRateLpm,
    this.liquidLevelPercent,
    this.sprayedLiters,
    this.liquidValue,
  });

  static const Duration gpsSatsStaleAfter = Duration(seconds: 3);
  static const Duration standardGpsDetailFreshFor = Duration(seconds: 5);

  static const int gpsFixRtkFloat = 5;
  static const int gpsFixRtkFixed = 6;
  static const int baseModeArmed = 128;

  /// Log 206[2] vs 207[65] disagreement at most once per process.
  static bool _loggedQualityMismatch = false;

  /// Test hook to re-arm the one-shot mismatch log.
  static void resetQualityMismatchLogForTest() => _loggedQualityMismatch = false;

  final double? voltage;
  final int? batteryRemaining;
  final int sensorsPresent;
  final int sensorsHealth;
  final int? gpsFixType;
  /// Satellites from msgid 207[73] (0 = no fix yet). Null if never received / cleared.
  final int? satellites;
  final int? gps2FixType;
  final int? gps2Satellites;
  /// Quality grade from msgid 206[2] (fallback 207[65]).
  final int? gpsQuality;
  /// When [satellites] was last set from a valid 75-byte msgid 207.
  final DateTime? gpsSatsReceivedAt;
  /// Last msgid 24 (GPS_RAW_INT) frame time — for Status GPS1/HDOP tiles.
  final DateTime? gpsRawIntReceivedAt;
  /// Last msgid 124 (GPS2_RAW) frame time — for Status GPS2 tiles.
  final DateTime? gps2RawReceivedAt;
  final double? hdop;
  final double? latDeg;
  final double? lonDeg;

  /// True while msgid 206 reports a live (plugged) GPS module.
  /// Cleared on the unplugged stub `00 01 00 00 01 01`.
  final bool gpsAgriLinked;
  final double? altMeters;
  final double? groundSpeedMps;
  final double? headingDeg;
  final int? customMode;
  final int baseMode;
  final int? systemStatus;
  final List<ImuReading?> imus;
  final double? pressureHpa;
  final double? temperatureC;
  final List<int> rcChannels;
  final int? rssi;
  final String? lastStatusText;

  /// Flow meter on K1 (L/min), when the FC reports it.
  final double? flowRateLpm;

  /// Level sensor reading (0–100), when reported.
  final double? liquidLevelPercent;

  /// Cumulative sprayed volume (L), when reported.
  final double? sprayedLiters;

  /// Raw JIYI-style liquidValue (flow or level).
  final double? liquidValue;

  bool get armed => baseMode & baseModeArmed != 0;

  /// True when any spray / liquid reading is present.
  bool get hasSprayTelem =>
      flowRateLpm != null || liquidLevelPercent != null || sprayedLiters != null || liquidValue != null;

  SensorHealth healthOf(FcSensor sensor) {
    if (sensor == FcSensor.gps) {
      return _gpsModuleHealth();
    }
    // On K++ the magnetometer lives in the GPS puck — if GPS is unplugged,
    // compass must not stay "Normal" from a stale MAG2 present bit.
    if (sensor == FcSensor.compass) {
      return _compassModuleHealth();
    }
    final present =
        sensorsPresent & sensor.presentMask != 0 || _telemetryIndicatesPresent(sensor);
    if (!present) {
      return SensorHealth.notConnected;
    }
    // K++ secondary-bit health flags are unreliable (e.g. GYRO2 present with
    // health clear). Presence / live samples mean the module is connected.
    return SensorHealth.healthy;
  }

  SensorHealth _compassModuleHealth() {
    // Compass is in the GPS puck — never Normal while GPS is Not connected.
    if (_gpsModuleHealth() != SensorHealth.healthy) {
      return SensorHealth.notConnected;
    }
    final present =
        sensorsPresent & FcSensor.compass.presentMask != 0 ||
        _telemetryIndicatesPresent(FcSensor.compass);
    return present ? SensorHealth.healthy : SensorHealth.notConnected;
  }

  /// Minimum satellites before a no-lock RAW / GPS_STATUS counts as present.
  static const int _gpsPresentMinSats = 4;

  /// GPS Overview: Normal only while the puck looks plugged; Not connected
  /// when it is removed. SYS_STATUS GPS2 bits stay set either way on K++ —
  /// we use msgid 206 live vs dead stub (proven on USB captures).
  SensorHealth _gpsModuleHealth() {
    if (gpsAgriLinked) {
      return SensorHealth.healthy;
    }
    if (latDeg != null && lonDeg != null) {
      return SensorHealth.healthy;
    }
    final bestFix = _maxInt(gpsFixType, gps2FixType);
    final bestSats = _maxInt(satellites, gps2Satellites);
    if (bestFix >= 2 && bestSats > 0) {
      return SensorHealth.healthy;
    }
    if (bestSats >= _gpsPresentMinSats) {
      return SensorHealth.healthy;
    }

    return SensorHealth.notConnected;
  }

  /// Plug/unplug: msgid 206 quality grade (byte[2]) > 0.
  static bool _kppGpsStatusIndicatesConnected(KppGpsStatus message) {
    return message.quality > 0;
  }

  static int _maxInt(int? a, int? b) {
    final left = a ?? 0;
    final right = b ?? 0;
    return left > right ? left : right;
  }

  static int? _nonZeroSats(int? sats) => (sats == null || sats == 0) ? null : sats;

  /// RAW GPS update for fix/sats/HDOP. Coords update only on a live lock.
  ///
  /// [gps2] writes GPS2_RAW into the GPS2 slots. K++ agri pucks usually report
  /// on GPS2 — never overwrite GPS1 sats with GPS2 (or the reverse).
  ///
  /// Never clear lat/lon on a dead/zero RAW frame — K++ interleaves 0,0 RAW with
  /// a good msgid 203, which used to make Overview Position blink.
  FcTelemetry _applyGpsRaw({
    required int fixType,
    required int sats,
    required int eph,
    required int latE7,
    required int lonE7,
    required int altMm,
    bool gps2 = false,
  }) {
    final valid = _validLatLon(latE7, lonE7);
    final looksLive = fixType >= 2
        ? sats > 0
        : fixType >= 1 && sats >= _gpsPresentMinSats;
    final useCoords = valid && looksLive;
    // Store standard GPS_RAW_* when it looks live. Old rule (≥4 sats for any
    // fix≥2) hid outdoor 3D locks with 2–3 sats → Status GPS "Not connected".
    // Still reject impossible 2D·1 and empty 3D·0 (interleaved dead RAW).
    final storeFixSats = sats > 0 &&
        sats <= 40 &&
        fixType >= 1 &&
        fixType <= 8 &&
        (fixType >= 3 ||
            (fixType == 2 && sats >= 4) ||
            (fixType == 1 && sats >= _gpsPresentMinSats));
    return _copy(
      gpsFixType: gps2 ? null : (storeFixSats ? fixType : null),
      satellites: gps2 ? null : (storeFixSats ? sats : null),
      gps2FixType: gps2 ? (storeFixSats ? fixType : null) : null,
      gps2Satellites: gps2 ? (storeFixSats ? sats : null) : null,
      hdop: eph == 0xFFFF ? null : eph / 100,
      // null lat/lon here means "keep previous" in _copy (do not clear).
      latDeg: useCoords ? latE7 / 1e7 : null,
      lonDeg: useCoords ? lonE7 / 1e7 : null,
      altMeters: altMm / 1000,
      gpsAgriLinked: storeFixSats || useCoords || gpsAgriLinked,
      gpsRawIntReceivedAt: gps2 ? null : DateTime.now(),
      gps2RawReceivedAt: gps2 ? DateTime.now() : null,
      setGpsRawIntReceivedAt: !gps2,
      setGps2RawReceivedAt: gps2,
    );
  }

  FcTelemetry _applyKppGpsStatus(KppGpsStatus message) {
    // msgid 206[2] is quality grade — never a satellite count.
    if (!_kppGpsStatusIndicatesConnected(message)) {
      return _copy(
        gpsAgriLinked: false,
        clearLatLon: true,
        clearGpsSlots: true,
        clearGpsSatsReceivedAt: true,
        gpsQuality: 0,
      );
    }
    return _copy(
      gpsQuality: message.quality,
      gpsAgriLinked: true,
    );
  }

  FcTelemetry _applyKppGpsDetail(KppGpsDetail message) {
    // Satellites = unsigned 207[73]. Prefer quality from 206[2]; fallback 207[65].
    final from206 = gpsQuality;
    final from207 = message.gpsState;
    if (from206 != null && from206 != from207 && !_loggedQualityMismatch) {
      _loggedQualityMismatch = true;
      developer.log(
        'GPS quality mismatch: 206[2]=$from206 vs 207[65]=$from207 (using 206)',
        name: 'FcTelemetry',
      );
    }
    return _copy(
      setSatellites: true,
      satellites: message.gpsSats,
      gpsSatsReceivedAt: DateTime.now(),
      gpsQuality: from206 ?? from207,
      gpsAgriLinked: true,
    );
  }

  /// msgid 203: real lat/lon ⇒ connected. All-zero 203 is sent while
  /// unplugged too — do not treat zeros as a plug event (206 decides that).
  FcTelemetry _applyKppGpsPosition(KppGpsPosition message) {
    final next = _applyPositionOnly(
      latE7: message.latE7,
      lonE7: message.lonE7,
      altMeters: message.altMm / 1000,
    );
    if (_validLatLon(message.latE7, message.lonE7)) {
      return next._copy(gpsAgriLinked: true);
    }
    return next;
  }

  FcTelemetry _applyPositionOnly({
    required int latE7,
    required int lonE7,
    required double altMeters,
  }) {
    if (!_validLatLon(latE7, lonE7)) {
      // Hold last good fix (do not clear).
      return _copy(altMeters: altMeters);
    }
    return _withLivePositionFix(
      _copy(
        latDeg: latE7 / 1e7,
        lonDeg: lonE7 / 1e7,
        altMeters: altMeters,
      ),
    );
  }

  /// Keep coords only — do not invent a fake 3D/DGPS enum (caused "3D · 0 sats").
  FcTelemetry _withLivePositionFix(FcTelemetry next) => next;

  FcTelemetry _applyGlobalPosition(GlobalPositionInt message) {
    final heading =
        message.hdgCdeg == 65535 ? headingDeg : message.hdgCdeg / 100;
    final speed = _groundSpeedMps(message.vx, message.vy);
    final alt = message.relativeAltMm / 1000;
    if (!_validLatLon(message.latE7, message.lonE7)) {
      // Keep last lat/lon — FC often sends 0,0 GLOBAL between good 203 frames.
      return _copy(
        altMeters: alt,
        groundSpeedMps: speed,
        headingDeg: heading,
      );
    }
    return _withLivePositionFix(
      _copy(
        latDeg: message.latE7 / 1e7,
        lonDeg: message.lonE7 / 1e7,
        altMeters: alt,
        groundSpeedMps: speed,
        headingDeg: heading,
      ),
    );
  }

  FcTelemetry _applyGpsStatus(GpsStatus message) {
    // K++ agri path uses msgid 206 for sats. Do not invent a 3D fix or
    // overwrite the exact 206 count from GPS_STATUS.
    return this;
  }

  bool _telemetryIndicatesPresent(FcSensor sensor) {
    return switch (sensor) {
      FcSensor.gps => _gpsModuleHealth() == SensorHealth.healthy,
      FcSensor.compass => imus.any((imu) => imu != null && imu.mag.any((v) => v != 0)),
      FcSensor.gyro => imus.any((imu) => imu != null),
      FcSensor.accelerometer => imus.any((imu) => imu != null),
      FcSensor.barometer => pressureHpa != null,
    };
  }

  /// MAVLink uses 0,0 for “no position”; do not treat that as a valid fix.
  static bool _validLatLon(int latE7, int lonE7) => latE7 != 0 || lonE7 != 0;

  /// Fix only from GPS_RAW / GPS2_RAW — never invented from msgid 206.
  String get gpsFixLabel => fixLabelFor(gpsFixType);

  String get gps2FixLabel => fixLabelFor(gps2FixType);

  /// UI satellites from 207[73]; null → show "—" (stale / never received).
  /// 0 is a real value (no fix yet).
  int? get displaySatellites {
    final at = gpsSatsReceivedAt;
    if (at == null || satellites == null) {
      return null;
    }
    if (DateTime.now().difference(at) > gpsSatsStaleAfter) {
      return null;
    }
    return satellites;
  }

  /// Best live sat count for arming / mission bar (respects 3s stale).
  int get gpsSatelliteCount {
    final live = displaySatellites;
    if (live != null) {
      return live;
    }
    return _maxInt(null, gps2Satellites);
  }

  /// Observed quality text from official-app pre-start messages (not a documented protocol).
  ///
  /// Scale: 0 Not connected, 1 No fix, 2/3 Poor, 4 Good, 5 RTK.
  static String observedQualityLabel(int? quality) {
    // Labels observed from the official app's pre-start messages (read from its
    // code) — observed, not a documented protocol.
    return switch (quality) {
      0 => 'Not connected',
      1 => 'No fix',
      2 || 3 => 'Poor',
      4 => 'Good',
      5 => 'RTK',
      _ => '—',
    };
  }

  /// Colour tone for [observedQualityLabel]: 0/1 grey, 2/3 amber, 4 green, 5 blue.
  static GpsQualityTone observedQualityTone(int? quality) {
    // Colour mapping observed with the official app labels — observed, not a
    // documented protocol.
    return switch (quality) {
      2 || 3 => GpsQualityTone.amber,
      4 => GpsQualityTone.green,
      5 => GpsQualityTone.blue,
      _ => GpsQualityTone.grey, // null, 0, 1, unknown
    };
  }

  /// Quality grade label from 206[2] (fallback 207[65]).
  String get gpsQualityLabel => observedQualityLabel(gpsQuality);

  /// Combined UI string: `"Good - 14 sats"`, or `"—"` when 207 is stale / missing.
  String get gpsQualitySatsDisplay {
    final sats = displaySatellites;
    if (sats == null) {
      return '—';
    }
    return '${gpsQualityLabel} - $sats sats';
  }

  /// Tone for [gpsQualitySatsDisplay]; grey when satellites are stale.
  GpsQualityTone get gpsQualityDisplayTone {
    if (displaySatellites == null) {
      return GpsQualityTone.grey;
    }
    return observedQualityTone(gpsQuality);
  }

  /// Status → Sensors → GPS value (observed quality scale; not SYS_STATUS "Normal").
  String get statusGpsSensorValue => gpsQualityLabel;

  /// Status → Sensors → GPS colour. Green only for grade 4; blue for 5.
  GpsQualityTone get statusGpsSensorTone => observedQualityTone(gpsQuality);

  /// Status Satellites tile: 207[73], or "—" when stale / missing.
  String get statusSatellitesValue {
    final sats = displaySatellites;
    return sats == null ? '—' : '$sats';
  }

  GpsQualityTone get statusSatellitesTone =>
      displaySatellites == null ? GpsQualityTone.grey : observedQualityTone(gpsQuality);

  /// Position is "live" only with quality ≥ 2 and a fresh msgid 207.
  bool get statusPositionLive {
    final q = gpsQuality ?? 0;
    return q >= 2 && displaySatellites != null;
  }

  /// Status Position tile text.
  String get statusPositionValue {
    if (statusPositionLive && latDeg != null && lonDeg != null) {
      return '${latDeg!.toStringAsFixed(7)}, ${lonDeg!.toStringAsFixed(7)}';
    }
    if (latDeg != null && lonDeg != null) {
      return 'last known: ${latDeg!.toStringAsFixed(7)}, ${lonDeg!.toStringAsFixed(7)}';
    }
    return 'No fix';
  }

  /// Green only when [statusPositionLive]; otherwise grey.
  GpsQualityTone get statusPositionTone =>
      statusPositionLive ? GpsQualityTone.green : GpsQualityTone.grey;

  /// True when msgid 24 or 124 arrived within [standardGpsDetailFreshFor].
  bool get hasFreshStandardGpsDetail {
    final now = DateTime.now();
    final raw1 = gpsRawIntReceivedAt;
    final raw2 = gps2RawReceivedAt;
    return (raw1 != null && now.difference(raw1) <= standardGpsDetailFreshFor) ||
        (raw2 != null && now.difference(raw2) <= standardGpsDetailFreshFor);
  }

  static String fixLabelFor(int? fixType) => switch (fixType) {
    null => 'No data',
    0 || 1 => 'No fix',
    2 => '2D fix',
    3 => '3D fix',
    4 => 'DGPS',
    gpsFixRtkFloat => 'RTK float',
    gpsFixRtkFixed => 'RTK fixed',
    _ => 'Fix type $fixType',
  };

  SensorHealth imuHealth(int index) {
    if (index < 0 || index >= imus.length || imus[index] == null) {
      return SensorHealth.notConnected;
    }
    return SensorHealth.healthy;
  }

  /// Applies one incoming message and returns the updated telemetry.
  FcTelemetry apply(MavMessage message) {
    return switch (message) {
      Heartbeat() => message.type == Heartbeat.typeGcs
          ? this
          : _copy(
              customMode: message.customMode,
              baseMode: message.baseMode,
              systemStatus: message.systemStatus,
            ),
      SysStatus() => _copy(
        // UINT16_MAX means voltage not available.
        voltage: message.voltageMillivolts >= 65535
            ? null
            : message.voltageMillivolts / 1000,
        // MAVLink: −1 = autopilot does not estimate remaining energy.
        // Keep an existing BATTERY_STATUS remaining when SYS_STATUS says unknown.
        batteryRemaining: message.batteryRemaining < 0 ? null : message.batteryRemaining,
        clearBatteryRemaining: message.batteryRemaining < 0 && batteryRemaining == null,
        keepVoltage: message.voltageMillivolts >= 65535,
        keepBatteryRemaining: message.batteryRemaining < 0 && batteryRemaining != null,
        sensorsPresent: message.sensorsPresent,
        sensorsHealth: message.sensorsHealth,
      ),
      BatteryStatus() => _copy(
        voltage: message.packVoltage,
        keepVoltage: message.packVoltage == null,
        batteryRemaining: message.batteryRemaining < 0 ? null : message.batteryRemaining,
        // −1 means unknown — do not wipe a valid remaining from SYS_STATUS.
        keepBatteryRemaining: message.batteryRemaining < 0,
        clearBatteryRemaining: false,
      ),
      GpsRawInt() => _applyGpsRaw(
        fixType: message.fixType,
        sats: message.satellites,
        eph: message.eph,
        latE7: message.latE7,
        lonE7: message.lonE7,
        altMm: message.altMm,
      ),
      GpsStatus() => _applyGpsStatus(message),
      // Agri GPS on K++ is typically GPS2 — keep it out of the GPS1 slots.
      Gps2Raw() => _applyGpsRaw(
        fixType: message.fixType,
        sats: message.satellites,
        eph: message.eph,
        latE7: message.latE7,
        lonE7: message.lonE7,
        altMm: message.altMm,
        gps2: true,
      ),
      KppGpsStatus() => _applyKppGpsStatus(message),
      KppGpsDetail() => _applyKppGpsDetail(message),
      KppGpsPosition() => _applyKppGpsPosition(message),
      GlobalPositionInt() => _applyGlobalPosition(message),
      ImuSample() => _copy(
        imus: [
          for (var i = 0; i < imus.length; i++)
            i == message.instance ? ImuReading(acc: message.acc, gyro: message.gyro, mag: message.mag) : imus[i],
        ],
      ),
      ScaledPressure() => _copy(pressureHpa: message.pressureHpa, temperatureC: message.temperatureCenti / 100),
      RcChannelsRaw() => _copy(rcChannels: _mergeRawPort(message), rssi: message.rssi),
      RcChannels() => _copy(rcChannels: message.channels, rssi: message.rssi),
      StatusText() => _applyStatusText(message),
      UnknownMavMessage() => _applyUnknownSpray(message),
      _ => this,
    };
  }

  FcTelemetry _applyStatusText(StatusText message) {
    final spray = SprayTelem.fromStatusText(message.text);
    return _copy(
      lastStatusText: message.text,
      flowRateLpm: spray?.flowRateLpm,
      liquidLevelPercent: spray?.liquidLevelPercent,
      sprayedLiters: spray?.sprayedLiters,
      liquidValue: spray?.liquidValue,
      keepSpray: spray == null,
    );
  }

  FcTelemetry _applyUnknownSpray(UnknownMavMessage message) {
    final spray = SprayTelem.fromUnknown(message);
    if (spray == null) {
      return this;
    }
    return _copy(
      flowRateLpm: spray.flowRateLpm,
      liquidLevelPercent: spray.liquidLevelPercent,
      sprayedLiters: spray.sprayedLiters,
      liquidValue: spray.liquidValue,
    );
  }

  static double _groundSpeedMps(int vxCms, int vyCms) {
    final vx = vxCms / 100.0;
    final vy = vyCms / 100.0;
    return math.sqrt(vx * vx + vy * vy);
  }

  /// RC_CHANNELS_RAW carries eight channels per port; place them at the
  /// right offset and keep the channels from the other port.
  List<int> _mergeRawPort(RcChannelsRaw message) {
    final first = message.port * RcChannelsRaw.channelsPerPort;
    final last = first + RcChannelsRaw.channelsPerPort;
    return List<int>.filled(last > rcChannels.length ? last : rcChannels.length, 0)
      ..setRange(0, rcChannels.length, rcChannels)
      ..setRange(first, last, message.channels);
  }

  FcTelemetry _copy({
    double? voltage,
    int? batteryRemaining,
    int? sensorsPresent,
    int? sensorsHealth,
    int? gpsFixType,
    int? satellites,
    int? gps2FixType,
    int? gps2Satellites,
    int? gpsQuality,
    DateTime? gpsSatsReceivedAt,
    DateTime? gpsRawIntReceivedAt,
    DateTime? gps2RawReceivedAt,
    double? hdop,
    double? latDeg,
    double? lonDeg,
    bool? gpsAgriLinked,
    bool clearLatLon = false,
    bool clearGpsSlots = false,
    bool clearGpsSatsReceivedAt = false,
    bool setSatellites = false,
    bool setGpsRawIntReceivedAt = false,
    bool setGps2RawReceivedAt = false,
    bool clearBatteryRemaining = false,
    bool keepVoltage = false,
    bool keepBatteryRemaining = false,
    double? altMeters,
    double? groundSpeedMps,
    double? headingDeg,
    int? customMode,
    int? baseMode,
    int? systemStatus,
    List<ImuReading?>? imus,
    double? pressureHpa,
    double? temperatureC,
    List<int>? rcChannels,
    int? rssi,
    String? lastStatusText,
    double? flowRateLpm,
    double? liquidLevelPercent,
    double? sprayedLiters,
    double? liquidValue,
    bool keepSpray = false,
  }) {
    return FcTelemetry(
      voltage: keepVoltage ? this.voltage : (voltage ?? this.voltage),
      batteryRemaining: keepBatteryRemaining
          ? this.batteryRemaining
          : clearBatteryRemaining
              ? null
              : (batteryRemaining ?? this.batteryRemaining),
      sensorsPresent: sensorsPresent ?? this.sensorsPresent,
      sensorsHealth: sensorsHealth ?? this.sensorsHealth,
      // clearGpsSlots = replace GPS slots with the values passed in (null clears).
      gpsFixType: clearGpsSlots ? gpsFixType : (gpsFixType ?? this.gpsFixType),
      // 207 may set satellites=0 (no fix). RAW still uses non-zero coerce unless setSatellites.
      satellites: clearGpsSlots
          ? (setSatellites ? satellites : null)
          : (setSatellites ? satellites : _nonZeroSats(satellites ?? this.satellites)),
      gps2FixType: clearGpsSlots ? gps2FixType : (gps2FixType ?? this.gps2FixType),
      gps2Satellites: clearGpsSlots
          ? _nonZeroSats(gps2Satellites)
          : _nonZeroSats(gps2Satellites ?? this.gps2Satellites),
      gpsQuality: clearGpsSlots && gpsQuality == null ? null : (gpsQuality ?? this.gpsQuality),
      gpsSatsReceivedAt: clearGpsSlots || clearGpsSatsReceivedAt
          ? (setSatellites ? gpsSatsReceivedAt : null)
          : (gpsSatsReceivedAt ?? this.gpsSatsReceivedAt),
      gpsRawIntReceivedAt: clearGpsSlots
          ? (setGpsRawIntReceivedAt ? gpsRawIntReceivedAt : null)
          : (setGpsRawIntReceivedAt ? gpsRawIntReceivedAt : this.gpsRawIntReceivedAt),
      gps2RawReceivedAt: clearGpsSlots
          ? (setGps2RawReceivedAt ? gps2RawReceivedAt : null)
          : (setGps2RawReceivedAt ? gps2RawReceivedAt : this.gps2RawReceivedAt),
      hdop: clearGpsSlots ? hdop : (hdop ?? this.hdop),
      latDeg: clearLatLon ? null : (latDeg ?? this.latDeg),
      lonDeg: clearLatLon ? null : (lonDeg ?? this.lonDeg),
      gpsAgriLinked: gpsAgriLinked ?? this.gpsAgriLinked,
      altMeters: altMeters ?? this.altMeters,
      groundSpeedMps: groundSpeedMps ?? this.groundSpeedMps,
      headingDeg: headingDeg ?? this.headingDeg,
      customMode: customMode ?? this.customMode,
      baseMode: baseMode ?? this.baseMode,
      systemStatus: systemStatus ?? this.systemStatus,
      imus: imus ?? this.imus,
      pressureHpa: pressureHpa ?? this.pressureHpa,
      temperatureC: temperatureC ?? this.temperatureC,
      rcChannels: rcChannels ?? this.rcChannels,
      rssi: rssi ?? this.rssi,
      lastStatusText: lastStatusText ?? this.lastStatusText,
      flowRateLpm: keepSpray ? this.flowRateLpm : (flowRateLpm ?? this.flowRateLpm),
      liquidLevelPercent:
          keepSpray ? this.liquidLevelPercent : (liquidLevelPercent ?? this.liquidLevelPercent),
      sprayedLiters: keepSpray ? this.sprayedLiters : (sprayedLiters ?? this.sprayedLiters),
      liquidValue: keepSpray ? this.liquidValue : (liquidValue ?? this.liquidValue),
    );
  }
}
