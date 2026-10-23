import 'dart:async';

import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/params/param_number.dart';
import 'package:fuselage_kpp/data/session/mavlink_connection.dart';

class ParameterException implements Exception {
  const ParameterException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Reads and writes flight-controller parameters by name
/// (PARAM_REQUEST_LIST / PARAM_REQUEST_READ / PARAM_SET).
class ParameterService {
  ParameterService(this._connection) {
    _subscription = _connection.messagesOf<ParamValue>().listen(_onParamValue);
  }

  static const Duration _listIdleTimeout = Duration(seconds: 3);
  static const Duration _listIdleTimeoutSlow = Duration(seconds: 8);
  static const Duration _ackTimeout = Duration(milliseconds: 1500);
  static const int _maxAttempts = 3;
  static const int _maxAttemptsSlow = 6;
  static const double _ackTolerance = 1e-4;

  final MavlinkConnection _connection;
  late final StreamSubscription<ParamValue> _subscription;
  final StreamController<ParamValue> _updates = StreamController.broadcast();
  final Map<int, String> _idsByIndex = {};
  final Map<String, double> _values = {};
  int? _expectedCount;

  /// Every PARAM_VALUE received, whether requested or not.
  Stream<ParamValue> get updates => _updates.stream;

  /// Latest known value of every parameter received so far.
  Map<String, double> get values => Map.unmodifiable(_values);

  /// Downloads the full parameter list, re-requesting any missing indices.
  /// [onProgress] receives (received, total).
  /// [broadcast] targets sys/comp 0 (JIYI phone path). [slowLink] uses longer
  /// idle waits (Android BT / radio telem).
  Future<void> downloadAll({
    void Function(int received, int total)? onProgress,
    bool broadcast = false,
    bool slowLink = false,
  }) async {
    _idsByIndex.clear();
    _expectedCount = null;
    final idle = slowLink ? _listIdleTimeoutSlow : _listIdleTimeout;
    final attempts = slowLink ? _maxAttemptsSlow : _maxAttempts;
    final sys = broadcast ? 0 : _connection.targetSystem;
    final comp = broadcast ? 0 : _connection.targetComponent;
    final progress = _updates.stream.listen((_) {
      final total = _expectedCount;
      if (total != null) {
        onProgress?.call(_idsByIndex.length, total);
      }
    });
    try {
      // K++ answers reliably after a READ kick + LIST (JIYI does the same on the wire).
      // On slow BT also TX clear FE copies — some T12 RFCOMM paths only forward FE.
      for (var kick = 0; kick < attempts && _expectedCount == null; kick++) {
        _sendParamRead(0, sys, comp, alsoClear: slowLink);
        _sendParamList(sys, comp, alsoClear: slowLink);
        await _waitUntilIdle(idle);
      }
      for (var attempt = 0; attempt < attempts && _missingIndices().isNotEmpty; attempt++) {
        final missing = _missingIndices();
        // Smaller batches on slow BT so we do not overrun the radio buffer.
        final batch = missing.take(slowLink ? 15 : 40);
        for (final index in batch) {
          _sendParamRead(index, sys, comp, alsoClear: slowLink);
        }
        await _waitUntilIdle(idle);
      }
    } finally {
      unawaited(progress.cancel());
    }
    if (_expectedCount == null) {
      throw const ParameterException('The flight controller did not send any parameters.');
    }
    final missing = _missingIndices();
    if (missing.isNotEmpty) {
      throw ParameterException('${missing.length} of $_expectedCount parameters could not be read.');
    }
  }

  void _sendParamList(int system, int component, {bool alsoClear = false}) {
    final msg = ParamRequestList(targetSystem: system, targetComponent: component);
    _connection.send(msg);
    if (alsoClear) {
      _connection.sendClearMavlink(msg);
    }
  }

  void _sendParamRead(int index, int system, int component, {bool alsoClear = false}) {
    final msg = ParamRequestRead(
      targetSystem: system,
      targetComponent: component,
      paramId: '',
      paramIndex: index,
    );
    _connection.send(msg);
    if (alsoClear) {
      _connection.sendClearMavlink(msg);
    }
  }

  /// Writes [value] and waits until the flight controller echoes it back.
  /// Returns the value the flight controller actually stored.
  Future<double> setParam(String id, double value) async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final echo = _updates.stream.firstWhere((p) => p.paramId == id).timeout(_ackTimeout);
      _connection.send(
        ParamSet(
          targetSystem: _connection.targetSystem,
          targetComponent: _connection.targetComponent,
          paramId: id,
          value: value,
        ),
      );
      try {
        final stored = (await echo).value;
        if ((stored - value).abs() > _ackTolerance) {
          throw ParameterException('$id was rejected: the flight controller kept ${formatParamNumber(stored)}.');
        }
        return stored;
      } on TimeoutException {
        continue;
      }
    }
    throw ParameterException('No confirmation for $id after $_maxAttempts attempts.');
  }

  Future<void> dispose() async {
    unawaited(_subscription.cancel());
    if (!_updates.isClosed) {
      unawaited(_updates.close());
    }
  }

  void _onParamValue(ParamValue value) {
    _expectedCount = value.count;
    _idsByIndex[value.index] = value.paramId;
    _values[value.paramId] = value.value;
    _updates.add(value);
  }

  List<int> _missingIndices() {
    final total = _expectedCount;
    if (total == null) {
      return const [];
    }
    return [
      for (var i = 0; i < total; i++)
        if (!_idsByIndex.containsKey(i)) i,
    ];
  }

  Future<void> _waitUntilIdle(Duration idleTimeout) async {
    final idle = Completer<void>();
    Timer timer = Timer(idleTimeout, idle.complete);
    final subscription = _updates.stream.listen((_) {
      timer.cancel();
      final done = _expectedCount != null && _missingIndices().isEmpty;
      timer = Timer(done ? Duration.zero : idleTimeout, () {
        if (!idle.isCompleted) {
          idle.complete();
        }
      });
    });
    await idle.future;
    timer.cancel();
    unawaited(subscription.cancel());
  }
}
