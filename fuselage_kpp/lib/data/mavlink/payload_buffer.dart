import 'dart:convert';
import 'dart:typed_data';

/// Little-endian payload writer. Fields must be written in MAVLink wire
/// order (largest types first), which is how the message classes call it.
class PayloadWriter {
  PayloadWriter(int length) : _data = ByteData(length);

  final ByteData _data;
  int _offset = 0;

  void u8(int value) => _data.setUint8(_advance(1), value);
  void i8(int value) => _data.setInt8(_advance(1), value);
  void u16(int value) => _data.setUint16(_advance(2), value, Endian.little);
  void i16(int value) => _data.setInt16(_advance(2), value, Endian.little);
  void u32(int value) => _data.setUint32(_advance(4), value, Endian.little);
  void i32(int value) => _data.setInt32(_advance(4), value, Endian.little);
  void u64(int value) => _data.setUint64(_advance(8), value, Endian.little);
  void f32(double value) => _data.setFloat32(_advance(4), value, Endian.little);

  void chars(String value, int length) {
    final start = _advance(length);
    final encoded = ascii.encode(value);
    for (var i = 0; i < length && i < encoded.length; i++) {
      _data.setUint8(start + i, encoded[i]);
    }
  }

  void bytes(List<int> value, int length) {
    final start = _advance(length);
    for (var i = 0; i < length && i < value.length; i++) {
      _data.setUint8(start + i, value[i]);
    }
  }

  Uint8List toBytes() => _data.buffer.asUint8List();

  int _advance(int size) {
    final start = _offset;
    _offset += size;
    return start;
  }
}

/// Little-endian payload reader. The payload is zero-extended to the
/// message's full length first, because MAVLink v2 trims trailing zeros.
class PayloadReader {
  PayloadReader(Uint8List payload, int fullLength) : _data = ByteData.sublistView(_zeroExtend(payload, fullLength));

  final ByteData _data;
  int _offset = 0;

  int u8() => _data.getUint8(_advance(1));
  int i8() => _data.getInt8(_advance(1));
  int u16() => _data.getUint16(_advance(2), Endian.little);
  int i16() => _data.getInt16(_advance(2), Endian.little);
  int u32() => _data.getUint32(_advance(4), Endian.little);
  int i32() => _data.getInt32(_advance(4), Endian.little);
  int u64() => _data.getUint64(_advance(8), Endian.little);
  double f32() => _data.getFloat32(_advance(4), Endian.little);

  String chars(int length) {
    final start = _advance(length);
    final raw = Uint8List.sublistView(_data, start, start + length);
    final end = raw.indexOf(0);
    return ascii.decode(end < 0 ? raw : raw.sublist(0, end), allowInvalid: true);
  }

  Uint8List bytes(int length) {
    final start = _advance(length);
    return Uint8List.fromList(Uint8List.sublistView(_data, start, start + length));
  }

  int _advance(int size) {
    final start = _offset;
    _offset += size;
    return start;
  }

  static Uint8List _zeroExtend(Uint8List payload, int fullLength) {
    if (payload.length >= fullLength) {
      return payload;
    }
    return Uint8List(fullLength)..setRange(0, payload.length, payload);
  }
}
