import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

class ImuCalibrationCard extends ConsumerStatefulWidget {
  const ImuCalibrationCard({super.key});

  @override
  ConsumerState<ImuCalibrationCard> createState() => _ImuCalibrationCardState();
}

class _ImuCalibrationCardState extends ConsumerState<ImuCalibrationCard> {
  bool _busy = false;
  String? _status;

  Future<void> _run() async {
    final session = ref.read(fcSessionProvider);
    if (session == null) {
      return;
    }
    final l10n = KppLocalizations.of(context);
    setState(() {
      _busy = true;
      _status = l10n.imuLevelCalibrationSubtitle;
    });
    final sub = session.commands.statusTexts.listen((t) {
      if (mounted) {
        setState(() => _status = t.text);
      }
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await session.commands.calibrateImu();
      messenger.showSnackBar(SnackBar(content: Text(l10n.imuCalibrationAccepted)));
      setState(() => _status = l10n.imuCalibrationAccepted);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.imuCalibrationFailed(error.toString()))));
      setState(() => _status = error.toString());
    } finally {
      await sub.cancel();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    return AppCard(
      title: l10n.imuLevelCalibration,
      subtitle: l10n.imuLevelCalibrationSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_status != null) Text(_status!),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _busy ? null : _run,
            child: Text(_busy ? l10n.calibratingImu : l10n.calibrateImu),
          ),
        ],
      ),
    );
  }
}

class CompassCalibrationCard extends ConsumerStatefulWidget {
  const CompassCalibrationCard({super.key});

  @override
  ConsumerState<CompassCalibrationCard> createState() => _CompassCalibrationCardState();
}

class _CompassCalibrationCardState extends ConsumerState<CompassCalibrationCard> {
  bool _busy = false;
  String? _status;

  Future<void> _run() async {
    final session = ref.read(fcSessionProvider);
    if (session == null) {
      return;
    }
    final l10n = KppLocalizations.of(context);
    setState(() {
      _busy = true;
      _status = l10n.compassCalibrationSubtitle;
    });
    final sub = session.commands.statusTexts.listen((t) {
      if (mounted) {
        setState(() => _status = t.text);
      }
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await session.commands.calibrateCompass();
      messenger.showSnackBar(SnackBar(content: Text(l10n.compassCalibrationStarted)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.compassCalibrationFailed(error.toString()))));
      setState(() => _status = error.toString());
    } finally {
      await sub.cancel();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    final live = ref.watch(telemetryProvider.select((t) => t.lastStatusText));
    return AppCard(
      title: l10n.compassCalibration,
      subtitle: l10n.compassCalibrationSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_status != null || live != null) Text(_status ?? live!),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _busy ? null : _run,
            child: Text(_busy ? l10n.calibratingCompass : l10n.calibrateCompass),
          ),
        ],
      ),
    );
  }
}
