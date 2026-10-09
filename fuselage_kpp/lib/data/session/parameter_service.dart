import 'dart:async';

import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
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
  static const Duration _ackTimeout = Duration(milliseconds: 1500);
  static const int _maxAttempts = 3;
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
  Future<void> downloadAll({void Function(int received, int total)? onProgress}) async {
    _idsByIndex.clear();
    _expectedCount = null;
    final progress = _updates.stream.listen((_) {
      final total = _expectedCount;
      if (total != null) {
        onProgress?.call(_idsByIndex.length, total);
      }
    });
    try {
      // K++ answers reliably after a READ kick + LIST (JIYI does the same on the wire).
      for (var kick = 0; kick < _maxAttempts && _expectedCount == null; kick++) {
        _sendParamRead(0);
        _sendParamList();
        await _waitUntilIdle();
      }
      for (var attempt = 0; attempt < _maxAttempts && _missingIndices().isNotEmpty; attempt++) {
        final missing = _missingIndices();
        // Batch a modest window so we do not flood the link.
        final batch = missing.take(40);
        for (final index in batch) {
          _sendParamRead(index);
        }
        await _waitUntilIdle();
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

  void _sendParamList() {
    _connection.send(
      ParamRequestList(targetSystem: _connection.targetSystem, targetComponent: _connection.targetComponent),
    );
  }

  void _sendParamRead(int index) {
    _connection.send(
      ParamRequestRead(
        targetSystem: _connection.targetSystem,
        targetComponent: _connection.targetComponent,
        paramId: '',
        paramIndex: index,
      ),
    );
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
          throw ParameterException('$id was rejected: the flight controller kept ${_format(stored)}.');
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

  Future<void> _waitUntilIdle() async {
    final idle = Completer<void>();
    Timer timer = Timer(_listIdleTimeout, idle.complete);
    final subscription = _updates.stream.listen((_) {
      timer.cancel();
      final done = _expectedCount != null && _missingIndices().isEmpty;
      timer = Timer(done ? Duration.zero : _listIdleTimeout, () {
        if (!idle.isCompleted) {
          idle.complete();
        }
      });
    });
    await idle.future;
    timer.cancel();
    unawaited(subscription.cancel());
  }

  static String _format(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
}
