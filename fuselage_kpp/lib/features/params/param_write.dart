import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

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
  final l10n = KppLocalizations.of(context);
  final current = ref.read(paramValuesProvider)[id];
  final summary = '$id: ${current == null ? '—' : format(current)} → ${format(value)}';
  final messenger = ScaffoldMessenger.of(context);
  if (!await _confirmOnHardware(context, ref, summary)) {
    return false;
  }

  try {
    final stored = await ref.read(paramValuesProvider.notifier).write(id, value);
    messenger.showSnackBar(SnackBar(content: Text(l10n.paramSaved(id, format(stored)))));
    return true;
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.paramNotSaved(id, error.toString()))));
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
  final l10n = KppLocalizations.of(context);
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
            ? l10n.paramsSavedCount(values.length)
            : l10n.paramsSavedPartial(values.length - failed.length, failed.length, failed.join(', ')),
      ),
    ),
  );
  return failed;
}

Future<bool> _confirmOnHardware(BuildContext context, WidgetRef ref, String summary) async {
  if (ref.read(fcConnectionProvider).isSimulator) {
    return true;
  }
  final l10n = KppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.writeToFlightControllerTitle),
      content: SingleChildScrollView(child: SelectableText(summary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.write)),
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
