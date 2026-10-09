import 'dart:typed_data';

/// Minimal DataFlash parser: extract GPS track and altitude/voltage samples
/// from FMT + GPS/ATT/CURR (or BAT) messages when present.
class DataflashSummary {
  const DataflashSummary({required this.track, required this.altitudes, required this.voltages});

  final List<(double lat, double lon)> track;
  final List<(int ms, double alt)> altitudes;
  final List<(int ms, double volts)> voltages;

  static DataflashSummary parse(Uint8List bytes) {
    final track = <(double, double)>[];
    final altitudes = <(int, double)>[];
    final voltages = <(int, double)>[];

    // FMT: 0xA3 0x95 type=0x80, then type, length, name[4], format[16], labels…
    // GPS: look for messages named GPS with format containing L for lat/lon.
    final formats = <int, _Fmt>{};
    var i = 0;
    while (i + 3 < bytes.length) {
      if (bytes[i] != 0xA3 || bytes[i + 1] != 0x95) {
        i++;
        continue;
      }
      final type = bytes[i + 2];
      if (type == 0x80 && i + 89 <= bytes.length) {
        // FMT records are fixed 89 bytes; byte 4 is the described message length.
        const fmtRecordLength = 89;
        final msgType = bytes[i + 3];
        final length = bytes[i + 4];
        final name = String.fromCharCodes(bytes.sublist(i + 5, i + 9)).replaceAll('\u0000', '').trim();
        final format = String.fromCharCodes(bytes.sublist(i + 9, i + 25)).replaceAll('\u0000', '');
        formats[msgType] = _Fmt(name: name, length: length, format: format);
        i += fmtRecordLength;
        continue;
      }
      final fmt = formats[type];
      if (fmt == null || i + fmt.length > bytes.length) {
        i++;
        continue;
      }
      final payload = bytes.sublist(i + 3, i + fmt.length);
      _extract(fmt, payload, track, altitudes, voltages);
      i += fmt.length;
    }

    return DataflashSummary(track: track, altitudes: altitudes, voltages: voltages);
  }

  static void _extract(
    _Fmt fmt,
    Uint8List payload,
    List<(double, double)> track,
    List<(int, double)> altitudes,
    List<(int, double)> voltages,
  ) {
    final name = fmt.name.toUpperCase();
    final data = ByteData.sublistView(payload);
    var offset = 0;
    int? timeMs;
    double? lat;
    double? lon;
    double? alt;
    double? volts;

    for (var c = 0; c < fmt.format.length; c++) {
      final ch = fmt.format[c];
      if (offset >= payload.length) {
        break;
      }
      switch (ch) {
        case 'b':
        case 'M':
          offset += 1;
        case 'B':
          offset += 1;
        case 'h':
        case 'c':
          offset += 2;
        case 'H':
        case 'C':
          if (offset + 2 <= payload.length && name.contains('GPS') && timeMs == null) {
            // ignore
          }
          offset += 2;
        case 'i':
        case 'L':
          if (offset + 4 <= payload.length) {
            final v = data.getInt32(offset, Endian.little);
            if (ch == 'L') {
              if (lat == null) {
                lat = v / 1e7;
              } else if (lon == null) {
                lon = v / 1e7;
              }
            }
            if (name.contains('ATT') && alt == null && ch == 'i') {
              // skip
            }
          }
          offset += 4;
        case 'I':
        case 'e':
          if (offset + 4 <= payload.length) {
            final v = data.getUint32(offset, Endian.little);
            timeMs ??= v;
          }
          offset += 4;
        case 'f':
          if (offset + 4 <= payload.length) {
            final v = data.getFloat32(offset, Endian.little);
            if (name.contains('ATT') || name.contains('GPS')) {
              alt ??= v;
            }
            if (name.contains('CURR') || name.contains('BAT')) {
              volts ??= v;
            }
          }
          offset += 4;
        case 'n':
        case 'N':
        case 'Z':
          offset += ch == 'n'
              ? 4
              : ch == 'N'
              ? 16
              : 64;
        case 'q':
        case 'Q':
          offset += 8;
        default:
          offset += 1;
      }
    }

    if (lat != null && lon != null && lat.abs() > 0.1 && lon.abs() > 0.1) {
      track.add((lat, lon));
    }
    if (alt != null) {
      altitudes.add((timeMs ?? altitudes.length, alt));
    }
    if (volts != null && volts > 5 && volts < 100) {
      voltages.add((timeMs ?? voltages.length, volts));
    }
  }
}

class _Fmt {
  const _Fmt({required this.name, required this.length, required this.format});

  final String name;
  final int length;
  final String format;
}
