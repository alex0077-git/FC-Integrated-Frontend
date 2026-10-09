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

/// Full parameter list with search, export (参数导出) and import (参数导入).
///
/// Stateful because it keeps the search text.
class ParametersPage extends ConsumerStatefulWidget {
  const ParametersPage({super.key});

  @override
  ConsumerState<ParametersPage> createState() => _ParametersPageState();
}

class _ParametersPageState extends ConsumerState<ParametersPage> {
  static const _fileTypes = [
    XTypeGroup(label: 'Parameter files', extensions: ['param', 'txt']),
  ];

  /// Parameters travel as 32-bit floats, so 44.4 comes back as 44.400001.
  static const double _float32Tolerance = 1e-4;

  String _query = '';

  Future<void> _export() async {
    final location = await getSaveLocation(
      acceptedTypeGroups: _fileTypes,
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
    _notify('Exported ${values.length} parameters to ${location.path}');
  }

  Future<void> _import() async {
    final file = await openFile(acceptedTypeGroups: _fileTypes);
    if (file == null) {
      return;
    }
    final Map<String, double> imported;
    try {
      imported = ParamFile.decode(await file.readAsString());
    } on FormatException catch (error) {
      _notify('File format error: ${error.message}');
      return;
    }
    final current = ref.read(paramValuesProvider);
    final changes = {
      for (final entry in imported.entries)
        if (current.containsKey(entry.key) &&
            ParamCatalog.byId(entry.key)?.readOnly != true &&
            (current[entry.key]! - entry.value).abs() > _float32Tolerance)
          entry.key: entry.value,
    };
    if (changes.isEmpty) {
      _notify('Nothing to import: every value already matches the flight controller.');
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
    final ids =
        values.keys
            .where((id) => id.contains(query) || (ParamCatalog.byId(id)?.label.toUpperCase().contains(query) ?? false))
            .toList()
          ..sort();

    return RequiresConnection(
      child: PageScaffold(
        title: 'All parameters',
        description: '${values.length} parameters read from the flight controller.',
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _export,
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Export'),
              ),
              FilledButton.tonalIcon(
                onPressed: _import,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('Import'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : () => ref.read(fcConnectionProvider.notifier).reloadParameters(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reload from FC'),
              ),
            ],
          ),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by id or name',
              border: OutlineInputBorder(),
            ),
            onChanged: (text) => setState(() => _query = text),
          ),
          AppCard(
            title: '${ids.length} shown',
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Id')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Value'), numeric: true),
              ],
              rows: [
                for (final id in ids)
                  DataRow(
                    cells: [
                      DataCell(SelectableText(id)),
                      DataCell(Text(ParamCatalog.byId(id)?.label ?? '—')),
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
