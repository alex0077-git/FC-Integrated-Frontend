import 'dart:math' as math;

import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';

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
    this.hdop,
    this.latDeg,
    this.lonDeg,
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
  });

  static const int gpsFixRtkFloat = 5;
  static const int gpsFixRtkFixed = 6;
  static const int baseModeArmed = 128;

  final double? voltage;
  final int? batteryRemaining;
  final int sensorsPresent;
  final int sensorsHealth;
  final int? gpsFixType;
  final int? satellites;
  final int? gps2FixType;
  final int? gps2Satellites;
  final double? hdop;
  final double? latDeg;
  final double? lonDeg;
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

  bool get armed => baseMode & baseModeArmed != 0;

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

  /// Minimum satellites before we treat a no-lock GPS as physically present.
  ///
  /// K++ still emits msgid 206 with fix=1 and 1–3 “sats” when the puck is
  /// unplugged; require a stronger signal than that for Normal.
  static const int _gpsPresentMinSats = 4;

  /// GPS row: "Not connected" unless the FC is actually reporting GPS data.
  ///
  /// K++ often leaves the GPS2 *present* bit set even with the puck unplugged,
  /// and GLOBAL_POSITION_INT / last lat-lon keep streaming — neither must show
  /// Normal. Stale coordinates alone are never enough.
  SensorHealth _gpsModuleHealth() {
    final bestFix = _maxInt(gpsFixType, gps2FixType);
    final bestSats = _maxInt(satellites, gps2Satellites);
    // 2D/3D/DGPS/RTK ⇒ module is talking (ignore bogus fix with zero sats).
    if (bestFix >= 2 && bestSats > 0) {
      return SensorHealth.healthy;
    }
    if (bestFix >= 2 && satellites == null && gps2Satellites == null) {
      return SensorHealth.healthy;
    }
    // NO_FIX (1) only counts as connected when enough sats are visible.
    // Fix 0 / null / 1 with few sats ⇒ Not connected (typical unplugged K++).
    if (bestFix >= 1 && bestSats >= _gpsPresentMinSats) {
      return SensorHealth.healthy;
    }

    return SensorHealth.notConnected;
  }

  static int _maxInt(int? a, int? b) {
    final left = a ?? 0;
    final right = b ?? 0;
    return left > right ? left : right;
  }

  /// RAW GPS update: keep coords only while fix/sats look like a live module.
  FcTelemetry _applyGpsRaw({
    required int fixType,
    required int sats,
    required int eph,
    required int latE7,
    required int lonE7,
    required int altMm,
  }) {
    final valid = _validLatLon(latE7, lonE7);
    final looksLive = fixType >= 2
        ? sats > 0
        : fixType >= 1 && sats >= _gpsPresentMinSats;
    return _copy(
      gpsFixType: fixType,
      satellites: sats,
      hdop: eph == 0xFFFF ? null : eph / 100,
      latDeg: valid && looksLive ? latE7 / 1e7 : null,
      lonDeg: valid && looksLive ? lonE7 / 1e7 : null,
      clearLatLon: !valid || !looksLive,
      altMeters: altMm / 1000,
    );
  }

  FcTelemetry _applyKppGpsStatus(KppGpsStatus message) {
    final next = _copy(
      // Live layout: [res, gps1_fix, gps1_sats, gps2_fix, gps2_sats, ...]
      gpsFixType: message.fixType,
      satellites: message.satellites,
      gps2FixType: message.fixType2,
      gps2Satellites: message.satellites2,
    );
    // Unplugged stub (fix≈1, few sats) must drop any stale lat/lon.
    if (next._gpsModuleHealth() != SensorHealth.healthy) {
      return next._copy(clearLatLon: true);
    }
    return next;
  }

  /// Fused / K++ position — only keep coords while the GPS module looks live.
  FcTelemetry _applyPositionOnly({
    required int latE7,
    required int lonE7,
    required double altMeters,
  }) {
    if (!_validLatLon(latE7, lonE7) || _gpsModuleHealth() != SensorHealth.healthy) {
      return _copy(clearLatLon: true, altMeters: altMeters);
    }
    return _copy(
      latDeg: latE7 / 1e7,
      lonDeg: lonE7 / 1e7,
      altMeters: altMeters,
    );
  }

  FcTelemetry _applyGlobalPosition(GlobalPositionInt message) {
    final heading =
        message.hdgCdeg == 65535 ? headingDeg : message.hdgCdeg / 100;
    final speed = _groundSpeedMps(message.vx, message.vy);
    final alt = message.relativeAltMm / 1000;
    if (!_validLatLon(message.latE7, message.lonE7) ||
        _gpsModuleHealth() != SensorHealth.healthy) {
      return _copy(
        clearLatLon: true,
        altMeters: alt,
        groundSpeedMps: speed,
        headingDeg: heading,
      );
    }
    return _copy(
      latDeg: message.latE7 / 1e7,
      lonDeg: message.lonE7 / 1e7,
      altMeters: alt,
      groundSpeedMps: speed,
      headingDeg: heading,
    );
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

  String get gpsFixLabel => fixLabelFor(gpsFixType);

  String get gps2FixLabel => fixLabelFor(gps2FixType);

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
      Gps2Raw() => _applyGpsRaw(
        fixType: message.fixType,
        sats: message.satellites,
        eph: message.eph,
        latE7: message.latE7,
        lonE7: message.lonE7,
        altMm: message.altMm,
      ),
      KppGpsStatus() => _applyKppGpsStatus(message),
      KppGpsPosition() => _applyPositionOnly(
        latE7: message.latE7,
        lonE7: message.lonE7,
        altMeters: message.altMm / 1000,
      ),
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
      StatusText() => _copy(lastStatusText: message.text),
      _ => this,
    };
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
    double? hdop,
    double? latDeg,
    double? lonDeg,
    bool clearLatLon = false,
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
      gpsFixType: gpsFixType ?? this.gpsFixType,
      satellites: satellites ?? this.satellites,
      gps2FixType: gps2FixType ?? this.gps2FixType,
      gps2Satellites: gps2Satellites ?? this.gps2Satellites,
      hdop: hdop ?? this.hdop,
      latDeg: clearLatLon ? null : (latDeg ?? this.latDeg),
      lonDeg: clearLatLon ? null : (lonDeg ?? this.lonDeg),
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
    );
  }
}
