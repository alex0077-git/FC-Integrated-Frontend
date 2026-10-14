import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_catalog.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/features/parameters/param_file.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';
import 'package:fuselage_kpp/l10n/param_l10n.dart';

/// Full parameter list with search, export (参数导出) and import (参数导入).
///
/// Stateful because it keeps the search text.
class ParametersPage extends ConsumerStatefulWidget {
  const ParametersPage({super.key});

  @override
  ConsumerState<ParametersPage> createState() => _ParametersPageState();
}

class _ParametersPageState extends ConsumerState<ParametersPage> {
  String _query = '';

  Future<void> _export() async {
    final l10n = KppLocalizations.of(context);
    final fileTypes = [
      XTypeGroup(label: l10n.parameterFiles, extensions: ['param', 'txt']),
    ];
    final location = await getSaveLocation(
      acceptedTypeGroups: fileTypes,
      suggestedName: 'fuselage_kpp_${DateTime.now().toIso8601String().substring(0, 10)}.param',
    );
    if (location == null) {
      return;
    }
    final values = ref.read(paramValuesProvider);
    final link = ref.read(fcSessionProvider)?.linkLabel ?? 'unknown';
    await File(
      location.path,
    ).writeAsString(ParamFile.encode(values, header: 'Fuselage-K++ export from $link, ${DateTime.now()}'));
    _notify(l10n.exportParametersTo(values.length, location.path));
  }

  Future<void> _import() async {
    final l10n = KppLocalizations.of(context);
    final fileTypes = [
      XTypeGroup(label: l10n.parameterFiles, extensions: ['param', 'txt']),
    ];
    final file = await openFile(acceptedTypeGroups: fileTypes);
    if (file == null) {
      return;
    }
    final Map<String, double> imported;
    try {
      imported = ParamFile.decode(await file.readAsString());
    } on FormatException catch (error) {
      _notify(l10n.importFileFormatError(error.message));
      return;
    }
    final current = ref.read(paramValuesProvider);
    const float32Tolerance = 1e-4;
    final changes = {
      for (final entry in imported.entries)
        if (current.containsKey(entry.key) &&
            ParamCatalog.byId(entry.key)?.readOnly != true &&
            (current[entry.key]! - entry.value).abs() > float32Tolerance)
          entry.key: entry.value,
    };
    if (changes.isEmpty) {
      _notify(l10n.importNothingMatches);
      return;
    }
    if (mounted) {
      await writeParamsFromUi(context, ref, values: changes);
    }
  }

  void _notify(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(paramValuesProvider);
    final busy = ref.watch(fcConnectionProvider.select((s) => s.isBusy));
    final query = _query.toUpperCase();
    final l10n = KppLocalizations.of(context);
    final ids =
        values.keys.where((id) {
          final spec = ParamCatalog.byId(id);
          final label = spec == null ? '' : ParamL10n.label(l10n, spec);
          return id.contains(query) || label.toUpperCase().contains(query);
        }).toList()..sort();

    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destParameters,
        description: l10n.parametersDescription(values.length),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _export,
                icon: const Icon(Icons.file_download_outlined),
                label: Text(l10n.export),
              ),
              FilledButton.tonalIcon(
                onPressed: _import,
                icon: const Icon(Icons.file_upload_outlined),
                label: Text(l10n.import),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : () => ref.read(fcConnectionProvider.notifier).reloadParameters(),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.reloadFromFc),
              ),
            ],
          ),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.searchByIdOrName,
              border: const OutlineInputBorder(),
            ),
            onChanged: (text) => setState(() => _query = text),
          ),
          AppCard(
            title: l10n.parametersShown(ids.length),
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.paramColumnId)),
                DataColumn(label: Text(l10n.paramColumnName)),
                DataColumn(label: Text(l10n.paramColumnValue), numeric: true),
              ],
              rows: [
                for (final id in ids)
                  DataRow(
                    cells: [
                      DataCell(SelectableText(id)),
                      DataCell(Text(ParamCatalog.byId(id) == null ? '—' : ParamL10n.label(l10n, ParamCatalog.byId(id)!))),
                      DataCell(Text(ParamCatalog.byId(id)?.formatValue(values[id]!) ?? '${values[id]}')),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
