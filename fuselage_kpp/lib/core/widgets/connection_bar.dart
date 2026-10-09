import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/theme/app_theme.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/link/serial_fc_link.dart';
import 'package:fuselage_kpp/data/link/transmitter_devices.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/session/fc_session.dart';

/// Top bar: pick the USB serial port and baud rate (or the simulator),
/// connect, and see the link status. Optional wireless MAVLink is an add-on.
class ConnectionBar extends ConsumerStatefulWidget {
  const ConnectionBar({super.key});

  static const String simulatorOption = 'Simulator';

  @override
  ConsumerState<ConnectionBar> createState() => _ConnectionBarState();
}

class _ConnectionBarState extends ConsumerState<ConnectionBar> {
  List<SerialPortInfo> _ports = const [];
  String _selectedPort = ConnectionBar.simulatorOption;
  int _baudRate = ConnectionSettings.defaultBaudRate;
  bool _showTransmitter = false;
  List<TransmitterBluetoothDevice> _btDevices = const [];
  String? _selectedBtId;
  final _wifiHost = TextEditingController(text: '192.168.4.1');
  final _wifiPort = TextEditingController(text: '${ConnectionSettings.defaultTcpPort}');

  @override
  void initState() {
    super.initState();
    _refreshPorts();
    _refreshBluetooth();
  }

  @override
  void dispose() {
    _wifiHost.dispose();
    _wifiPort.dispose();
    super.dispose();
  }

  void _refreshBluetooth() {
    final devices = listBluetoothTransmitterPorts(ref.read(serialPortListerProvider));
    final fallback = devices.isEmpty
        ? listSerialPortsAsBluetoothCandidates(ref.read(serialPortListerProvider))
        : devices;
    setState(() {
      _btDevices = fallback;
      if (_selectedBtId == null || !fallback.any((d) => d.id == _selectedBtId)) {
        _selectedBtId = fallback.isEmpty ? null : fallback.first.id;
      }
    });
  }

  void _refreshPorts() {
    final ports = ref.read(serialPortListerProvider)();
    setState(() {
      _ports = ports;
      final stillPresent = ports.any((p) => p.name == _selectedPort);
      if (!stillPresent) {
        _selectedPort = ports.isEmpty ? ConnectionBar.simulatorOption : ports.first.name;
      }
    });
  }

  ConnectionSettings get _settings => _selectedPort == ConnectionBar.simulatorOption
      ? const ConnectionSettings(useSimulator: true)
      : ConnectionSettings(useSimulator: false, portName: _selectedPort, baudRate: _baudRate);

  Future<void> _connectBluetooth() async {
    final id = _selectedBtId;
    if (id == null) {
      return;
    }
    await ref.read(fcConnectionProvider.notifier).connect(
      ConnectionSettings.bluetooth(portName: id),
    );
  }

  Future<void> _connectWifiTcp() async {
    final host = _wifiHost.text.trim();
    if (host.isEmpty) {
      return;
    }
    final port = int.tryParse(_wifiPort.text.trim()) ?? ConnectionSettings.defaultTcpPort;
    await ref.read(fcConnectionProvider.notifier).connect(
      ConnectionSettings.tcpHost(host: host, remotePort: port),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(fcConnectionProvider);
    final controller = ref.read(fcConnectionProvider.notifier);
    final editable = !connection.hasSession && !connection.isBusy;
    final isSerial = _selectedPort != ConnectionBar.simulatorOption;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const Border(bottom: BorderSide(color: AppCard.borderColor)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _LabeledDropdown<String>(
                  label: 'Port',
                  value: _selectedPort,
                  enabled: editable,
                  items: {
                    for (final port in _ports) port.name: '${port.name}  ${port.description}',
                    ConnectionBar.simulatorOption: 'Simulator (no hardware)',
                  },
                  onChanged: (value) => setState(() => _selectedPort = value),
                ),
                IconButton(
                  tooltip: 'Refresh COM ports',
                  onPressed: editable ? _refreshPorts : null,
                  icon: const Icon(Icons.refresh),
                ),
                if (isSerial) ...[
                  _LabeledDropdown<int>(
                    label: 'Baud',
                    value: _baudRate,
                    enabled: editable,
                    items: {for (final baud in ConnectionSettings.baudRates) baud: '$baud'},
                    onChanged: (value) => setState(() => _baudRate = value),
                  ),
                ],
                if (connection.hasSession || connection.isBusy)
                  OutlinedButton.icon(
                    onPressed: connection.status == FcLinkStatus.connecting ? null : controller.disconnect,
                    icon: const Icon(Icons.link_off),
                    label: const Text('Disconnect'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => controller.connect(_settings),
                    icon: const Icon(Icons.link),
                    label: const Text('Connect'),
                  ),
                TextButton(
                  onPressed: editable
                      ? () => setState(() => _showTransmitter = !_showTransmitter)
                      : null,
                  child: Text(_showTransmitter ? 'Hide transmitter' : 'Transmitter BT/WiFi'),
                ),
                _StatusChip(state: connection),
              ],
            ),
            if (_showTransmitter && editable) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (_selectedBtId != null && _btDevices.isNotEmpty)
                    _LabeledDropdown<String>(
                      label: 'BT',
                      value: _selectedBtId!,
                      enabled: editable,
                      items: {
                        for (final d in _btDevices) d.id: '${d.name} (${d.detail})',
                      },
                      onChanged: (value) => setState(() => _selectedBtId = value),
                    )
                  else
                    Text(
                      'No BT serial port — pair TX then refresh',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  IconButton(
                    tooltip: 'Refresh Bluetooth ports',
                    onPressed: _refreshBluetooth,
                    icon: const Icon(Icons.refresh),
                  ),
                  OutlinedButton.icon(
                    onPressed: _selectedBtId == null ? null : _connectBluetooth,
                    icon: const Icon(Icons.bluetooth),
                    label: const Text('Bluetooth'),
                  ),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      controller: _wifiHost,
                      decoration: const InputDecoration(
                        labelText: 'TX WiFi IP',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _wifiPort,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'TCP',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _connectWifiTcp,
                    icon: const Icon(Icons.wifi),
                    label: const Text('WiFi'),
                  ),
                ],
              ),
            ],
            if (connection.status == FcLinkStatus.loadingParameters) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: connection.paramsTotal == 0 ? null : connection.paramsReceived / connection.paramsTotal,
              ),
            ],
            if (connection.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                connection.errorMessage!,
                style: TextStyle(
                  color: (Theme.of(context).extension<AppStatusColors>() ?? AppStatusColors.dark)
                      .statusCritical,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final bool enabled;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: Theme.of(context).textTheme.bodySmall),
        DropdownButton<T>(
          value: value,
          underline: const SizedBox.shrink(),
          items: [for (final entry in items.entries) DropdownMenuItem(value: entry.key, child: Text(entry.value))],
          onChanged: enabled ? (v) => v == null ? null : onChanged(v) : null,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.state});

  final FcConnectionState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppStatusColors>() ?? AppStatusColors.dark;
    final (label, color) = switch (state.status) {
      FcLinkStatus.disconnected => ('Disconnected', Colors.grey),
      FcLinkStatus.connecting => ('Connecting…', colors.statusWarning),
      FcLinkStatus.loadingParameters => (
        'Reading parameters ${state.paramsReceived}/${state.paramsTotal}',
        colors.statusWarning,
      ),
      FcLinkStatus.connected => ('Connected · ${state.session?.linkLabel}', colors.statusGood),
      FcLinkStatus.linkLost => ('Link lost · ${state.session?.linkLabel}', colors.statusCritical),
    };
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 5),
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.6)),
    );
  }
}
