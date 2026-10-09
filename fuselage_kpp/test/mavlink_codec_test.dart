import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_codec.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';

/// Wire frames: clear EB MAVLink after `rotl3(clear ^ 0xDF)` (magic becomes A1).
const _serialFrames = {
  'HEARTBEAT': 'a1b6c6010bfefefefefecebefefee6836f',
  'PARAM_SET': 'a146c6010b46fefa27d4f6f6f48cc49cd40494f43cfefefefefefefeb69197',
  'PARAM_REQUEST_LIST': 'a1eec6010b56f6f6f579',
};
const _fcParamValue = 'a136aff6f64efefa23dc3dfef7fe6c5c9c04f49c5cfefefefefefefefefeb69f72';

const _gcsHeartbeat = Heartbeat(type: Heartbeat.typeGcs, autopilot: Heartbeat.autopilotInvalid);
const _setAngleMax = ParamSet(targetSystem: 1, targetComponent: 1, paramId: 'ANGLE_MAX', value: 3000);
const _requestList = ParamRequestList(targetSystem: 1, targetComponent: 1);

Uint8List _hex(String hex) =>
    Uint8List.fromList([for (var i = 0; i < hex.length; i += 2) int.parse(hex.substring(i, i + 2), radix: 16)]);

String _toHex(Uint8List bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

MavFrameEncoder _encoderAtSeq7() {
  final encoder = MavFrameEncoder(systemId: 255, componentId: 190);
  for (var i = 0; i < 7; i++) {
    encoder.encode(_requestList);
  }
  return encoder;
}

void main() {
  group('encoder matches the K++ serial frame', () {
    test('HEARTBEAT', () {
      expect(_toHex(_encoderAtSeq7().encode(_gcsHeartbeat)), _serialFrames['HEARTBEAT']);
    });
    test('PARAM_SET', () {
      expect(_toHex(_encoderAtSeq7().encode(_setAngleMax)), _serialFrames['PARAM_SET']);
    });
    test('PARAM_REQUEST_LIST', () {
      expect(_toHex(_encoderAtSeq7().encode(_requestList)), _serialFrames['PARAM_REQUEST_LIST']);
    });
  });

  test('parser decodes a serial PARAM_VALUE frame', () {
    final packets = MavFrameParser().addBytes(_hex(_fcParamValue));

    expect(packets, hasLength(1));
    final message = packets.single.message as ParamValue;
    expect(message.paramId, 'RTL_ALT');
    expect(message.value, 1500.0);
    expect(message.count, 120);
    expect(message.index, 33);
    expect(packets.single.sequence, 42);
    expect(packets.single.systemId, 1);
  });

  test('wire obfuscation round-trips clear EB frames', () {
    final clear = [0xEB, 0x09, 0x00, 0xFF, 0xBE, 0x00, 0, 0, 0, 0, 6, 8, 0, 0, 3, 0xAF, 0x32];
    final wire = encodeWireFrame(clear);
    expect(wire.first, 0xA1);
    expect(decodeWireBytes(wire), clear);
  });

  test('parser resynchronises after noise and split chunks', () {
    final frame = _hex(_fcParamValue);
    final falseStart = encodeWireFrame([0xEB, 0x12, 0x99, 0x00, 0x00, 0x00]);
    final noisy = [...falseStart, ...frame, 0xFE, 0x01];
    final parser = MavFrameParser();

    final first = parser.addBytes(noisy.sublist(0, 15));
    final second = parser.addBytes(noisy.sublist(15));

    expect(first.length + second.length, 1);
    expect(parser.rejectedFrames, greaterThan(0));
  });

  test('parser rejects a frame with a corrupted checksum', () {
    final frame = _hex(_fcParamValue);
    frame[frame.length - 1] ^= 0xFF;

    expect(MavFrameParser().addBytes(frame), isEmpty);
  });

  test('every message round-trips through a serial frame', () {
    final messages = <MavMessage>[
      _gcsHeartbeat,
      const SysStatus(
        sensorsPresent: 1,
        sensorsEnabled: 1,
        sensorsHealth: 1,
        load: 200,
        voltageMillivolts: 48200,
        currentCentiamps: 150,
        batteryRemaining: 80,
      ),
      const GpsRawInt(latE7: 129716000, lonE7: 775946000, altMm: 920000, eph: 80, fixType: 3, satellites: 17),
      const GlobalPositionInt(
        latE7: 129716000,
        lonE7: 775946000,
        altMm: 920000,
        relativeAltMm: 15000,
        vx: 0,
        vy: 0,
        vz: 0,
        hdgCdeg: 18000,
      ),
      const Gps2Raw(latE7: 129716000, lonE7: 775946000, altMm: 920000, eph: 90, fixType: 5, satellites: 16),
      const ImuSample(instance: 2, acc: [1, -2, -1000], gyro: [3, 4, 5], mag: [100, -200, 300]),
      const ScaledPressure(pressureHpa: 1009.5, temperatureCenti: 3150),
      const RcChannelsRaw(port: 1, channels: [1500, 1100, 1900, 1500, 1000, 2000, 1500, 1500], rssi: 200),
      RcChannels(channels: List.filled(16, 1500), rssi: 255),
      LogData(logId: 3, offset: 900, data: Uint8List.fromList(List.generate(90, (i) => i))),
    ];
    final encoder = MavFrameEncoder(systemId: 1, componentId: 1);
    final parser = MavFrameParser();

    final packets = parser.addBytes([for (final m in messages) ...encoder.encode(m)]);

    expect(packets.map((p) => p.message.runtimeType), messages.map((m) => m.runtimeType));
    expect((packets[2].message as GpsRawInt).satellites, 17);
    expect((packets[4].message as Gps2Raw).fixType, 5);
    expect((packets[5].message as ImuSample).mag, [100, -200, 300]);
    expect((packets[7].message as RcChannelsRaw).channels[5], 2000);
    expect((packets[9].message as LogData).data.last, 89);
    expect(parser.rejectedFrames, 0);
  });
}
