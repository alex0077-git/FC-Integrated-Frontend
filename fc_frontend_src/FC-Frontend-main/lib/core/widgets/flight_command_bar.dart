import 'package:fc_frontend/core/widgets/command_result.dart';
import 'package:fc_frontend/core/widgets/home_button.dart';
import 'package:fc_frontend/data/repositories/flight_command_repository.dart';
import 'package:fc_frontend/data/repositories/telemetry_repository.dart';
import 'package:fc_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlightCommandBar extends ConsumerStatefulWidget {
  const FlightCommandBar({super.key});

  @override
  ConsumerState<FlightCommandBar> createState() => _FlightCommandBarState();
}

class _FlightCommandBarState extends ConsumerState<FlightCommandBar> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(telemetryStreamProvider).asData?.value;
    final connected = ref.watch(telemetryConnectionProvider);
    final armed = telemetry?.armed ?? false;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        const Expanded(child: HomeButton()),
        Expanded(
          child: _FlightCommandButton(
            label: l10n.takeoff,
            onPressed: !connected || _busy ? null : _onTakeoff,
          ),
        ),
        Expanded(
          child: _FlightCommandButton(
            label: armed ? l10n.disarm : l10n.arm,
            onPressed: !connected || _busy ? null : () => _onArmDisarm(armed),
          ),
        ),
        Expanded(
          child: _FlightCommandButton(
            label: l10n.rtl,
            onPressed: !connected || _busy ? null : _onRtl,
          ),
        ),
        Expanded(
          child: _FlightCommandButton(
            label: l10n.land,
            onPressed: !connected || _busy
                ? null
                : () => _confirmThen(
                      l10n.landConfirmTitle,
                      l10n.landConfirmMessage,
                      (c) => c.land(),
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _onTakeoff() async {
    final l10n = AppLocalizations.of(context);
    final altitude = await showDialog<double>(
      context: context,
      builder: (context) => const _TakeoffAltitudeDialog(defaultAltitude: 10),
    );
    if (altitude == null || !mounted) {
      return;
    }
    await _run(l10n.takeoff, (c) => c.takeoff(altitudeMeters: altitude));
  }

  Future<void> _onArmDisarm(bool armed) async {
    final l10n = AppLocalizations.of(context);
    await _confirmThen(
      armed ? l10n.disarm : l10n.arm,
      armed ? l10n.disarmConfirmMessage : l10n.armConfirmMessage,
      (c) => armed ? c.disarm() : c.arm(),
    );
  }

  Future<void> _onRtl() async {
    final l10n = AppLocalizations.of(context);
    await _confirmThen(
      l10n.rtl,
      l10n.rtlConfirmMessage,
      (c) => c.returnToLaunch(),
    );
  }

  Future<void> _confirmThen(
    String label,
    String message,
    Future<void> Function(FlightCommandRepository commands) action,
  ) async {
    final confirmed = await _confirm(title: label, message: message);
    if (!confirmed || !mounted) {
      return;
    }
    await _run(label, action);
  }

  Future<void> _run(
    String label,
    Future<void> Function(FlightCommandRepository commands) action,
  ) async {
    setState(() => _busy = true);
    try {
      await action(ref.read(flightCommandRepositoryProvider));
      if (!mounted) {
        return;
      }
      // Shown only after COMMAND_ACK accepted on the live USB/BT/WiFi link.
      showCommandResult(context, '$label accepted by K++');
    } on FlightCommandException catch (error) {
      if (!mounted) {
        return;
      }
      showCommandResult(context, error.message);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<bool> _confirm({required String title, required String message}) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }
}

class _FlightCommandButton extends StatelessWidget {
  const _FlightCommandButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        onPressed: onPressed,
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _TakeoffAltitudeDialog extends StatefulWidget {
  const _TakeoffAltitudeDialog({required this.defaultAltitude});

  final double defaultAltitude;

  @override
  State<_TakeoffAltitudeDialog> createState() => _TakeoffAltitudeDialogState();
}

class _TakeoffAltitudeDialogState extends State<_TakeoffAltitudeDialog> {
  late bool _setAltitude;
  late final TextEditingController _altitudeController;

  @override
  void initState() {
    super.initState();
    _setAltitude = true;
    _altitudeController = TextEditingController(
      text: widget.defaultAltitude.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _altitudeController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_setAltitude) {
      Navigator.of(context).pop(widget.defaultAltitude);
      return;
    }
    final parsed = double.tryParse(_altitudeController.text.trim());
    if (parsed == null || parsed <= 0 || parsed > 500) {
      return;
    }
    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meters = _setAltitude
        ? _altitudeController.text.trim()
        : widget.defaultAltitude.toStringAsFixed(0);
    return AlertDialog(
      title: Text(l10n.takeoff),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.takeoffConfirmMessage(meters.isEmpty ? '—' : meters)),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.setTakeoffAltitude),
            value: _setAltitude,
            onChanged: (value) => setState(() => _setAltitude = value ?? false),
          ),
          if (_setAltitude)
            TextField(
              controller: _altitudeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.takeoffAltitudeMeters,
                suffixText: 'm',
              ),
              onChanged: (_) => setState(() {}),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _confirm,
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
