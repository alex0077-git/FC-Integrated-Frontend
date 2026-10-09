import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/logs/dataflash_summary.dart';

void main() {
  test('parses FMT + GPS Lat/Lon into a track', () {
    final bytes = BytesBuilder();
    // FMT record: fixed 89 bytes; describes GPS messages of length 11.
    final fmt = Uint8List(89);
    fmt[0] = 0xA3;
    fmt[1] = 0x95;
    fmt[2] = 0x80;
    fmt[3] = 1; // msg type
    fmt[4] = 11; // GPS message length (header + two int32)
    final name = 'GPS'.codeUnits;
    for (var i = 0; i < name.length; i++) {
      fmt[5 + i] = name[i];
    }
    fmt[9] = 'L'.codeUnitAt(0);
    fmt[10] = 'L'.codeUnitAt(0);
    bytes.add(fmt);

    final gps = ByteData(11);
    gps.setUint8(0, 0xA3);
    gps.setUint8(1, 0x95);
    gps.setUint8(2, 1);
    gps.setInt32(3, 129700000, Endian.little); // 12.97
    gps.setInt32(7, 775900000, Endian.little); // 77.59
    bytes.add(gps.buffer.asUint8List());

    final summary = DataflashSummary.parse(Uint8List.fromList(bytes.toBytes()));
    expect(summary.track, isNotEmpty);
    expect(summary.track.first.$1, closeTo(12.97, 1e-6));
    expect(summary.track.first.$2, closeTo(77.59, 1e-6));
  });
}
