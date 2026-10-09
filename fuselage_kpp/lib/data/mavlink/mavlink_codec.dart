import 'dart:typed_data';

import 'package:fuselage_kpp/data/mavlink/mavlink_crc.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/mavlink/payload_buffer.dart';

/// A decoded message plus the header of the serial frame that carried it.
class MavPacket {
  const MavPacket({required this.message, required this.systemId, required this.componentId, required this.sequence});

  final MavMessage message;
  final int systemId;
  final int componentId;
  final int sequence;
}

/// Cleartext K++ / MAVLink-1 frame layout (before USB wire obfuscation):
/// `EB | len | seq | sys | comp | msgid | payload | crc_lo | crc_hi`.
/// The leading `EB` is not part of the checksum. The checksum is the X.25
/// CRC of every following byte plus one extra byte chosen by the message id.
///
/// On the wire every byte is obfuscated as `rotl3(clear ^ 0xDF)`, so the
/// magic appears as `0xA1`. That transform is reversed from JIYI221014's
/// serial byte filter at 0x4388a0 / 0x4388c0.
const int serialFrameMagic = 0xEB;
const int serialWireKey = 0xDF;
const int _headerLength = 6;
const int _crcLength = 2;

int _rotl8(int value, int bits) => ((value << bits) | (value >> (8 - bits))) & 0xFF;

/// Obfuscate one clear MAVLink byte for the USB serial wire.
int encodeWireByte(int clear) => _rotl8(clear ^ serialWireKey, 3);

/// Read one wire byte back into clear MAVLink form.
int decodeWireByte(int wire) => _rotl8(wire, 5) ^ serialWireKey;

Uint8List encodeWireFrame(List<int> clearFrame) =>
    Uint8List.fromList([for (final b in clearFrame) encodeWireByte(b)]);

Uint8List decodeWireBytes(List<int> wireBytes) =>
    Uint8List.fromList([for (final b in wireBytes) decodeWireByte(b)]);

/// Builds K++ serial frames for outgoing messages.
class MavFrameEncoder {
  MavFrameEncoder({required this.systemId, required this.componentId});

  final int systemId;
  final int componentId;
  int _sequence = 0;

  Uint8List encode(MavMessage message) {
    final spec = message.spec;
    final payload = message.encodePayload();
    final header = [serialFrameMagic, payload.length, _sequence, systemId, componentId, spec.id];
    _sequence = (_sequence + 1) & 0xFF;

    final crc = x25Crc([...header.skip(1), ...payload, spec.crcExtra]);
    final clear = [...header, ...payload, crc & 0xFF, crc >> 8];
    return encodeWireFrame(clear);
  }
}

/// Turns an arbitrary byte stream into validated K++ serial frames.
///
/// Frames with unknown message ids are skipped, because their checksum
/// cannot be verified without that message's extra byte.
class MavFrameParser {
  final List<int> _buffer = [];
  int _rejectedFrames = 0;

  /// Frames dropped because of a bad checksum or unknown message id.
  int get rejectedFrames => _rejectedFrames;

  List<MavPacket> addBytes(List<int> bytes) {
    _buffer.addAll(decodeWireBytes(bytes));
    final packets = <MavPacket>[];
    while (true) {
      final start = _buffer.indexOf(serialFrameMagic);
      if (start < 0) {
        _buffer.clear();
        break;
      }
      if (start > 0) {
        _buffer.removeRange(0, start);
      }
      final frameLength = _completeFrameLength();
      if (frameLength == null) {
        break;
      }
      final packet = _decodeFrame(frameLength);
      if (packet == null) {
        _rejectedFrames++;
        _buffer.removeAt(0);
      } else {
        packets.add(packet);
        _buffer.removeRange(0, frameLength);
      }
    }
    return packets;
  }

  int? _completeFrameLength() {
    if (_buffer.length < 2) {
      return null;
    }
    final length = _headerLength + _buffer[1] + _crcLength;
    return _buffer.length >= length ? length : null;
  }

  MavPacket? _decodeFrame(int frameLength) {
    final payloadLength = _buffer[1];
    final messageId = _buffer[5];
    final spec = mavMessageSpecs[messageId];
    if (spec == null || payloadLength > spec.fullLength) {
      return null;
    }

    final crcEnd = _headerLength + payloadLength;
    final expected = x25Crc([..._buffer.sublist(1, crcEnd), spec.crcExtra]);
    final received = _buffer[crcEnd] | (_buffer[crcEnd + 1] << 8);
    if (expected != received) {
      return null;
    }

    final payload = Uint8List.fromList(_buffer.sublist(_headerLength, crcEnd));
    return MavPacket(
      message: spec.decode(PayloadReader(payload, spec.fullLength)),
      sequence: _buffer[2],
      systemId: _buffer[3],
      componentId: _buffer[4],
    );
  }
}
