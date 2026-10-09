import 'dart:async';

import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/mission/mission_item.dart';
import 'package:fuselage_kpp/data/session/mavlink_connection.dart';

class MissionException implements Exception {
  const MissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Downloads and uploads missions using MISSION_*_INT.
class MissionService {
  MissionService(this._connection);

  static const Duration _stepTimeout = Duration(seconds: 3);

  final MavlinkConnection _connection;
  List<MissionItem> _items = const [];

  List<MissionItem> get items => List.unmodifiable(_items);

  void setLocalItems(List<MissionItem> items) {
    _items = [for (var i = 0; i < items.length; i++) items[i].copyWith(seq: i)];
  }

  Future<List<MissionItem>> download({void Function(int received, int total)? onProgress}) async {
    final countFuture = _connection.messagesOf<MissionCount>().first.timeout(_stepTimeout);
    _connection.send(
      MissionRequestList(targetSystem: _connection.targetSystem, targetComponent: _connection.targetComponent),
    );
    final countMsg = await countFuture;
    final total = countMsg.count;
    if (total == 0) {
      _items = const [];
      onProgress?.call(0, 0);
      return _items;
    }

    final collected = <int, MissionItem>{};
    for (var seq = 0; seq < total; seq++) {
      final itemFuture = _connection.messagesOf<MissionItemInt>().firstWhere((m) => m.seq == seq).timeout(_stepTimeout);
      _connection.send(
        MissionRequestInt(
          seq: seq,
          targetSystem: _connection.targetSystem,
          targetComponent: _connection.targetComponent,
        ),
      );
      final item = await itemFuture;
      collected[seq] = MissionItem.fromMav(item);
      onProgress?.call(collected.length, total);
    }
    _items = [for (var i = 0; i < total; i++) collected[i]!];
    return _items;
  }

  Future<void> upload(List<MissionItem> items, {void Function(int sent, int total)? onProgress}) async {
    final ordered = [for (var i = 0; i < items.length; i++) items[i].copyWith(seq: i)];
    final total = ordered.length;
    final done = Completer<void>();
    var sent = 0;

    late final StreamSubscription<MavMessage> sub;
    sub = _connection.messages.listen((message) {
      if (message is MissionRequestInt) {
        final seq = message.seq;
        if (seq < 0 || seq >= total) {
          if (!done.isCompleted) {
            done.completeError(MissionException('FC requested invalid mission seq $seq'));
          }
          return;
        }
        _connection.send(
          ordered[seq].toMav(
            targetSystem: _connection.targetSystem,
            targetComponent: _connection.targetComponent,
            current: seq == 0 ? 1 : 0,
          ),
        );
        sent++;
        onProgress?.call(sent.clamp(0, total), total);
      } else if (message is MissionAck) {
        if (message.type != MavMissionResult.accepted) {
          if (!done.isCompleted) {
            done.completeError(MissionException('Mission upload rejected: ${message.type}'));
          }
        } else if (!done.isCompleted) {
          done.complete();
        }
      }
    });

    try {
      _connection.send(
        MissionCount(
          count: total,
          targetSystem: _connection.targetSystem,
          targetComponent: _connection.targetComponent,
        ),
      );
      await done.future.timeout(
        Duration(seconds: 3 + total),
        onTimeout: () => throw const MissionException('Mission upload timed out.'),
      );
      _items = ordered;
    } finally {
      await sub.cancel();
    }
  }

  Future<void> clear() async {
    final ackFuture = _connection.messagesOf<MissionAck>().first.timeout(_stepTimeout);
    _connection.send(
      MissionClearAll(targetSystem: _connection.targetSystem, targetComponent: _connection.targetComponent),
    );
    final ack = await ackFuture;
    if (ack.type != MavMissionResult.accepted) {
      throw MissionException('Mission clear rejected: ${ack.type}');
    }
    _items = const [];
  }
}
