import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';

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
    setState(() {
      _busy = true;
      _status = 'Place the FC face up and level…';
    });
    final sub = session.commands.statusTexts.listen((t) {
      if (mounted) {
        setState(() => _status = t.text);
      }
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await session.commands.calibrateImu();
      messenger.showSnackBar(const SnackBar(content: Text('IMU calibration accepted')));
      setState(() => _status = 'IMU calibration finished');
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('IMU calibration failed: $error')));
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
    return AppCard(
      title: 'IMU level calibration',
      subtitle: 'Place the flight controller face up and level, then calibrate.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_status != null) Text(_status!),
          const SizedBox(height: 8),
          FilledButton(onPressed: _busy ? null : _run, child: Text(_busy ? 'Calibrating…' : 'Calibrate IMU')),
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
    setState(() {
      _busy = true;
      _status = 'Rotate the aircraft level, then nose-down…';
    });
    final sub = session.commands.statusTexts.listen((t) {
      if (mounted) {
        setState(() => _status = t.text);
      }
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await session.commands.calibrateCompass();
      messenger.showSnackBar(const SnackBar(content: Text('Compass calibration started')));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Compass calibration failed: $error')));
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
    final live = ref.watch(telemetryProvider.select((t) => t.lastStatusText));
    return AppCard(
      title: 'Compass calibration',
      subtitle: 'Rotate the aircraft level and clockwise, then nose-down and clockwise.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_status != null || live != null) Text(_status ?? live!),
          const SizedBox(height: 8),
          FilledButton(onPressed: _busy ? null : _run, child: Text(_busy ? 'Calibrating…' : 'Calibrate compass')),
        ],
      ),
    );
  }
}
