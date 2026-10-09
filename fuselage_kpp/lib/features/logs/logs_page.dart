import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/features/logs/log_review_page.dart';
import 'package:path_provider/path_provider.dart';

/// Flight log download (日志下载).
///
/// Stateful because it holds the fetched list and per-log download progress.
class LogsPage extends ConsumerStatefulWidget {
  const LogsPage({super.key});

  @override
  ConsumerState<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends ConsumerState<LogsPage> {
  List<LogEntry>? _logs;
  bool _listing = false;
  final Map<int, double> _progress = {};
  final Map<int, String> _savedPaths = {};
  String? _message;

  Future<void> _refresh() async {
    final session = ref.read(fcSessionProvider);
    if (session == null) {
      return;
    }
    setState(() {
      _listing = true;
      _message = null;
    });
    try {
      final logs = await session.logs.listLogs();
      setState(() => _logs = logs);
    } catch (error) {
      setState(() => _message = error.toString());
    } finally {
      if (mounted) {
        setState(() => _listing = false);
      }
    }
  }

  Future<void> _download(LogEntry entry) async {
    final session = ref.read(fcSessionProvider);
    if (session == null) {
      return;
    }
    setState(() => _progress[entry.id] = 0);
    try {
      final bytes = await session.logs.download(
        entry,
        onProgress: (f) {
          if (mounted) {
            setState(() => _progress[entry.id] = f);
          }
        },
      );
      final file = await _logFile(entry);
      await file.writeAsBytes(bytes);
      setState(() {
        _savedPaths[entry.id] = file.path;
        _message = 'Log ${entry.id} saved to ${file.path}';
      });
    } catch (error) {
      setState(() => _message = error.toString());
    } finally {
      if (mounted) {
        setState(() => _progress.remove(entry.id));
      }
    }
  }

  void _review(int logId) {
    final path = _savedPaths[logId];
    if (path == null) {
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LogReviewPage(file: File(path))));
  }

  static Future<File> _logFile(LogEntry entry) async {
    final documents = await getApplicationDocumentsDirectory();
    final folder = Directory('${documents.path}${Platform.pathSeparator}Fuselage-K++${Platform.pathSeparator}logs');
    await folder.create(recursive: true);
    return File('${folder.path}${Platform.pathSeparator}log_${entry.id}_${entry.timeUtc}.bin');
  }

  @override
  Widget build(BuildContext context) {
    final logs = _logs;
    return RequiresConnection(
      child: PageScaffold(
        title: 'Flight logs',
        description: 'Downloaded logs are saved to Documents\\Fuselage-K++\\logs.',
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: _listing ? null : _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh list'),
              ),
              if (_listing) const Padding(padding: EdgeInsets.only(left: 12), child: CircularProgressIndicator()),
            ],
          ),
          if (_message != null) Text(_message!),
          if (logs != null)
            AppCard(
              title: '${logs.length} logs on the flight controller',
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('No.')),
                  DataColumn(label: Text('Time (UTC)')),
                  DataColumn(label: Text('Size (bytes)'), numeric: true),
                  DataColumn(label: Text('')),
                ],
                rows: [
                  for (final entry in logs)
                    DataRow(
                      cells: [
                        DataCell(Text('${entry.id}')),
                        DataCell(
                          Text(
                            entry.timeUtc == 0
                                ? '—'
                                : DateTime.fromMillisecondsSinceEpoch(
                                    entry.timeUtc * 1000,
                                    isUtc: true,
                                  ).toString().substring(0, 19),
                          ),
                        ),
                        DataCell(Text('${entry.size}')),
                        DataCell(
                          _progress.containsKey(entry.id)
                              ? SizedBox(width: 120, child: LinearProgressIndicator(value: _progress[entry.id]))
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(onPressed: () => _download(entry), child: const Text('Download')),
                                    if (_savedPaths.containsKey(entry.id))
                                      TextButton(onPressed: () => _review(entry.id), child: const Text('Review')),
                                  ],
                                ),
                        ),
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
