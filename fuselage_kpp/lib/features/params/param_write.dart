import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';

/// Writes one parameter from the UI: asks for confirmation on real hardware,
/// performs the write and reports the outcome in a snackbar.
///
/// Returns true when the flight controller confirmed the new value.
Future<bool> writeParamFromUi(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required double value,
  required String Function(double) format,
}) async {
  final current = ref.read(paramValuesProvider)[id];
  final summary = '$id: ${current == null ? '—' : format(current)} → ${format(value)}';
  final messenger = ScaffoldMessenger.of(context);
  if (!await _confirmOnHardware(context, ref, summary)) {
    return false;
  }

  try {
    final stored = await ref.read(paramValuesProvider.notifier).write(id, value);
    messenger.showSnackBar(SnackBar(content: Text('$id saved: ${format(stored)}')));
    return true;
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text('$id not saved: $error')));
    return false;
  }
}

/// Writes several parameters with a single confirmation. Returns the ids
/// that failed (empty when everything was confirmed by the flight controller).
Future<List<String>> writeParamsFromUi(
  BuildContext context,
  WidgetRef ref, {
  required Map<String, double> values,
}) async {
  final current = ref.read(paramValuesProvider);
  final summary = [
    for (final entry in values.entries) '${entry.key}: ${_plain(current[entry.key])} → ${_plain(entry.value)}',
  ].join('\n');
  final messenger = ScaffoldMessenger.of(context);
  if (!await _confirmOnHardware(context, ref, summary)) {
    return values.keys.toList();
  }

  final controller = ref.read(paramValuesProvider.notifier);
  final failed = <String>[];
  for (final entry in values.entries) {
    try {
      await controller.write(entry.key, entry.value);
    } catch (_) {
      failed.add(entry.key);
    }
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        failed.isEmpty
            ? '${values.length} parameters saved'
            : '${values.length - failed.length} saved, ${failed.length} failed: ${failed.join(', ')}',
      ),
    ),
  );
  return failed;
}

Future<bool> _confirmOnHardware(BuildContext context, WidgetRef ref, String summary) async {
  if (ref.read(fcConnectionProvider).isSimulator) {
    return true;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Write to flight controller?'),
      content: SingleChildScrollView(child: SelectableText(summary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Write')),
      ],
    ),
  );
  return confirmed == true;
}

String _plain(double? value) {
  if (value == null) {
    return '—';
  }
  return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}
