import 'dart:async';
import 'dart:typed_data';

import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/session/mavlink_connection.dart';

class LogDownloadException implements Exception {
  const LogDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Lists and downloads on-board flight logs
/// (LOG_REQUEST_LIST / LOG_ENTRY / LOG_REQUEST_DATA / LOG_DATA).
class LogService {
  LogService(this._connection);

  static const Duration _listTimeout = Duration(seconds: 3);
  static const Duration _stallTimeout = Duration(seconds: 2);
  static const int _maxStalls = 5;

  final MavlinkConnection _connection;

  Future<List<LogEntry>> listLogs() async {
    final entries = <int, LogEntry>{};
    final complete = Completer<void>();
    final subscription = _connection.messagesOf<LogEntry>().listen((entry) {
      if (complete.isCompleted) {
        return;
      }
      if (entry.numLogs == 0) {
        complete.complete();
        return;
      }
      entries[entry.id] = entry;
      if (entries.length >= entry.numLogs) {
        complete.complete();
      }
    });
    _connection.send(
      LogRequestList(targetSystem: _connection.targetSystem, targetComponent: _connection.targetComponent),
    );
    try {
      await complete.future.timeout(_listTimeout);
    } on TimeoutException {
      if (entries.isEmpty) {
        throw const LogDownloadException('The flight controller did not answer the log list request.');
      }
    } finally {
      unawaited(subscription.cancel());
    }
    return entries.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  /// Downloads a whole log, re-requesting whatever is still missing whenever
  /// the transfer stalls. [onProgress] receives a fraction from 0 to 1.
  Future<Uint8List> download(LogEntry entry, {void Function(double fraction)? onProgress}) async {
    final buffer = Uint8List(entry.size);
    final received = List<bool>.filled(entry.size, false);
    var receivedCount = 0;
    var progressed = false;
    final finished = Completer<void>();

    final subscription = _connection.messagesOf<LogData>().where((d) => d.logId == entry.id).listen((chunk) {
      for (var i = 0; i < chunk.data.length && chunk.offset + i < entry.size; i++) {
        final position = chunk.offset + i;
        if (!received[position]) {
          received[position] = true;
          buffer[position] = chunk.data[i];
          receivedCount++;
        }
      }
      progressed = true;
      onProgress?.call(receivedCount / entry.size);
      if (receivedCount == entry.size && !finished.isCompleted) {
        finished.complete();
      }
    });

    try {
      var consecutiveStalls = 0;
      while (receivedCount < entry.size) {
        final gapStart = received.indexOf(false);
        final gapEnd = received.indexOf(true, gapStart);
        _requestRange(entry.id, gapStart, (gapEnd < 0 ? entry.size : gapEnd) - gapStart);
        progressed = false;
        await Future.any([finished.future, Future<void>.delayed(_stallTimeout)]);
        consecutiveStalls = progressed ? 0 : consecutiveStalls + 1;
        if (consecutiveStalls >= _maxStalls) {
          throw LogDownloadException(
            'Log ${entry.id} stalled at ${(100 * receivedCount / entry.size).toStringAsFixed(0)} %.',
          );
        }
      }
    } finally {
      unawaited(subscription.cancel());
    }
    return buffer;
  }

  void _requestRange(int logId, int offset, int count) {
    _connection.send(
      LogRequestData(
        targetSystem: _connection.targetSystem,
        targetComponent: _connection.targetComponent,
        logId: logId,
        offset: offset,
        count: count,
      ),
    );
  }
}
