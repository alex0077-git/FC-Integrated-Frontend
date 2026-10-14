import 'package:fc_frontend/core/theme/app_theme.dart';
import 'package:fc_frontend/l10n/app_localizations.dart';
import 'package:fc_frontend/core/widgets/command_result.dart';
import 'package:fc_frontend/data/repositories/telemetry_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/link/serial_fc_link.dart';
import 'package:fuselage_kpp/data/link/transmitter_devices.dart';
import 'package:fuselage_kpp/data/link/wifi_network_info.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/session/fc_session.dart';

enum _TxTransport { bluetooth, wifi }

enum _WifiMode { tcp, udpHost, udpListen }

/// Live USB to K++ on the ground, plus transmitter Bluetooth / WiFi for airborne.
class ConnectPanel extends ConsumerStatefulWidget {
  const ConnectPanel({super.key});

  @override
  ConsumerState<ConnectPanel> createState() => _ConnectPanelState();
}

class _ConnectPanelState extends ConsumerState<ConnectPanel> {
  List<SerialPortInfo> _ports = const [];
  String? _selectedPort;
  int _baudRate = ConnectionSettings.defaultBaudRate;
  bool _loadingPorts = false;

  _TxTransport _txTransport = _TxTransport.bluetooth;
  List<TransmitterBluetoothDevice> _btDevices = const [];
  String? _selectedBtId;
  bool _showAllComAsBt = false;
  int _btBaud = ConnectionSettings.defaultBaudRate;

  _WifiMode _wifiMode = _WifiMode.tcp;
  final _hostController = TextEditingController(text: '192.168.4.1');
  final _remotePortController = TextEditingController(
    text: '${ConnectionSettings.defaultTcpPort}',
  );
  final _localPortController = TextEditingController(
    text: '${ConnectionSettings.defaultUdpListenPort}',
  );
  String? _wifiNetworkHint;
  bool _wifiProbing = false;

  @override
  void initState() {
    super.initState();
    _refreshPorts();
    _refreshBluetooth();
    _refreshWifiNetworkHint();
  }

  Future<void> _refreshWifiNetworkHint() async {
    if (kIsWeb) {
      return;
    }
    final gateway = await detectDefaultGatewayIp();
    final locals = await detectLocalIpv4Addresses();
    if (!mounted) {
      return;
    }
    setState(() {
      if (gateway != null) {
        final g20 = looksLikeSkydroidG20Hotspot(gateway);
        _wifiNetworkHint = g20
            ? 'Skydroid G20 hotspot detected ($gateway'
                '${locals.isEmpty ? '' : ', you: ${locals.first}'}). '
                'Use TCP 192.168.43.1 port 5760 (not UDP 14550). Tap “G20 preset” then Connect.'
            : 'This PC is on WiFi gateway $gateway'
                '${locals.isEmpty ? '' : ' (you: ${locals.first})'}. '
                'If that is the transmitter, tap “Use gateway IP”, then Connect or Auto-try.';
        if (g20 ||
            _hostController.text.trim() == '192.168.4.1' ||
            _hostController.text.trim() == gateway) {
          _hostController.text = g20 ? kSkydroidG20HotspotIp : gateway;
        }
        if (g20) {
          _wifiMode = _WifiMode.tcp;
          _remotePortController.text = '$kSkydroidG20MavlinkTcpPort';
        }
      } else {
        _wifiNetworkHint =
            'Could not read WiFi gateway. For Skydroid G20: join its WLAN hotspot, '
            'then tap “G20 preset” (TCP 192.168.43.1:5760).';
      }
    });
  }

  void _applyG20Preset() {
    setState(() {
      _txTransport = _TxTransport.wifi;
      _wifiMode = _WifiMode.tcp;
      _hostController.text = kSkydroidG20HotspotIp;
      _remotePortController.text = '$kSkydroidG20MavlinkTcpPort';
      _wifiNetworkHint =
          'G20 preset: TCP $kSkydroidG20HotspotIp:$kSkydroidG20MavlinkTcpPort. '
          'On the G20 enable WLAN hotspot + data sharing, aircraft powered, then Connect.';
    });
  }

  @override
  void dispose() {
    _hostController.dispose();
    _remotePortController.dispose();
    _localPortController.dispose();
    super.dispose();
  }

  void _refreshPorts() {
    if (kIsWeb) {
      setState(() {
        _ports = const [];
        _selectedPort = null;
        _loadingPorts = false;
      });
      return;
    }
    setState(() => _loadingPorts = true);
    List<SerialPortInfo> ports = const [];
    try {
      ports = ref.read(serialPortListerProvider)();
    } catch (_) {
      ports = const [];
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _ports = ports;
      if (_selectedPort == null || !ports.any((p) => p.name == _selectedPort)) {
        _selectedPort = ports.isEmpty ? null : ports.first.name;
      }
      _loadingPorts = false;
    });
  }

  void _refreshBluetooth() {
    if (kIsWeb) {
      setState(() {
        _btDevices = const [];
        _selectedBtId = null;
      });
      return;
    }
    List<TransmitterBluetoothDevice> devices = const [];
    try {
      final lister = ref.read(serialPortListerProvider);
      devices = _showAllComAsBt
          ? listSerialPortsAsBluetoothCandidates(lister)
          : listBluetoothTransmitterPorts(lister);
    } catch (_) {
      devices = const [];
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _btDevices = devices;
      if (_selectedBtId == null || !devices.any((d) => d.id == _selectedBtId)) {
        _selectedBtId = devices.isEmpty ? null : devices.first.id;
      }
    });
  }

  Future<void> _disconnect() async {
    await ref.read(fcConnectionProvider.notifier).disconnect();
  }

  Future<void> _connectUsb() async {
    final l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      showCommandResult(context, l10n.connectErrorUsbNeedsNative);
      return;
    }
    final port = _selectedPort;
    if (port == null) {
      showCommandResult(context, l10n.connectErrorNoComPort);
      return;
    }
    await ref.read(fcConnectionProvider.notifier).connect(
      ConnectionSettings(useSimulator: false, portName: port, baudRate: _baudRate),
    );
  }

  int? _parsePort(TextEditingController controller, {required String label}) {
    final l10n = AppLocalizations.of(context);
    final value = int.tryParse(controller.text.trim());
    if (value == null || value <= 0 || value > 65535) {
      showCommandResult(context, l10n.connectErrorInvalidPort(label));
      return null;
    }
    return value;
  }

  Future<void> _connectBluetooth() async {
    final l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      showCommandResult(context, l10n.connectErrorBluetoothNeedsNative);
      return;
    }
    final id = _selectedBtId;
    if (id == null) {
      showCommandResult(context, l10n.connectErrorNoBluetoothSerial);
      return;
    }
    await ref.read(fcConnectionProvider.notifier).connect(
      ConnectionSettings.bluetooth(portName: id, baudRate: _btBaud),
    );
  }

  Future<void> _connectWifi() async {
    final l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      showCommandResult(context, l10n.connectErrorWifiNeedsNative);
      return;
    }

    final settings = _wifiSettingsOrNull();
    if (settings == null) {
      return;
    }

    await ref.read(fcConnectionProvider.notifier).connect(settings);
    if (!mounted) {
      return;
    }
    final err = ref.read(fcConnectionProvider).errorMessage;
    if (err != null && !ref.read(telemetryConnectionProvider)) {
      showCommandResult(
        context,
        '$err\n\nTips: stay on the transmitter WiFi (not home WiFi), '
        'tap “Use gateway IP”, try port 14550, or switch mode to “UDP listen”.',
      );
    }
  }

  ConnectionSettings? _wifiSettingsOrNull() {
    final l10n = AppLocalizations.of(context);
    switch (_wifiMode) {
      case _WifiMode.udpListen:
        final local = _parsePort(_localPortController, label: l10n.localUdpPort);
        if (local == null) {
          return null;
        }
        return ConnectionSettings.udpListen(localPort: local);
      case _WifiMode.udpHost:
        final host = _hostController.text.trim();
        if (host.isEmpty) {
          showCommandResult(context, l10n.connectErrorEnterTxHost);
          return null;
        }
        final remote = _parsePort(_remotePortController, label: l10n.remoteUdpPort);
        final local = _parsePort(_localPortController, label: l10n.localUdpPort);
        if (remote == null || local == null) {
          return null;
        }
        return ConnectionSettings.udpHost(host: host, remotePort: remote, localPort: local);
      case _WifiMode.tcp:
        final host = _hostController.text.trim();
        if (host.isEmpty) {
          showCommandResult(context, l10n.connectErrorEnterTxHost);
          return null;
        }
        final remote = _parsePort(_remotePortController, label: l10n.tcpPort);
        if (remote == null) {
          return null;
        }
        return ConnectionSettings.tcpHost(host: host, remotePort: remote);
    }
  }

  Future<void> _useGatewayIp() async {
    final l10n = AppLocalizations.of(context);
    await _refreshWifiNetworkHint();
    final gateway = await detectDefaultGatewayIp();
    if (!mounted) {
      return;
    }
    if (gateway == null) {
      showCommandResult(context, l10n.connectErrorNoWifiGateway);
      return;
    }
    setState(() {
      _hostController.text = gateway;
      _wifiMode = _WifiMode.tcp;
      _remotePortController.text = '${ConnectionSettings.defaultTcpPort}';
    });
    showCommandResult(context, l10n.connectUsingGateway(gateway));
  }

  /// Tries common TCP ports on the host, then UDP listen 14550.
  Future<void> _autoTryWifi() async {
    final l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      return;
    }
    await _refreshWifiNetworkHint();
    var host = _hostController.text.trim();
    host = (await detectDefaultGatewayIp()) ?? host;
    if (host.isEmpty) {
      showCommandResult(context, l10n.connectWifiJoinFirst);
      return;
    }
    setState(() {
      _wifiProbing = true;
      _hostController.text = host;
    });

    final controller = ref.read(fcConnectionProvider.notifier);
    String? lastError;
    for (final port in kCommonMavlinkTcpPorts) {
      if (!mounted) {
        return;
      }
      setState(() {
        _wifiMode = _WifiMode.tcp;
        _remotePortController.text = '$port';
      });
      await controller.connect(ConnectionSettings.tcpHost(host: host, remotePort: port));
      final state = ref.read(fcConnectionProvider);
      if (state.session != null && state.errorMessage == null) {
        setState(() => _wifiProbing = false);
        showCommandResult(context, l10n.connectWifiTcpSuccess(host, '$port'));
        return;
      }
      lastError = state.errorMessage;
      await controller.disconnect();
    }

    // Skydroid G20 official share: TCP 192.168.43.1:5760 (try first if on that subnet).
    if (looksLikeSkydroidG20Hotspot(host) || host == kSkydroidG20HotspotIp) {
      setState(() {
        _wifiMode = _WifiMode.tcp;
        _hostController.text = kSkydroidG20HotspotIp;
        _remotePortController.text = '$kSkydroidG20MavlinkTcpPort';
      });
      await controller.connect(
        const ConnectionSettings.tcpHost(
          host: kSkydroidG20HotspotIp,
          remotePort: kSkydroidG20MavlinkTcpPort,
        ),
      );
      final g20 = ref.read(fcConnectionProvider);
      if (g20.session != null && g20.errorMessage == null) {
        setState(() => _wifiProbing = false);
        showCommandResult(context, l10n.connectWifiG20Success);
        return;
      }
      lastError = g20.errorMessage ?? lastError;
      await controller.disconnect();
    }

    // Fallback: some radios push MAVLink to the GCS on UDP 14550.
    setState(() {
      _wifiMode = _WifiMode.udpListen;
      _localPortController.text = '${ConnectionSettings.defaultUdpListenPort}';
    });
    await controller.connect(
      const ConnectionSettings.udpListen(localPort: ConnectionSettings.defaultUdpListenPort),
    );
    final state = ref.read(fcConnectionProvider);
    setState(() => _wifiProbing = false);
    if (state.session != null && state.errorMessage == null) {
      showCommandResult(context, l10n.connectWifiUdpListenSuccess);
      return;
    }
    showCommandResult(
      context,
      l10n.connectWifiAutoTryFailed(
        lastError ?? state.errorMessage ?? 'No MAVLink reply.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connection = ref.watch(fcConnectionProvider);
    final connected = ref.watch(telemetryConnectionProvider);
    final busy = connection.isBusy;
    final transmitter = connection.session?.isTransmitterLink ?? false;
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.85;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.connectLiveKpp, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  connected
                      ? l10n.connectLiveLink(connection.session?.linkLabel ?? 'K++')
                      : l10n.connectUsbIntro,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                if (kIsWeb)
                  Text(
                    l10n.connectWebUnsupported,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  )
                else ...[
                  // —— USB (unchanged) ——
                  Text(l10n.usbGround, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('usb-port-${_selectedPort ?? 'none'}-${_ports.length}'),
                          initialValue: _ports.isEmpty ? null : _selectedPort,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.comPort,
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                          hint: Text(l10n.noComPort),
                          items: [
                            for (final port in _ports)
                              DropdownMenuItem(
                                value: port.name,
                                child: Text(
                                  '${port.name}  ${port.description}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: connected || busy || _ports.isEmpty
                              ? null
                              : (value) => setState(() => _selectedPort = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: l10n.refreshComPorts,
                        onPressed: connected || busy || _loadingPorts ? null : _refreshPorts,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _baudRate,
                    decoration: InputDecoration(
                      labelText: l10n.baud,
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final baud in ConnectionSettings.baudRates)
                        DropdownMenuItem(value: baud, child: Text('$baud')),
                    ],
                    onChanged: connected || busy
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _baudRate = value);
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: busy
                        ? null
                        : connected
                            ? _disconnect
                            : _connectUsb,
                    icon: Icon(connected ? Icons.link_off : Icons.usb),
                    label: Text(connected ? l10n.disconnect : l10n.connectUsbToKpp),
                  ),

                  // —— Transmitter Bluetooth / WiFi ——
                  const SizedBox(height: 8),
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: transmitter || !connected,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 4),
                      title: Text(
                        l10n.transmitterBtWifi,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        l10n.airbornePath,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      children: [
                        Text(
                          l10n.transmitterPickHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 420;
                            return SizedBox(
                              width: constraints.maxWidth,
                              child: SegmentedButton<_TxTransport>(
                                showSelectedIcon: !compact,
                                style: compact
                                    ? const ButtonStyle(
                                        visualDensity: VisualDensity.compact,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )
                                    : null,
                                segments: [
                                  ButtonSegment(
                                    value: _TxTransport.bluetooth,
                                    label: Text(compact ? l10n.btAbbrev : l10n.bluetooth),
                                    icon: const Icon(Icons.bluetooth, size: 18),
                                  ),
                                  ButtonSegment(
                                    value: _TxTransport.wifi,
                                    label: Text(l10n.wifi),
                                    icon: const Icon(Icons.wifi, size: 18),
                                  ),
                                ],
                                selected: {_txTransport},
                                onSelectionChanged: connected || busy
                                    ? null
                                    : (next) {
                                        setState(() {
                                          _txTransport = next.first;
                                          if (_txTransport == _TxTransport.wifi) {
                                            _wifiMode = _WifiMode.tcp;
                                            _remotePortController.text =
                                                '${ConnectionSettings.defaultTcpPort}';
                                            _refreshWifiNetworkHint();
                                          }
                                        });
                                      },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_txTransport == _TxTransport.bluetooth) ...[
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(
                                    'bt-${_selectedBtId ?? 'none'}-${_btDevices.length}-$_showAllComAsBt',
                                  ),
                                  initialValue: _btDevices.isEmpty ? null : _selectedBtId,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.bluetoothTransmitter,
                                    isDense: true,
                                    border: const OutlineInputBorder(),
                                  ),
                                  hint: Text(l10n.noBluetoothPort),
                                  items: [
                                    for (final device in _btDevices)
                                      DropdownMenuItem(
                                        value: device.id,
                                        child: Text(
                                          '${device.name}  (${device.detail})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                  onChanged: connected || busy || _btDevices.isEmpty
                                      ? null
                                      : (value) => setState(() => _selectedBtId = value),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: l10n.refreshBluetoothPorts,
                                onPressed: connected || busy ? null : _refreshBluetooth,
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            value: _showAllComAsBt,
                            onChanged: connected || busy
                                ? null
                                : (value) {
                                    setState(() => _showAllComAsBt = value ?? false);
                                    _refreshBluetooth();
                                  },
                            title: Text(l10n.showAllComPorts),
                            subtitle: Text(l10n.showAllComPortsHint),
                          ),
                          DropdownButtonFormField<int>(
                            initialValue: _btBaud,
                            decoration: InputDecoration(
                              labelText: l10n.baud,
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              for (final baud in ConnectionSettings.baudRates)
                                DropdownMenuItem(value: baud, child: Text('$baud')),
                            ],
                            onChanged: connected || busy
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _btBaud = value);
                                    }
                                  },
                          ),
                          const SizedBox(height: 12),
                          if (!connected)
                            OutlinedButton.icon(
                              onPressed: busy ? null : _connectBluetooth,
                              icon: const Icon(Icons.bluetooth_connected),
                              label: Text(l10n.connectTransmitterBt),
                            )
                          else if (transmitter)
                            OutlinedButton.icon(
                              onPressed: busy ? null : _disconnect,
                              icon: const Icon(Icons.link_off),
                              label: Text(l10n.disconnectTransmitter),
                            ),
                        ] else ...[
                          if (_wifiNetworkHint != null) ...[
                            Text(
                              _wifiNetworkHint!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: connected || busy || _wifiProbing ? null : _applyG20Preset,
                                icon: const Icon(Icons.sports_esports),
                                label: Text(l10n.g20Preset),
                              ),
                              OutlinedButton.icon(
                                onPressed: connected || busy || _wifiProbing ? null : _useGatewayIp,
                                icon: const Icon(Icons.router),
                                label: Text(l10n.useGatewayIp),
                              ),
                              OutlinedButton.icon(
                                onPressed: connected || busy || _wifiProbing
                                    ? null
                                    : _refreshWifiNetworkHint,
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.refreshNetwork),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<_WifiMode>(
                            initialValue: _wifiMode,
                            decoration: InputDecoration(
                              labelText: l10n.wifiMode,
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: _WifiMode.tcp,
                                child: Text(l10n.wifiModeTcp),
                              ),
                              DropdownMenuItem(
                                value: _WifiMode.udpHost,
                                child: Text(l10n.wifiModeUdp),
                              ),
                              DropdownMenuItem(
                                value: _WifiMode.udpListen,
                                child: Text(l10n.wifiModeUdpListen),
                              ),
                            ],
                            onChanged: connected || busy || _wifiProbing
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _wifiMode = value;
                                        if (value == _WifiMode.tcp) {
                                          _remotePortController.text =
                                              '${ConnectionSettings.defaultTcpPort}';
                                        } else {
                                          _remotePortController.text =
                                              '${ConnectionSettings.defaultUdpListenPort}';
                                        }
                                      });
                                    }
                                  },
                          ),
                          if (_wifiMode != _WifiMode.udpListen) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _hostController,
                              enabled: !connected && !busy && !_wifiProbing,
                              decoration: InputDecoration(
                                labelText: l10n.hostIp,
                                isDense: true,
                                border: const OutlineInputBorder(),
                                hintText: 'gateway IP while on TX WiFi',
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (_wifiMode != _WifiMode.udpListen)
                                Expanded(
                                  child: TextField(
                                    controller: _remotePortController,
                                    enabled: !connected && !busy && !_wifiProbing,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: InputDecoration(
                                      labelText: l10n.remotePort,
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              if (_wifiMode != _WifiMode.tcp) ...[
                                if (_wifiMode != _WifiMode.udpListen) const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _localPortController,
                                    enabled: !connected && !busy && !_wifiProbing,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: InputDecoration(
                                      labelText: l10n.localPort,
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (!connected) ...[
                            FilledButton.tonalIcon(
                              onPressed: busy || _wifiProbing ? null : _autoTryWifi,
                              icon: _wifiProbing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.travel_explore),
                              label: Text(_wifiProbing ? l10n.tryingWifiPorts : l10n.autoTryWifi),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: busy || _wifiProbing ? null : _connectWifi,
                              icon: const Icon(Icons.wifi),
                              label: Text(l10n.connectTransmitterWifi),
                            ),
                          ] else if (transmitter)
                            OutlinedButton.icon(
                              onPressed: busy ? null : _disconnect,
                              icon: const Icon(Icons.link_off),
                              label: Text(l10n.disconnectTransmitter),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (connection.status == FcLinkStatus.loadingParameters) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: connection.paramsTotal == 0
                        ? null
                        : connection.paramsReceived / connection.paramsTotal,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loadingParameters(
                      connection.paramsReceived,
                      connection.paramsTotal,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (connection.status == FcLinkStatus.linkLost) ...[
                  const SizedBox(height: 8),
                  Text(
                    transmitter ? l10n.linkLostTransmitter : l10n.linkLostUsb,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                if (connection.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    connection.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 12),
                _LiveHint(text: l10n.connectLiveHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveHint extends StatelessWidget {
  const _LiveHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3548)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text),
      ),
    );
  }
}
