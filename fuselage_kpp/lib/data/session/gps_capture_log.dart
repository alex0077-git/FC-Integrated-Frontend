import 'dart:convert';
import 'dart:io';

import 'package:fuselage_kpp/data/mavlink/mavlink_codec.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';

/// Always-on GPS wire logger (Documents/FuselageKppCaptures).
///
/// Previous ENABLE-file logging never fired because Flutter's CWD is the build
/// folder, not the repo — so we guessed layouts blind. This writes raw msgid +
/// payload hex from every GPS-related frame so we can match the assistant.
class GpsCaptureLog {
  GpsCaptureLog._();

  static IOSink? _sink;
  static bool _ready = false;
  static String? capturePath;

  static final _gpsIds = {1, 24, 25, 33, 66, 124, 203, 204, 205, 206, 207, 211, 220};

  /// Call once on connect; safe to call repeatedly.
  static void ensureStarted() {
    if (_ready) {
      return;
    }
    _ready = true;
    try {
      final dir = _captureDir()..createSync(recursive: true);
      final stamp = DateTime.now().toLocal().toIso8601String().replaceAll(':', '').replaceAll('.', '');
      final file = File('${dir.path}${Platform.pathSeparator}kpp_wire_$stamp.jsonl');
      _sink = file.openWrite(mode: FileMode.writeOnlyAppend);
      capturePath = file.path;
      // ignore: avoid_print
      print('K++ GPS wire capture -> ${file.path}');
    } catch (error) {
      // ignore: avoid_print
      print('K++ GPS wire capture failed: $error');
      _sink = null;
    }
  }

  static Directory _captureDir() {
    final env = Platform.environment['KPP_GPS_CAPTURE_DIR'];
    if (env != null && env.isNotEmpty) {
      return Directory(env);
    }
    final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? Directory.systemTemp.path;
    return Directory('$home${Platform.pathSeparator}Documents${Platform.pathSeparator}FuselageKppCaptures');
  }

  static void logPacket(String direction, MavPacket packet) {
    ensureStarted();
    final sink = _sink;
    if (sink == null) {
      return;
    }
    final id = packet.messageId;
    if (!_gpsIds.contains(id) && id < 200) {
      return;
    }
    final rec = <String, Object?>{
      't': DateTime.now().toUtc().toIso8601String(),
      'dir': direction,
      'msgid': id,
      'sys': packet.systemId,
      'comp': packet.componentId,
      'payload_hex': packet.rawPayload == null
          ? null
          : packet.rawPayload!.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      'fields': _fields(packet.message),
    };
    sink.writeln(jsonEncode(rec));
  }

  static void logRawFrame({
    required String direction,
    required int msgid,
    required int sys,
    required int comp,
    required List<int> payload,
    required bool crcOk,
  }) {
    ensureStarted();
    final sink = _sink;
    if (sink == null) {
      return;
    }
    if (!_gpsIds.contains(msgid) && msgid < 200) {
      return;
    }
    sink.writeln(
      jsonEncode({
        't': DateTime.now().toUtc().toIso8601String(),
        'dir': direction,
        'msgid': msgid,
        'sys': sys,
        'comp': comp,
        'crc_ok': crcOk,
        'payload_hex': payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      }),
    );
  }

  static Map<String, Object?> _fields(MavMessage message) {
    return switch (message) {
      GpsRawInt(:final latE7, :final lonE7, :final altMm, :final eph, :final fixType, :final satellites) => {
          'lat_e7': latE7,
          'lon_e7': lonE7,
          'alt_mm': altMm,
          'eph': eph,
          'fix': fixType,
          'sats': satellites,
        },
      GpsStatus(:final satellitesVisible) => {'sats': satellitesVisible},
      Gps2Raw(:final latE7, :final lonE7, :final altMm, :final eph, :final fixType, :final satellites) => {
          'lat_e7': latE7,
          'lon_e7': lonE7,
          'alt_mm': altMm,
          'eph': eph,
          'fix': fixType,
          'sats': satellites,
        },
      GlobalPositionInt(:final latE7, :final lonE7, :final altMm, :final relativeAltMm) => {
          'lat_e7': latE7,
          'lon_e7': lonE7,
          'alt_mm': altMm,
          'relative_alt_mm': relativeAltMm,
        },
      KppGpsPosition(
        :final latE7,
        :final lonE7,
        :final altMm,
        :final status,
        :final fixType,
        :final satellites,
        :final fixType2,
        :final satellites2,
      ) => {
          'lat_e7': latE7,
          'lon_e7': lonE7,
          'alt_mm': altMm,
          'status': status,
          'gps1_fix': fixType,
          'gps1_sats': satellites,
          'gps2_fix': fixType2,
          'gps2_sats': satellites2,
        },
      KppGpsStatus(:final fixType, :final satellites, :final fixType2, :final satellites2) => {
          'gps1_fix': fixType,
          'gps_quality': satellites,
          'gps2_fix': fixType2,
          'gps2_sats': satellites2,
        },
      KppGpsDetail(:final utcTime, :final latE7, :final lonE7, :final gpsState, :final rtkStatus, :final gpsSats) => {
          'utc_time': utcTime,
          'lat_e7': latE7,
          'lon_e7': lonE7,
          'gps_state': gpsState,
          'rtk_status': rtkStatus,
          'gps_sats': gpsSats,
        },
      RequestDataStream(:final rateHz, :final streamId, :final targetSystem, :final targetComponent, :final start) => {
          'rate_hz': rateHz,
          'stream_id': streamId,
          'target_system': targetSystem,
          'target_component': targetComponent,
          'start': start,
        },
      UnknownMavMessage(:final messageId, :final payload) => {
          'unknown': true,
          'msgid': messageId,
          'len': payload.length,
        },
      _ => {'type': message.runtimeType.toString()},
    };
  }

  static Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
    _ready = false;
  }
}
