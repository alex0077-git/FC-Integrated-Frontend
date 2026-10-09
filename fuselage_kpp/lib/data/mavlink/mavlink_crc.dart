/// CRC-16/MCRF4XX ("X.25") checksum used by every MAVLink frame.
int x25Crc(Iterable<int> bytes, [int crc = 0xFFFF]) {
  var value = crc;
  for (final byte in bytes) {
    var tmp = (byte ^ (value & 0xFF)) & 0xFF;
    tmp = (tmp ^ (tmp << 4)) & 0xFF;
    value = ((value >> 8) ^ (tmp << 8) ^ (tmp << 3) ^ (tmp >> 4)) & 0xFFFF;
  }
  return value;
}
