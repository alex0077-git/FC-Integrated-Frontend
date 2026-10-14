import 'package:fc_frontend/core/theme/app_theme.dart';
import 'package:fc_frontend/l10n/app_localizations.dart';
import 'package:fc_frontend/core/widgets/command_result.dart';
import 'package:fc_frontend/data/repositories/flight_command_repository.dart';
import 'package:fc_frontend/data/repositories/telemetry_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Map overlay that sends return-to-launch to the live K++.
class MapRtlButton extends ConsumerStatefulWidget {
  const MapRtlButton({super.key});

  @override
  ConsumerState<MapRtlButton> createState() => _MapRtlButtonState();
}

class _MapRtlButtonState extends ConsumerState<MapRtlButton> {
  bool _confirming = false;
  bool _busy = false;

  void _toggle() {
    setState(() => _confirming = !_confirming);
  }

  void _cancel() {
    setState(() => _confirming = false);
  }

  Future<void> _confirm() async {
    setState(() {
      _confirming = false;
      _busy = true;
    });
    try {
      await ref.read(flightCommandRepositoryProvider).returnToLaunch();
      if (!mounted) {
        return;
      }
      showCommandResult(context, 'RTL sent to K++');
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connected = ref.watch(telemetryConnectionProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_confirming) ...[
          _RtlConfirmCard(onCancel: _cancel, onConfirm: _busy ? () {} : _confirm),
          const SizedBox(width: 8),
        ],
        Material(
          color: AppTheme.surface.withValues(alpha: 0.92),
          shape: const CircleBorder(),
          elevation: 2,
          child: IconButton(
            tooltip: connected ? l10n.returnToLaunch : l10n.connectUsbToKpp,
            onPressed: !connected || _busy ? null : _toggle,
            style: IconButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.flight_land),
          ),
        ),
      ],
    );
  }
}

class _RtlConfirmCard extends StatelessWidget {
  const _RtlConfirmCard({required this.onCancel, required this.onConfirm});

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Material(
        color: AppTheme.surface,
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.returnToLaunch),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onCancel,
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onConfirm,
                    child: Text(l10n.confirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
