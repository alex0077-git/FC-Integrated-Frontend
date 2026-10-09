/// Suggested transmitter / gateway IP for the WiFi Connect field.
Future<String?> detectDefaultGatewayIp() async => null;

/// Local IPv4 addresses currently assigned to this machine.
Future<List<String>> detectLocalIpv4Addresses() async => const [];

const List<int> kCommonMavlinkTcpPorts = [5760, 5761, 14550, 14551, 8080];
const List<int> kCommonMavlinkUdpPorts = [14550, 14551, 14555];

const String kSkydroidG20HotspotIp = '192.168.43.1';
const int kSkydroidG20MavlinkTcpPort = 5760;

bool looksLikeSkydroidG20Hotspot(String? gateway) => false;
