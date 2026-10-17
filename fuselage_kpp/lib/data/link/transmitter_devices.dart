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
    this.outgoing = false,
  });

  /// COM port name (e.g. COM5) used to open the serial pipe.
  final String id;
  final String name;
  final String detail;

  /// Windows PC→device client SPP (preferred). Incoming often semaphore-timeouts.
  final bool outgoing;
}

/// Lists Bluetooth-looking serial ports (paired transmitter SPP).
///
/// Order: Outgoing first, then higher COM numbers. Windows often creates
/// Incoming (lower) + Outgoing (higher); the PC→TX client path is Outgoing.
/// Opening Incoming commonly hangs then fails with "semaphore timeout".
List<TransmitterBluetoothDevice> listBluetoothTransmitterPorts([
  List<SerialPortInfo> Function()? portLister,
]) {
  final ports = (portLister ?? SerialPortInfo.available)();
  final btPorts = ports.where(isBluetoothSerialPort).toList();
  final matches = <TransmitterBluetoothDevice>[];
  for (final port in btPorts) {
    final outgoing = isBluetoothOutgoingPort(port, btPorts);
    final base = port.description.isEmpty ? port.name : port.description;
    matches.add(
      TransmitterBluetoothDevice(
        id: port.name,
        name: outgoing ? '$base · Outgoing' : '$base · Incoming',
        detail: port.name,
        outgoing: outgoing,
      ),
    );
  }
  matches.sort((a, b) {
    final byDir = (b.outgoing ? 1 : 0).compareTo(a.outgoing ? 1 : 0);
    if (byDir != 0) {
      return byDir;
    }
    return comPortNumber(b.id).compareTo(comPortNumber(a.id));
  });
  return matches;
}

/// Heuristic: higher COM among BT siblings, or description/mac hints.
bool isBluetoothOutgoingPort(SerialPortInfo port, [List<SerialPortInfo>? btSiblings]) {
  final text = '${port.name} ${port.description} ${port.macAddress ?? ''}'.toLowerCase();
  if (text.contains('outgoing')) {
    return true;
  }
  if (text.contains('incoming')) {
    return false;
  }
  final siblings = btSiblings ?? [port];
  if (siblings.length <= 1) {
    // Sole Windows SPP for a paired TX is almost always the Outgoing client port.
    return true;
  }
  final maxCom = siblings.map((p) => comPortNumber(p.name)).fold<int>(-1, (a, b) => a > b ? a : b);
  return comPortNumber(port.name) == maxCom;
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

/// Windows Incoming vs Outgoing: prefer an Outgoing BT COM when several exist.
SerialPortInfo preferredBluetoothSerialPort(
  SerialPortInfo selected,
  List<SerialPortInfo> allPorts,
) {
  final siblings = allPorts.where(isBluetoothSerialPort).toList();
  siblings.sort((a, b) {
    final byDir = (isBluetoothOutgoingPort(b, siblings) ? 1 : 0)
        .compareTo(isBluetoothOutgoingPort(a, siblings) ? 1 : 0);
    if (byDir != 0) {
      return byDir;
    }
    return comPortNumber(b.name).compareTo(comPortNumber(a.name));
  });
  if (siblings.isEmpty) {
    return selected;
  }
  return siblings.first;
}

/// Sibling BT COM (next after [portName] in Outgoing-first order), if any.
String? alternateBluetoothComName(
  String portName, [
  List<SerialPortInfo> Function()? portLister,
]) {
  for (final device in listBluetoothTransmitterPorts(portLister)) {
    if (device.id != portName) {
      return device.id;
    }
  }
  return null;
}

int comPortNumber(String name) {
  final match = RegExp(r'(\d+)\s*$').firstMatch(name.trim());
  return match == null ? -1 : int.tryParse(match.group(1)!) ?? -1;
}
