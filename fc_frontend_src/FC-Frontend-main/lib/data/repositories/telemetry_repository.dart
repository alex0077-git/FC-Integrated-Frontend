import 'package:fc_frontend/data/kpp/telemetry_mapper.dart';
import 'package:fc_frontend/data/models/telemetry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/session/fc_session.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

/// True when a live (non-simulator) K++ session is open (USB or wireless).
final telemetryConnectionProvider = Provider<bool>((ref) {
  final connection = ref.watch(fcConnectionProvider);
  final session = connection.session;
  if (session == null || session.isSimulated) {
    return false;
  }
  return connection.status == FcLinkStatus.connected ||
      connection.status == FcLinkStatus.linkLost ||
      connection.status == FcLinkStatus.loadingParameters;
});

final telemetryStreamProvider = StreamProvider<Telemetry>((ref) {
  final session = ref.watch(fcSessionProvider);
  if (session == null) {
    return const Stream<Telemetry>.empty();
  }
  return _sessionTelemetry(session);
});

Stream<Telemetry> _sessionTelemetry(FcSession session) async* {
  final current = session.telemetry.current;
  if (_hasUsefulFix(current)) {
    yield mapFcTelemetry(current);
  }
  await for (final update in session.telemetry.updates) {
    yield mapFcTelemetry(update);
  }
}

bool _hasUsefulFix(FcTelemetry telemetry) {
  return telemetry.latDeg != null ||
      telemetry.satellites != null ||
      telemetry.customMode != null ||
      telemetry.batteryRemaining != null ||
      telemetry.voltage != null;
}
