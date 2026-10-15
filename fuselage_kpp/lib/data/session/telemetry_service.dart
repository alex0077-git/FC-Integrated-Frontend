import 'dart:async';

import 'package:fuselage_kpp/data/session/fc_telemetry.dart';
import 'package:fuselage_kpp/data/session/mavlink_connection.dart';

/// Folds incoming MAVLink messages into the latest [FcTelemetry].
class TelemetryService {
  TelemetryService(MavlinkConnection connection) {
    _subscription = connection.messages.listen((message) {
      final next = _current.apply(message);
      if (!identical(next, _current)) {
        _current = next;
        _updates.add(next);
      }
    });
    // Refresh UI when msgid-207 sats go stale (>3s → "—").
    _staleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_updates.isClosed) {
        return;
      }
      final at = _current.gpsSatsReceivedAt;
      if (at == null) {
        return;
      }
      if (DateTime.now().difference(at) > FcTelemetry.gpsSatsStaleAfter) {
        _updates.add(_current);
      }
    });
  }

  late final StreamSubscription<Object> _subscription;
  Timer? _staleTimer;
  final StreamController<FcTelemetry> _updates = StreamController.broadcast();
  FcTelemetry _current = const FcTelemetry();

  FcTelemetry get current => _current;

  Stream<FcTelemetry> get updates => _updates.stream;

  Future<void> dispose() async {
    _staleTimer?.cancel();
    unawaited(_subscription.cancel());
    if (!_updates.isClosed) {
      unawaited(_updates.close());
    }
  }
}
