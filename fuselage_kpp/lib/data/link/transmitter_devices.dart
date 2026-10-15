import 'package:fuselage_kpp/data/link/serial_fc_link.dart';

/// A transmitter candidate the app can open over Bluetooth serial (SPP / COM).
///
/// On Windows/Android, many agri remotes appear as a Bluetooth serial port after
/// OS pairing. Pick that port — the app then sends the same MAVLink commands
/// through the transmitter path.
class TransmitterBluetoothDevice {
  const TransmitterBluetoothDevice({
    required this.id,
    required this.name,
    required this.detail,
  });

  /// COM port name (e.g. COM5) used to open the serial pipe.
  final String id;
  final String name;
  final String detail;
}

/// Lists Bluetooth-looking serial ports (paired transmitter SPP).
///
/// Pair the transmitter in Windows/Android Bluetooth settings first, then
/// refresh. Non-Bluetooth COM ports are omitted so USB FC cables stay under
/// the USB Connect section.
List<TransmitterBluetoothDevice> listBluetoothTransmitterPorts([
  List<SerialPortInfo> Function()? portLister,
]) {
  final ports = (portLister ?? SerialPortInfo.available)();
  final matches = <TransmitterBluetoothDevice>[];
  for (final port in ports) {
    if (!isBluetoothSerialPort(port)) {
      continue;
    }
    matches.add(
      TransmitterBluetoothDevice(
        id: port.name,
        name: port.description.isEmpty ? port.name : port.description,
        detail: port.name,
      ),
    );
  }
  return matches;
}

/// All COM ports — fallback when the OS does not tag the TX as "Bluetooth".
List<TransmitterBluetoothDevice> listSerialPortsAsBluetoothCandidates([
  List<SerialPortInfo> Function()? portLister,
]) {
  final ports = (portLister ?? SerialPortInfo.available)();
  return [
    for (final port in ports)
      TransmitterBluetoothDevice(
        id: port.name,
        name: port.description.isEmpty ? port.name : port.description,
        detail: port.name,
      ),
  ];
}

/// True when [port] looks like a Bluetooth SPP / RFCOMM virtual COM.
bool isBluetoothSerialPort(SerialPortInfo port) {
  final text = '${port.name} ${port.description}'.toLowerCase();
  return text.contains('bluetooth') ||
      text.contains('bth') ||
      text.contains('bt ') ||
      text.contains('standard serial over bluetooth') ||
      text.contains('rfcomm') ||
      text.contains('spp');
}
