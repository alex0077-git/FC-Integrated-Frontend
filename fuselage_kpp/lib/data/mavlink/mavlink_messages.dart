import 'dart:typed_data';

import 'package:fuselage_kpp/data/mavlink/payload_buffer.dart';

/// Wire facts about one MAVLink message type.
///
/// [baseLength] is the MAVLink 1 payload size (what we encode).
/// [fullLength] includes MAVLink 2 extension fields (what we may receive).
class MavMessageSpec {
  const MavMessageSpec({
    required this.id,
    required this.crcExtra,
    required this.baseLength,
    required this.fullLength,
    required this.decode,
  });

  final int id;
  final int crcExtra;
  final int baseLength;
  final int fullLength;
  final MavMessage Function(PayloadReader reader) decode;
}

/// A MAVLink message the app understands.
sealed class MavMessage {
  const MavMessage();

  MavMessageSpec get spec;

  void writeFields(PayloadWriter writer);

  Uint8List encodePayload() {
    final writer = PayloadWriter(spec.baseLength);
    writeFields(writer);
    return writer.toBytes();
  }
}

/// Frame with an id we do not decode yet (kept for wire capture / discovery).
class UnknownMavMessage extends MavMessage {
  const UnknownMavMessage({required this.messageId, required this.payload});

  final int messageId;
  final Uint8List payload;

  @override
  MavMessageSpec get spec => MavMessageSpec(
        id: messageId,
        crcExtra: 0,
        baseLength: payload.length,
        fullLength: payload.length,
        decode: (_) => throw UnsupportedError('UnknownMavMessage'),
      );

  @override
  void writeFields(PayloadWriter writer) => writer.bytes(payload, payload.length);
}

/// Every supported message, keyed by MAVLink message id.
final Map<int, MavMessageSpec> mavMessageSpecs = {
  for (final spec in [
    Heartbeat.messageSpec,
    RadioStatus.messageSpec,
    SysStatus.messageSpec,
    BatteryStatus.messageSpec,
    ParamRequestRead.messageSpec,
    ParamRequestList.messageSpec,
    ParamValue.messageSpec,
    ParamSet.messageSpec,
    GpsRawInt.messageSpec,
    GpsStatus.messageSpec,
    GlobalPositionInt.messageSpec,
    Gps2Raw.messageSpec,
    KppGpsPosition.messageSpec,
    KppGpsStatus.messageSpec,
    KppGpsDetail.messageSpec,
    KppLinkSetup.messageSpec,
    KppAppReady.messageSpec,
    ImuSample.rawImuSpec,
    ImuSample.scaledImu2Spec,
    ImuSample.scaledImu3Spec,
    ScaledPressure.messageSpec,
    RcChannelsRaw.messageSpec,
    RcChannels.messageSpec,
    RequestDataStream.messageSpec,
    SetMode.messageSpec,
    RcChannelsOverride.messageSpec,
    CommandLong.messageSpec,
    CommandAck.messageSpec,
    MissionRequestList.messageSpec,
    MissionCount.messageSpec,
    MissionClearAll.messageSpec,
    MissionAck.messageSpec,
    MissionRequestInt.messageSpec,
    MissionItemInt.messageSpec,
    MissionSetCurrent.messageSpec,
    StatusText.messageSpec,
    LogRequestList.messageSpec,
    LogEntry.messageSpec,
    LogRequestData.messageSpec,
    LogData.messageSpec,
  ])
    spec.id: spec,
};

/// Common MAV_CMD values used by Fuselage-K++.
abstract final class MavCmd {
  static const int navWaypoint = 16;
  static const int navReturnToLaunch = 20;
  static const int navLand = 21;
  static const int navTakeoff = 22;
  static const int doChangeSpeed = 178;
  static const int doSetMode = 176;
  static const int doSetServo = 183;
  static const int doMotorTest = 209;
  static const int preflightCalibration = 241;
  static const int componentArmDisarm = 400;
  static const int missionStart = 300;
}

/// ArduCopter custom_mode values used by the FC frontend / K++ GCS.
abstract final class CopterMode {
  static const int stabilize = 0;
  static const int altHold = 2;
  static const int auto = 3;
  static const int guided = 4;
  static const int loiter = 5;
  static const int rtl = 6;
  static const int land = 9;

  static String label(int? mode) => switch (mode) {
    null => '—',
    stabilize => 'Stabilize',
    altHold => 'AltHold',
    auto => 'Auto',
    guided => 'Guided',
    loiter => 'Loiter',
    rtl => 'RTL',
    land => 'Land',
    _ => 'Mode $mode',
  };
}

/// MAV_RESULT values from COMMAND_ACK.
abstract final class MavResult {
  static const int accepted = 0;
  static const int temporarilyRejected = 1;
  static const int denied = 2;
  static const int unsupported = 3;
  static const int failed = 4;
  static const int inProgress = 5;
}

/// MAV_MISSION_RESULT values from MISSION_ACK.
abstract final class MavMissionResult {
  static const int accepted = 0;
  static const int error = 1;
  static const int unsupportedFrame = 2;
  static const int unsupported = 3;
  static const int noSpace = 4;
  static const int invalid = 5;
}

/// MAV_FRAME values for mission items.
abstract final class MavFrame {
  static const int global = 0;
  static const int globalRelativeAlt = 3;
  static const int globalInt = 5;
  static const int globalRelativeAltInt = 6;
}

class Heartbeat extends MavMessage {
  const Heartbeat({
    required this.type,
    required this.autopilot,
    this.customMode = 0,
    this.baseMode = 0,
    this.systemStatus = 0,
    this.mavlinkVersion = 3,
  });

  static const int typeGcs = 6;
  static const int autopilotInvalid = 8;

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 0,
    crcExtra: 50,
    baseLength: 9,
    fullLength: 9,
    decode: (r) {
      final customMode = r.u32();
      return Heartbeat(
        customMode: customMode,
        type: r.u8(),
        autopilot: r.u8(),
        baseMode: r.u8(),
        systemStatus: r.u8(),
        mavlinkVersion: r.u8(),
      );
    },
  );

  final int customMode;
  final int type;
  final int autopilot;
  final int baseMode;
  final int systemStatus;
  final int mavlinkVersion;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u32(customMode)
    ..u8(type)
    ..u8(autopilot)
    ..u8(baseMode)
    ..u8(systemStatus)
    ..u8(mavlinkVersion);
}

/// SiK / T12 radio status (msgid 109) — emitted by the transmitter itself over SPP.
///
/// MAVLink wire order is largest fields first (u16 then u8), not the docs'
/// logical order.
class RadioStatus extends MavMessage {
  const RadioStatus({
    required this.rxerrors,
    required this.fixed,
    required this.rssi,
    required this.remrssi,
    required this.txbuf,
    required this.noise,
    required this.remnoise,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 109,
    crcExtra: 185,
    baseLength: 9,
    fullLength: 9,
    decode: (r) => RadioStatus(
      rxerrors: r.u16(),
      fixed: r.u16(),
      rssi: r.u8(),
      remrssi: r.u8(),
      txbuf: r.u8(),
      noise: r.u8(),
      remnoise: r.u8(),
    ),
  );

  final int rxerrors;
  final int fixed;
  final int rssi;
  final int remrssi;
  final int txbuf;
  final int noise;
  final int remnoise;

  /// True when the TX reports a remote (aircraft) radio signal.
  bool get hasRemoteLink => remrssi > 0;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u16(rxerrors)
    ..u16(fixed)
    ..u8(rssi)
    ..u8(remrssi)
    ..u8(txbuf)
    ..u8(noise)
    ..u8(remnoise);
}

class SysStatus extends MavMessage {
  const SysStatus({
    required this.sensorsPresent,
    required this.sensorsEnabled,
    required this.sensorsHealth,
    required this.load,
    required this.voltageMillivolts,
    required this.currentCentiamps,
    required this.batteryRemaining,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 1,
    crcExtra: 124,
    baseLength: 31,
    fullLength: 43,
    decode: (r) {
      final present = r.u32();
      final enabled = r.u32();
      final health = r.u32();
      final load = r.u16();
      final voltage = r.u16();
      final current = r.i16();
      for (var i = 0; i < 6; i++) {
        r.u16();
      }
      return SysStatus(
        sensorsPresent: present,
        sensorsEnabled: enabled,
        sensorsHealth: health,
        load: load,
        voltageMillivolts: voltage,
        currentCentiamps: current,
        batteryRemaining: r.i8(),
      );
    },
  );

  final int sensorsPresent;
  final int sensorsEnabled;
  final int sensorsHealth;
  final int load;
  final int voltageMillivolts;
  final int currentCentiamps;
  final int batteryRemaining;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) {
    w
      ..u32(sensorsPresent)
      ..u32(sensorsEnabled)
      ..u32(sensorsHealth)
      ..u16(load)
      ..u16(voltageMillivolts)
      ..i16(currentCentiamps);
    for (var i = 0; i < 6; i++) {
      w.u16(0);
    }
    w.i8(batteryRemaining);
  }
}

/// MAVLink BATTERY_STATUS (#147) — preferred source for pack remaining %.
class BatteryStatus extends MavMessage {
  const BatteryStatus({
    required this.id,
    required this.batteryFunction,
    required this.type,
    required this.temperature,
    required this.voltagesMv,
    required this.currentCentiamps,
    required this.currentConsumedMah,
    required this.energyConsumedHaj,
    required this.batteryRemaining,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 147,
    crcExtra: 154,
    baseLength: 36,
    fullLength: 54,
    decode: (r) {
      final id = r.u8();
      final function = r.u8();
      final type = r.u8();
      final temperature = r.i16();
      final voltages = [for (var i = 0; i < 10; i++) r.u16()];
      return BatteryStatus(
        id: id,
        batteryFunction: function,
        type: type,
        temperature: temperature,
        voltagesMv: voltages,
        currentCentiamps: r.i16(),
        currentConsumedMah: r.i32(),
        energyConsumedHaj: r.i32(),
        batteryRemaining: r.i8(),
      );
    },
  );

  final int id;
  final int batteryFunction;
  final int type;
  final int temperature;
  final List<int> voltagesMv;
  final int currentCentiamps;
  final int currentConsumedMah;
  final int energyConsumedHaj;
  final int batteryRemaining;

  /// Sum of known cell voltages, or cell0 when used as pack voltage (mV).
  double? get packVoltage {
    var sum = 0;
    var any = false;
    for (final cell in voltagesMv) {
      if (cell == 0 || cell >= 65535) {
        continue;
      }
      sum += cell;
      any = true;
    }
    if (!any) {
      return null;
    }
    return sum / 1000;
  }

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) {
    w
      ..u8(id)
      ..u8(batteryFunction)
      ..u8(type)
      ..i16(temperature);
    for (var i = 0; i < 10; i++) {
      w.u16(i < voltagesMv.length ? voltagesMv[i] : 65535);
    }
    w
      ..i16(currentCentiamps)
      ..i32(currentConsumedMah)
      ..i32(energyConsumedHaj)
      ..i8(batteryRemaining);
  }
}

class ParamRequestRead extends MavMessage {
  const ParamRequestRead({
    required this.targetSystem,
    required this.targetComponent,
    required this.paramId,
    this.paramIndex = -1,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 20,
    crcExtra: 214,
    baseLength: 20,
    fullLength: 20,
    decode: (r) {
      final index = r.i16();
      return ParamRequestRead(paramIndex: index, targetSystem: r.u8(), targetComponent: r.u8(), paramId: r.chars(16));
    },
  );

  final int paramIndex;
  final int targetSystem;
  final int targetComponent;
  final String paramId;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..i16(paramIndex)
    ..u8(targetSystem)
    ..u8(targetComponent)
    ..chars(paramId, 16);
}

class ParamRequestList extends MavMessage {
  const ParamRequestList({required this.targetSystem, required this.targetComponent});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 21,
    crcExtra: 159,
    baseLength: 2,
    fullLength: 2,
    decode: (r) => ParamRequestList(targetSystem: r.u8(), targetComponent: r.u8()),
  );

  final int targetSystem;
  final int targetComponent;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u8(targetSystem)
    ..u8(targetComponent);
}

/// MAV_PARAM_TYPE values used on the wire.
abstract final class MavParamType {
  static const int int32 = 6;
  static const int real32 = 9;
}

class ParamValue extends MavMessage {
  const ParamValue({
    required this.paramId,
    required this.value,
    required this.type,
    required this.count,
    required this.index,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 22,
    crcExtra: 220,
    baseLength: 25,
    fullLength: 25,
    decode: (r) {
      final value = r.f32();
      final count = r.u16();
      final index = r.u16();
      return ParamValue(value: value, count: count, index: index, paramId: r.chars(16), type: r.u8());
    },
  );

  final String paramId;
  final double value;
  final int type;
  final int count;
  final int index;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..f32(value)
    ..u16(count)
    ..u16(index)
    ..chars(paramId, 16)
    ..u8(type);
}

class ParamSet extends MavMessage {
  const ParamSet({
    required this.targetSystem,
    required this.targetComponent,
    required this.paramId,
    required this.value,
    this.type = MavParamType.real32,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 23,
    crcExtra: 168,
    baseLength: 23,
    fullLength: 23,
    decode: (r) {
      final value = r.f32();
      return ParamSet(value: value, targetSystem: r.u8(), targetComponent: r.u8(), paramId: r.chars(16), type: r.u8());
    },
  );

  final int targetSystem;
  final int targetComponent;
  final String paramId;
  final double value;
  final int type;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..f32(value)
    ..u8(targetSystem)
    ..u8(targetComponent)
    ..chars(paramId, 16)
    ..u8(type);
}

class GpsRawInt extends MavMessage {
  const GpsRawInt({
    required this.latE7,
    required this.lonE7,
    required this.altMm,
    required this.eph,
    required this.fixType,
    required this.satellites,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 24,
    crcExtra: 24,
    baseLength: 30,
    fullLength: 52,
    decode: (r) {
      r.u64();
      final lat = r.i32();
      final lon = r.i32();
      final alt = r.i32();
      final eph = r.u16();
      r
        ..u16()
        ..u16()
        ..u16();
      return GpsRawInt(latE7: lat, lonE7: lon, altMm: alt, eph: eph, fixType: r.u8(), satellites: r.u8());
    },
  );

  final int latE7;
  final int lonE7;
  final int altMm;
  final int eph;
  final int fixType;
  final int satellites;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u64(0)
    ..i32(latE7)
    ..i32(lonE7)
    ..i32(altMm)
    ..u16(eph)
    ..u16(0xFFFF)
    ..u16(0)
    ..u16(0)
    ..u8(fixType)
    ..u8(satellites);
}

/// GLOBAL_POSITION_INT (33) — fused position; useful when GPS_RAW_INT is quiet.
class GlobalPositionInt extends MavMessage {
  const GlobalPositionInt({
    required this.latE7,
    required this.lonE7,
    required this.altMm,
    required this.relativeAltMm,
    required this.vx,
    required this.vy,
    required this.vz,
    required this.hdgCdeg,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 33,
    crcExtra: 104,
    baseLength: 28,
    fullLength: 28,
    decode: (r) {
      r.u32();
      return GlobalPositionInt(
        latE7: r.i32(),
        lonE7: r.i32(),
        altMm: r.i32(),
        relativeAltMm: r.i32(),
        vx: r.i16(),
        vy: r.i16(),
        vz: r.i16(),
        hdgCdeg: r.u16(),
      );
    },
  );

  final int latE7;
  final int lonE7;
  final int altMm;
  final int relativeAltMm;
  final int vx;
  final int vy;
  final int vz;
  final int hdgCdeg;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u32(0)
    ..i32(latE7)
    ..i32(lonE7)
    ..i32(altMm)
    ..i32(relativeAltMm)
    ..i16(vx)
    ..i16(vy)
    ..i16(vz)
    ..u16(hdgCdeg);
}

/// JIYI send-before-streams setup (msgid 211), captured as payload `01`.
class KppLinkSetup extends MavMessage {
  const KppLinkSetup({this.enable = 1});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 211,
    crcExtra: 3,
    baseLength: 1,
    fullLength: 1,
    decode: (r) => KppLinkSetup(enable: r.u8()),
  );

  final int enable;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w.u8(enable);
}

/// JIYI send-after-streams ready (msgid 220), captured as payload `01 00`.
class KppAppReady extends MavMessage {
  const KppAppReady({this.flag = 1});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 220,
    crcExtra: 81,
    baseLength: 2,
    fullLength: 2,
    decode: (r) => KppAppReady(flag: r.u8()),
  );

  final int flag;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u8(flag)
    ..u8(0);
}

/// K++ proprietary GPS position (msgid 203). Lat/lon are degE7; zero when no fix.
///
/// Payload: `lat | lon | alt | 5-byte tail`. Tail layout is unproven on this
/// firmware — do not invent fix/sat counts from it (sats come from msgid 206).
class KppGpsPosition extends MavMessage {
  const KppGpsPosition({
    required this.latE7,
    required this.lonE7,
    required this.altMm,
    this.status = 0,
    this.fixType = 0,
    this.satellites = 0,
    this.fixType2 = 0,
    this.satellites2 = 0,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 203,
    crcExtra: 61,
    baseLength: 17,
    fullLength: 17,
    decode: (r) {
      final lat = r.i32();
      final lon = r.i32();
      final alt = r.i32();
      // Consume tail; leave fix/sats at 0 until a capture proves the layout.
      r.u8();
      r.u8();
      r.u8();
      r.u8();
      r.u8();
      return KppGpsPosition(latE7: lat, lonE7: lon, altMm: alt);
    },
  );

  final int latE7;
  final int lonE7;
  final int altMm;
  final int status;
  final int fixType;
  final int satellites;
  final int fixType2;
  final int satellites2;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..i32(latE7)
    ..i32(lonE7)
    ..i32(altMm)
    ..u8(status)
    ..u8(fixType)
    ..u8(satellites)
    ..u8(fixType2)
    ..u8(satellites2);
}

/// Standard GPS_STATUS (25) — satellites_visible when RAW is quiet on K++.
class GpsStatus extends MavMessage {
  const GpsStatus({required this.satellitesVisible});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 25,
    crcExtra: 23,
    baseLength: 101,
    fullLength: 101,
    decode: (r) {
      final sats = r.u8();
      // Remainder is per-sat PRN/used/elevation/azimuth/snr — not needed for UI.
      return GpsStatus(satellitesVisible: sats);
    },
  );

  final int satellitesVisible;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w..u8(satellitesVisible)..bytes(List<int>.filled(100, 0), 100);
}

/// K++ proprietary GPS status (msgid 206) — quality grade, not sat count.
///
/// Live USB (6 bytes): `[res, hdr, quality, b3, pad, pad]`
/// Captures show byte[2] in 1..4 while msgid 207[73] holds the sat count.
/// [satellites] here stores that quality grade (legacy field name).
class KppGpsStatus extends MavMessage {
  const KppGpsStatus({required this.fixType, required this.satellites, this.fixType2 = 0, this.satellites2 = 0});

  static const int minGoodSatellites = 6;

  /// Quality grade from payload[2] (1..4 in outdoor captures).
  int get quality => satellites;

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 206,
    crcExtra: 215,
    baseLength: 6,
    fullLength: 6,
    decode: (r) {
      r.u8(); // reserved
      r.u8(); // hdr
      final quality = r.u8();
      r.u8();
      r.u8();
      r.u8();
      return KppGpsStatus(fixType: 0, satellites: quality);
    },
  );

  final int fixType;
  final int satellites;
  final int fixType2;
  final int satellites2;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) {
    w
      ..u8(0)
      ..u8(1)
      ..u8(satellites & 0xFF)
      ..u8(0)
      ..u8(1)
      ..u8(1);
  }
}

/// K++ proprietary GPS detail (msgid 207) — 75-byte payload.
///
/// Satellite count is unsigned payload[73]. Ignore any frame whose wire
/// length is not exactly 75 (enforced in the frame parser + [tryParse]).
class KppGpsDetail extends MavMessage {
  const KppGpsDetail({
    required this.utcTime,
    required this.latE7,
    required this.lonE7,
    required this.gpsState,
    required this.rtkStatus,
    required this.gpsSats,
  });

  static const int payloadLength = 75;
  // crc_extra from JIYI221014 dialect table (index 207).
  static const int crcExtraValue = 154;

  /// Returns null when [payload] length is not 75.
  static KppGpsDetail? tryParse(List<int> payload) {
    if (payload.length != payloadLength) {
      return null;
    }
    return _parseReader(PayloadReader(Uint8List.fromList(payload), payloadLength));
  }

  static KppGpsDetail _parseReader(PayloadReader r) {
    // utc_time u64 @0, latitude i32 @20, longitude i32 @24,
    // gps_state u8 @65, rtk_status u8 @69, gps_sats u8 @73 (unsigned).
    final utcTime = r.u64();
    r.bytes(12);
    final latE7 = r.i32();
    final lonE7 = r.i32();
    r.bytes(37);
    final gpsState = r.u8();
    r.bytes(3);
    final rtkStatus = r.u8();
    r.bytes(3);
    final gpsSats = r.u8();
    return KppGpsDetail(
      utcTime: utcTime,
      latE7: latE7,
      lonE7: lonE7,
      gpsState: gpsState,
      rtkStatus: rtkStatus,
      gpsSats: gpsSats,
    );
  }

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 207,
    crcExtra: crcExtraValue,
    baseLength: payloadLength,
    fullLength: payloadLength,
    decode: (r) => _parseReader(r),
  );

  final int utcTime;
  final int latE7;
  final int lonE7;
  final int gpsState;
  final int rtkStatus;
  final int gpsSats;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) {
    w.u64(utcTime);
    w.bytes(List<int>.filled(12, 0), 12);
    w.i32(latE7);
    w.i32(lonE7);
    w.bytes(List<int>.filled(37, 0), 37);
    w.u8(gpsState);
    w.bytes(List<int>.filled(3, 0), 3);
    w.u8(rtkStatus);
    w.bytes(List<int>.filled(3, 0), 3);
    w.u8(gpsSats & 0xFF);
  }
}

/// GPS2_RAW (124) — K++ reports the agri GPS on the GPS2 sensor bit.
class Gps2Raw extends MavMessage {
  const Gps2Raw({
    required this.latE7,
    required this.lonE7,
    required this.altMm,
    required this.eph,
    required this.fixType,
    required this.satellites,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 124,
    crcExtra: 87,
    baseLength: 35,
    fullLength: 57,
    decode: (r) {
      // MAVLink1 wire order: time_usec, lat, lon, alt, dgps_age, eph, epv, vel, cog,
      // fix_type, satellites_visible, dgps_numch.
      r.u64();
      final lat = r.i32();
      final lon = r.i32();
      final alt = r.i32();
      r.u32();
      final eph = r.u16();
      r
        ..u16()
        ..u16()
        ..u16();
      return Gps2Raw(latE7: lat, lonE7: lon, altMm: alt, eph: eph, fixType: r.u8(), satellites: r.u8());
    },
  );

  final int latE7;
  final int lonE7;
  final int altMm;
  final int eph;
  final int fixType;
  final int satellites;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u64(0)
    ..i32(latE7)
    ..i32(lonE7)
    ..i32(altMm)
    ..u32(0)
    ..u16(eph)
    ..u16(0xFFFF)
    ..u16(0)
    ..u16(0)
    ..u8(fixType)
    ..u8(satellites)
    ..u8(0);
}

/// RAW_IMU (instance 0), SCALED_IMU2 (1) and SCALED_IMU3 (2) share a layout
/// apart from the timestamp width, so one class represents all three.
class ImuSample extends MavMessage {
  const ImuSample({required this.instance, required this.acc, required this.gyro, required this.mag});

  static final MavMessageSpec rawImuSpec = MavMessageSpec(
    id: 27,
    crcExtra: 144,
    baseLength: 26,
    fullLength: 29,
    decode: (r) {
      r.u64();
      return _decodeAxes(0, r);
    },
  );

  static final MavMessageSpec scaledImu2Spec = MavMessageSpec(
    id: 116,
    crcExtra: 76,
    baseLength: 22,
    fullLength: 24,
    decode: (r) {
      r.u32();
      return _decodeAxes(1, r);
    },
  );

  static final MavMessageSpec scaledImu3Spec = MavMessageSpec(
    id: 129,
    crcExtra: 0,
    baseLength: 22,
    fullLength: 24,
    decode: (r) {
      r.u32();
      return _decodeAxes(2, r);
    },
  );

  final int instance;
  final List<int> acc;
  final List<int> gyro;
  final List<int> mag;

  @override
  MavMessageSpec get spec => switch (instance) {
    0 => rawImuSpec,
    1 => scaledImu2Spec,
    _ => scaledImu3Spec,
  };

  @override
  void writeFields(PayloadWriter w) {
    if (instance == 0) {
      w.u64(0);
    } else {
      w.u32(0);
    }
    for (final value in [...acc, ...gyro, ...mag]) {
      w.i16(value);
    }
  }

  static ImuSample _decodeAxes(int instance, PayloadReader r) {
    List<int> axes() => [r.i16(), r.i16(), r.i16()];
    return ImuSample(instance: instance, acc: axes(), gyro: axes(), mag: axes());
  }
}

class ScaledPressure extends MavMessage {
  const ScaledPressure({required this.pressureHpa, required this.temperatureCenti});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 29,
    crcExtra: 115,
    baseLength: 14,
    fullLength: 16,
    decode: (r) {
      r.u32();
      final pressure = r.f32();
      r.f32();
      return ScaledPressure(pressureHpa: pressure, temperatureCenti: r.i16());
    },
  );

  final double pressureHpa;
  final int temperatureCenti;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u32(0)
    ..f32(pressureHpa)
    ..f32(0)
    ..i16(temperatureCenti);
}

/// RC_CHANNELS: up to 18 channel PWM values in microseconds.
class RcChannels extends MavMessage {
  const RcChannels({required this.channels, required this.rssi});

  static const int maxChannels = 18;

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 65,
    crcExtra: 118,
    baseLength: 42,
    fullLength: 42,
    decode: (r) {
      r.u32();
      final values = [for (var i = 0; i < maxChannels; i++) r.u16()];
      final count = r.u8();
      return RcChannels(channels: values.take(count).toList(), rssi: r.u8());
    },
  );

  final List<int> channels;
  final int rssi;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) {
    w.u32(0);
    for (var i = 0; i < maxChannels; i++) {
      w.u16(i < channels.length ? channels[i] : 0);
    }
    w
      ..u8(channels.length)
      ..u8(rssi);
  }
}

/// RC_CHANNELS_RAW: eight channels per message; [port] 0 = channels 1-8,
/// port 1 = channels 9-16.
class RcChannelsRaw extends MavMessage {
  const RcChannelsRaw({required this.port, required this.channels, required this.rssi});

  static const int channelsPerPort = 8;

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 35,
    crcExtra: 244,
    baseLength: 22,
    fullLength: 22,
    decode: (r) {
      r.u32();
      final values = [for (var i = 0; i < channelsPerPort; i++) r.u16()];
      return RcChannelsRaw(channels: values, port: r.u8(), rssi: r.u8());
    },
  );

  final int port;
  final List<int> channels;
  final int rssi;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) {
    w.u32(0);
    for (var i = 0; i < channelsPerPort; i++) {
      w.u16(i < channels.length ? channels[i] : 0);
    }
    w
      ..u8(port)
      ..u8(rssi);
  }
}

class RequestDataStream extends MavMessage {
  const RequestDataStream({
    required this.targetSystem,
    required this.targetComponent,
    required this.rateHz,
    this.streamId = allStreams,
    this.start = true,
  });

  static const int allStreams = 0;
  static const int rawSensors = 1;
  static const int extendedStatus = 2;
  static const int rcChannels = 3;
  static const int position = 6;
  static const int extra1 = 10;
  static const int extra2 = 11;
  static const int extra3 = 12;
  /// JIYI-specific streams that carry K++ GPS status / agri telemetry (203/206…).
  static const int kppAgri1 = 13;
  static const int kppAgri2 = 14;

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 66,
    crcExtra: 148,
    baseLength: 6,
    fullLength: 6,
    decode: (r) {
      final rate = r.u16();
      return RequestDataStream(
        rateHz: rate,
        targetSystem: r.u8(),
        targetComponent: r.u8(),
        streamId: r.u8(),
        start: r.u8() == 1,
      );
    },
  );

  final int targetSystem;
  final int targetComponent;
  final int rateHz;
  final int streamId;
  final bool start;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u16(rateHz)
    ..u8(targetSystem)
    ..u8(targetComponent)
    ..u8(streamId)
    ..u8(start ? 1 : 0);
}

class LogRequestList extends MavMessage {
  const LogRequestList({required this.targetSystem, required this.targetComponent});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 117,
    crcExtra: 128,
    baseLength: 6,
    fullLength: 6,
    decode: (r) {
      r
        ..u16()
        ..u16();
      return LogRequestList(targetSystem: r.u8(), targetComponent: r.u8());
    },
  );

  final int targetSystem;
  final int targetComponent;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u16(0)
    ..u16(0xFFFF)
    ..u8(targetSystem)
    ..u8(targetComponent);
}

class LogEntry extends MavMessage {
  const LogEntry({
    required this.timeUtc,
    required this.size,
    required this.id,
    required this.numLogs,
    required this.lastLogNum,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 118,
    crcExtra: 56,
    baseLength: 14,
    fullLength: 14,
    decode: (r) => LogEntry(timeUtc: r.u32(), size: r.u32(), id: r.u16(), numLogs: r.u16(), lastLogNum: r.u16()),
  );

  final int timeUtc;
  final int size;
  final int id;
  final int numLogs;
  final int lastLogNum;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u32(timeUtc)
    ..u32(size)
    ..u16(id)
    ..u16(numLogs)
    ..u16(lastLogNum);
}

class LogRequestData extends MavMessage {
  const LogRequestData({
    required this.targetSystem,
    required this.targetComponent,
    required this.logId,
    required this.offset,
    required this.count,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 119,
    crcExtra: 116,
    baseLength: 12,
    fullLength: 12,
    decode: (r) {
      final offset = r.u32();
      final count = r.u32();
      final logId = r.u16();
      return LogRequestData(offset: offset, count: count, logId: logId, targetSystem: r.u8(), targetComponent: r.u8());
    },
  );

  final int targetSystem;
  final int targetComponent;
  final int logId;
  final int offset;
  final int count;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u32(offset)
    ..u32(count)
    ..u16(logId)
    ..u8(targetSystem)
    ..u8(targetComponent);
}

class LogData extends MavMessage {
  const LogData({required this.logId, required this.offset, required this.data});

  static const int chunkSize = 90;

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 120,
    crcExtra: 24,
    baseLength: 97,
    fullLength: 97,
    decode: (r) {
      final offset = r.u32();
      final logId = r.u16();
      final count = r.u8();
      return LogData(offset: offset, logId: logId, data: r.bytes(chunkSize).sublist(0, count));
    },
  );

  final int logId;
  final int offset;
  final Uint8List data;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u32(offset)
    ..u16(logId)
    ..u8(data.length)
    ..bytes(data, chunkSize);
}

/// SET_MODE (#11) — legacy arm/mode path some proprietary FCs still honor.
class SetMode extends MavMessage {
  const SetMode({
    required this.targetSystem,
    required this.baseMode,
    required this.customMode,
  });

  static const int flagCustomModeEnabled = 1;
  static const int flagSafetyArmed = 128;

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 11,
    crcExtra: 89,
    baseLength: 6,
    fullLength: 6,
    decode: (r) {
      final target = r.u8();
      final base = r.u8();
      return SetMode(targetSystem: target, baseMode: base, customMode: r.u32());
    },
  );

  final int targetSystem;
  final int baseMode;
  final int customMode;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u8(targetSystem)
    ..u8(baseMode)
    ..u32(customMode);
}

/// RC_CHANNELS_OVERRIDE (#70) — used for stick-arm on FCs that reject cmd 400.
class RcChannelsOverride extends MavMessage {
  const RcChannelsOverride({
    required this.targetSystem,
    required this.targetComponent,
    required this.channels,
  });

  /// UINT16_MAX = ignore / release this channel.
  static const int ignore = 0xFFFF;

  static RcChannelsOverride release({required int targetSystem, int targetComponent = 0}) {
    return RcChannelsOverride(
      targetSystem: targetSystem,
      targetComponent: targetComponent,
      channels: List<int>.filled(8, ignore),
    );
  }

  /// Throttle-low + yaw-right arm gesture (Mode-2 AETR: ch3 thr, ch4 yaw).
  static RcChannelsOverride stickArm({required int targetSystem, int targetComponent = 0}) {
    return RcChannelsOverride(
      targetSystem: targetSystem,
      targetComponent: targetComponent,
      channels: const [1500, 1500, 1000, 2000, ignore, ignore, ignore, ignore],
    );
  }

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 70,
    crcExtra: 124,
    baseLength: 18,
    fullLength: 18,
    decode: (r) {
      final sys = r.u8();
      final comp = r.u8();
      final ch = [for (var i = 0; i < 8; i++) r.u16()];
      return RcChannelsOverride(targetSystem: sys, targetComponent: comp, channels: ch);
    },
  );

  final int targetSystem;
  final int targetComponent;
  final List<int> channels;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) {
    w
      ..u8(targetSystem)
      ..u8(targetComponent);
    for (var i = 0; i < 8; i++) {
      w.u16(i < channels.length ? channels[i] : ignore);
    }
  }
}

class CommandLong extends MavMessage {
  const CommandLong({
    required this.command,
    required this.targetSystem,
    required this.targetComponent,
    this.param1 = 0,
    this.param2 = 0,
    this.param3 = 0,
    this.param4 = 0,
    this.param5 = 0,
    this.param6 = 0,
    this.param7 = 0,
    this.confirmation = 0,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 76,
    crcExtra: 152,
    baseLength: 33,
    fullLength: 33,
    decode: (r) {
      final p1 = r.f32();
      final p2 = r.f32();
      final p3 = r.f32();
      final p4 = r.f32();
      final p5 = r.f32();
      final p6 = r.f32();
      final p7 = r.f32();
      final command = r.u16();
      return CommandLong(
        param1: p1,
        param2: p2,
        param3: p3,
        param4: p4,
        param5: p5,
        param6: p6,
        param7: p7,
        command: command,
        targetSystem: r.u8(),
        targetComponent: r.u8(),
        confirmation: r.u8(),
      );
    },
  );

  final int command;
  final int targetSystem;
  final int targetComponent;
  final double param1;
  final double param2;
  final double param3;
  final double param4;
  final double param5;
  final double param6;
  final double param7;
  final int confirmation;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..f32(param1)
    ..f32(param2)
    ..f32(param3)
    ..f32(param4)
    ..f32(param5)
    ..f32(param6)
    ..f32(param7)
    ..u16(command)
    ..u8(targetSystem)
    ..u8(targetComponent)
    ..u8(confirmation);
}

class CommandAck extends MavMessage {
  const CommandAck({required this.command, required this.result});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 77,
    crcExtra: 143,
    baseLength: 3,
    fullLength: 3,
    decode: (r) => CommandAck(command: r.u16(), result: r.u8()),
  );

  final int command;
  final int result;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u16(command)
    ..u8(result);
}

class MissionRequestList extends MavMessage {
  const MissionRequestList({required this.targetSystem, required this.targetComponent});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 43,
    crcExtra: 132,
    baseLength: 2,
    fullLength: 2,
    decode: (r) => MissionRequestList(targetSystem: r.u8(), targetComponent: r.u8()),
  );

  final int targetSystem;
  final int targetComponent;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u8(targetSystem)
    ..u8(targetComponent);
}

class MissionCount extends MavMessage {
  const MissionCount({required this.count, required this.targetSystem, required this.targetComponent});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 44,
    crcExtra: 221,
    baseLength: 4,
    fullLength: 4,
    decode: (r) {
      final count = r.u16();
      return MissionCount(count: count, targetSystem: r.u8(), targetComponent: r.u8());
    },
  );

  final int count;
  final int targetSystem;
  final int targetComponent;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u16(count)
    ..u8(targetSystem)
    ..u8(targetComponent);
}

class MissionClearAll extends MavMessage {
  const MissionClearAll({required this.targetSystem, required this.targetComponent});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 45,
    crcExtra: 232,
    baseLength: 2,
    fullLength: 2,
    decode: (r) => MissionClearAll(targetSystem: r.u8(), targetComponent: r.u8()),
  );

  final int targetSystem;
  final int targetComponent;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u8(targetSystem)
    ..u8(targetComponent);
}

class MissionAck extends MavMessage {
  const MissionAck({required this.targetSystem, required this.targetComponent, required this.type});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 47,
    crcExtra: 153,
    baseLength: 3,
    fullLength: 3,
    decode: (r) => MissionAck(targetSystem: r.u8(), targetComponent: r.u8(), type: r.u8()),
  );

  final int targetSystem;
  final int targetComponent;
  final int type;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u8(targetSystem)
    ..u8(targetComponent)
    ..u8(type);
}

class MissionRequestInt extends MavMessage {
  const MissionRequestInt({required this.seq, required this.targetSystem, required this.targetComponent});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 51,
    crcExtra: 196,
    baseLength: 4,
    fullLength: 4,
    decode: (r) {
      final seq = r.u16();
      return MissionRequestInt(seq: seq, targetSystem: r.u8(), targetComponent: r.u8());
    },
  );

  final int seq;
  final int targetSystem;
  final int targetComponent;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u16(seq)
    ..u8(targetSystem)
    ..u8(targetComponent);
}

class MissionSetCurrent extends MavMessage {
  const MissionSetCurrent({required this.seq, required this.targetSystem, required this.targetComponent});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 41,
    crcExtra: 28,
    baseLength: 4,
    fullLength: 4,
    decode: (r) {
      final seq = r.u16();
      return MissionSetCurrent(seq: seq, targetSystem: r.u8(), targetComponent: r.u8());
    },
  );

  final int seq;
  final int targetSystem;
  final int targetComponent;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u16(seq)
    ..u8(targetSystem)
    ..u8(targetComponent);
}

class MissionItemInt extends MavMessage {
  const MissionItemInt({
    required this.seq,
    required this.command,
    required this.targetSystem,
    required this.targetComponent,
    required this.frame,
    required this.x,
    required this.y,
    required this.z,
    this.param1 = 0,
    this.param2 = 0,
    this.param3 = 0,
    this.param4 = 0,
    this.current = 0,
    this.autocontinue = 1,
  });

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 73,
    crcExtra: 38,
    baseLength: 37,
    fullLength: 37,
    decode: (r) {
      final p1 = r.f32();
      final p2 = r.f32();
      final p3 = r.f32();
      final p4 = r.f32();
      final x = r.i32();
      final y = r.i32();
      final z = r.f32();
      final seq = r.u16();
      final command = r.u16();
      return MissionItemInt(
        param1: p1,
        param2: p2,
        param3: p3,
        param4: p4,
        x: x,
        y: y,
        z: z,
        seq: seq,
        command: command,
        targetSystem: r.u8(),
        targetComponent: r.u8(),
        frame: r.u8(),
        current: r.u8(),
        autocontinue: r.u8(),
      );
    },
  );

  final int seq;
  final int command;
  final int targetSystem;
  final int targetComponent;
  final int frame;
  final int x;
  final int y;
  final double z;
  final double param1;
  final double param2;
  final double param3;
  final double param4;
  final int current;
  final int autocontinue;

  double get latDeg => x / 1e7;
  double get lonDeg => y / 1e7;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..f32(param1)
    ..f32(param2)
    ..f32(param3)
    ..f32(param4)
    ..i32(x)
    ..i32(y)
    ..f32(z)
    ..u16(seq)
    ..u16(command)
    ..u8(targetSystem)
    ..u8(targetComponent)
    ..u8(frame)
    ..u8(current)
    ..u8(autocontinue);
}

class StatusText extends MavMessage {
  const StatusText({required this.severity, required this.text});

  static final MavMessageSpec messageSpec = MavMessageSpec(
    id: 253,
    crcExtra: 83,
    baseLength: 51,
    fullLength: 51,
    decode: (r) => StatusText(severity: r.u8(), text: r.chars(50)),
  );

  final int severity;
  final String text;

  @override
  MavMessageSpec get spec => messageSpec;

  @override
  void writeFields(PayloadWriter w) => w
    ..u8(severity)
    ..chars(text, 50);
}
