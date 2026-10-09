import 'dart:io';

/// Reads the active IPv4 default gateway (often the transmitter AP when joined to its WiFi).
Future<String?> detectDefaultGatewayIp() async {
  try {
    if (Platform.isWindows) {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        r"(Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1).IPv4DefaultGateway.NextHop",
      ]);
      if (result.exitCode == 0) {
        final text = (result.stdout as String).trim();
        if (_looksLikeIpv4(text)) {
          return text;
        }
      }
    } else if (Platform.isLinux || Platform.isMacOS) {
      final result = await Process.run('sh', [
        '-c',
        r"ip route 2>/dev/null | awk '/default/ {print $3; exit}' || route -n get default 2>/dev/null | awk '/gateway:/ {print $2; exit}'",
      ]);
      if (result.exitCode == 0) {
        final text = (result.stdout as String).trim();
        if (_looksLikeIpv4(text)) {
          return text;
        }
      }
    }
  } catch (_) {}
  return null;
}

/// Local IPv4 addresses currently assigned to this machine.
Future<List<String>> detectLocalIpv4Addresses() async {
  final addresses = <String>[];
  try {
    for (final iface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback && _looksLikeIpv4(addr.address)) {
          addresses.add(addr.address);
        }
      }
    }
  } catch (_) {}
  return addresses;
}

bool _looksLikeIpv4(String value) {
  final parts = value.split('.');
  if (parts.length != 4) {
    return false;
  }
  for (final part in parts) {
    final n = int.tryParse(part);
    if (n == null || n < 0 || n > 255) {
      return false;
    }
  }
  return true;
}

/// Common MAVLink ports used by WiFi radios / TX modules.
const List<int> kCommonMavlinkTcpPorts = [5760, 5761, 14550, 14551, 8080];
const List<int> kCommonMavlinkUdpPorts = [14550, 14551, 14555];

/// Skydroid G20 WLAN hotspot → Mission Planner TCP share (official manual).
const String kSkydroidG20HotspotIp = '192.168.43.1';
const int kSkydroidG20MavlinkTcpPort = 5760;

/// G20 (and similar Android remotes) use 192.168.43.1 as their WLAN hotspot gateway.
bool looksLikeSkydroidG20Hotspot(String? gateway) {
  if (gateway == null) {
    return false;
  }
  return gateway == kSkydroidG20HotspotIp || gateway.startsWith('192.168.43.');
}
