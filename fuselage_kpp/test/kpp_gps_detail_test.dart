import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/mavlink/payload_buffer.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

Directory? _captureDir() {
  final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
  if (home == null) {
    return null;
  }
  final dir = Directory('$home${Platform.pathSeparator}Documents${Platform.pathSeparator}FuselageKppCaptures');
  return dir.existsSync() ? dir : null;
}

File? _captureNamed(String contains) {
  final dir = _captureDir();
  if (dir == null) {
    return null;
  }
  for (final f in dir.listSync().whereType<File>()) {
    if (f.path.contains(contains) && f.path.endsWith('.jsonl') && f.lengthSync() > 0) {
      return f;
    }
  }
  return null;
}

Iterable<Uint8List> _payloads(File file, int msgid) sync* {
  for (final line in file.readAsLinesSync()) {
    if (line.trim().isEmpty) {
      continue;
    }
    final row = jsonDecode(line) as Map<String, dynamic>;
    if (row['msgid'] != msgid) {
      continue;
    }
    final hx = row['payload_hex'] as String?;
    if (hx == null || hx.isEmpty) {
      continue;
    }
    yield Uint8List.fromList([
      for (var i = 0; i + 1 < hx.length; i += 2) int.parse(hx.substring(i, i + 2), radix: 16),
    ]);
  }
}

void main() {
  test('tryParse ignores payload length 74', () {
    final short = Uint8List(74);
    expect(KppGpsDetail.tryParse(short), isNull);
  });

  test('byte 73 = 200 is unsigned 200', () {
    final payload = Uint8List(75);
    payload[73] = 200;
    final msg = KppGpsDetail.tryParse(payload);
    expect(msg, isNotNull);
    expect(msg!.gpsSats, 200);
    expect(msg.gpsSats, isNonNegative);
  });

  test('FcTelemetry satellites come from 207 not 206 quality', () {
    FcTelemetry.resetQualityMismatchLogForTest();
    var t = const FcTelemetry().apply(const KppGpsStatus(fixType: 0, satellites: 4));
    expect(t.gpsQuality, 4);
    expect(t.satellites, isNull);
    expect(t.displaySatellites, isNull);

    final detail = KppGpsDetail(
      utcTime: 0,
      latE7: 0,
      lonE7: 0,
      gpsState: 2,
      rtkStatus: 0,
      gpsSats: 15,
    );
    t = t.apply(detail);
    expect(t.satellites, 15);
    expect(t.displaySatellites, 15);
    expect(t.gpsQuality, 4); // kept from 206 when 207[65] disagrees
    expect(t.gpsQualitySatsDisplay, 'Good - 15 sats');
    expect(t.gpsQualityDisplayTone, GpsQualityTone.green);
  });

  test('satellites 0 from 207 is kept (no fix yet)', () {
    final t = const FcTelemetry().apply(
      const KppGpsDetail(utcTime: 0, latE7: 0, lonE7: 0, gpsState: 1, rtkStatus: 0, gpsSats: 0),
    );
    expect(t.satellites, 0);
    expect(t.displaySatellites, 0);
    expect(t.gpsQualitySatsDisplay, 'No fix - 0 sats');
  });

  test('quality grades 0..5 map to observed labels and colours', () {
    const expected = <(int, String, GpsQualityTone)>[
      (0, 'Not connected', GpsQualityTone.grey),
      (1, 'No fix', GpsQualityTone.grey),
      (2, 'Poor', GpsQualityTone.amber),
      (3, 'Poor', GpsQualityTone.amber),
      (4, 'Good', GpsQualityTone.green),
      (5, 'RTK', GpsQualityTone.blue),
    ];
    for (final (q, label, tone) in expected) {
      expect(FcTelemetry.observedQualityLabel(q), label, reason: 'quality $q label');
      expect(FcTelemetry.observedQualityTone(q), tone, reason: 'quality $q tone');
      final t = FcTelemetry(
        gpsQuality: q,
        satellites: 14,
        gpsSatsReceivedAt: DateTime.now(),
        gpsAgriLinked: true,
      );
      expect(t.gpsQualityLabel, label);
      expect(t.gpsQualitySatsDisplay, '$label - 14 sats');
      expect(t.gpsQualityDisplayTone, tone);
    }
  });

  test('stale 207 (>3s) shows — for combined quality/sats display', () {
    final t = FcTelemetry(
      gpsQuality: 4,
      satellites: 14,
      gpsSatsReceivedAt: DateTime.now().subtract(const Duration(seconds: 4)),
      gpsAgriLinked: true,
    );
    expect(t.displaySatellites, isNull);
    expect(t.gpsQualitySatsDisplay, '—');
    expect(t.gpsQualityDisplayTone, GpsQualityTone.grey);
  });

  test('T145138 capture: while 206[2] in {2,3,4}, parsed 207 sats in 9..15', () {
    final file = _captureNamed('T145138');
    expect(file, isNotNull, reason: 'capture T145138… missing under Documents/FuselageKppCaptures');

    final qualities = <int>{};
    final sats = <int>{};
    int? lastQ;
    for (final line in file!.readAsLinesSync()) {
      if (line.trim().isEmpty) {
        continue;
      }
      final row = jsonDecode(line) as Map<String, dynamic>;
      final hx = row['payload_hex'] as String?;
      if (hx == null || hx.isEmpty) {
        continue;
      }
      final b = Uint8List.fromList([
        for (var i = 0; i + 1 < hx.length; i += 2) int.parse(hx.substring(i, i + 2), radix: 16),
      ]);
      final mid = row['msgid'] as int;
      if (mid == 206 && b.length >= 3) {
        lastQ = b[2];
      }
      if (mid == 207) {
        final msg = KppGpsDetail.tryParse(b);
        expect(msg, isNotNull);
        if (lastQ != null && lastQ >= 2 && lastQ <= 4) {
          qualities.add(lastQ);
          sats.add(msg!.gpsSats);
          expect(msg.gpsSats, inInclusiveRange(9, 15));
        }
      }
    }
    expect(qualities, containsAll([2, 3, 4]));
    expect(sats.isNotEmpty, isTrue);
  });

  test('T152806 capture: parsed 207 sats only 0 or 4..10', () {
    final file = _captureNamed('T152806');
    expect(file, isNotNull, reason: 'capture T152806… missing under Documents/FuselageKppCaptures');

    final sats = <int>{};
    for (final payload in _payloads(file!, 207)) {
      final msg = KppGpsDetail.tryParse(payload);
      expect(msg, isNotNull);
      sats.add(msg!.gpsSats);
      expect(
        msg.gpsSats == 0 || (msg.gpsSats >= 4 && msg.gpsSats <= 10),
        isTrue,
        reason: 'unexpected sats ${msg.gpsSats}',
      );
    }
    expect(sats.isNotEmpty, isTrue);
  });

  test('OBSERVATION (not protocol): 206[2] vs 207[73] co-occurrence table', () {
    final dir = _captureDir();
    expect(dir, isNotNull);

    final pairs = <String, int>{};
    for (final f in dir!.listSync().whereType<File>()) {
      if (!f.path.contains('kpp_wire_') || !f.path.endsWith('.jsonl') || f.lengthSync() == 0) {
        continue;
      }
      int? lastQ;
      for (final line in f.readAsLinesSync()) {
        if (line.trim().isEmpty) {
          continue;
        }
        final row = jsonDecode(line) as Map<String, dynamic>;
        final hx = row['payload_hex'] as String?;
        if (hx == null || hx.isEmpty) {
          continue;
        }
        final b = [
          for (var i = 0; i + 1 < hx.length; i += 2) int.parse(hx.substring(i, i + 2), radix: 16),
        ];
        final mid = row['msgid'] as int;
        if (mid == 206 && b.length >= 3) {
          lastQ = b[2];
        }
        if (mid == 207 && b.length == 75 && lastQ != null) {
          final key = '206[2]=$lastQ  207[73]=${b[73]}';
          pairs[key] = (pairs[key] ?? 0) + 1;
        }
      }
    }

    final sorted = pairs.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    // ignore: avoid_print
    print('\n=== OBSERVATION ONLY (not protocol fact): 206[2] vs 207[73] frame counts ===');
    // ignore: avoid_print
    print('${'pair'.padRight(28)} count');
    for (final e in sorted.take(40)) {
      // ignore: avoid_print
      print('${e.key.padRight(28)} ${e.value}');
    }
    // ignore: avoid_print
    print('=== end observation (${sorted.length} distinct pairs) ===\n');
    expect(sorted, isNotEmpty);
  });

  test('messageSpec decode matches tryParse on 75-byte buffer', () {
    final payload = Uint8List(75);
    payload[65] = 2;
    payload[69] = 0;
    payload[73] = 12;
    final viaTry = KppGpsDetail.tryParse(payload)!;
    final decoded = KppGpsDetail.messageSpec.decode(
      PayloadReader(payload, KppGpsDetail.payloadLength),
    ) as KppGpsDetail;
    expect(decoded.gpsSats, viaTry.gpsSats);
    expect(decoded.gpsState, 2);
    expect(decoded.gpsSats, 12);
  });
}
