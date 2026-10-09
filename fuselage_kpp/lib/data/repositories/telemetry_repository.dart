import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

/// Live telemetry from the connected flight controller.
class TelemetryController extends Notifier<FcTelemetry> {
  @override
  FcTelemetry build() {
    final session = ref.watch(fcSessionProvider);
    if (session == null) {
      return const FcTelemetry();
    }
    final subscription = session.telemetry.updates.listen((telemetry) => state = telemetry);
    ref.onDispose(subscription.cancel);
    return session.telemetry.current;
  }
}

final telemetryProvider = NotifierProvider<TelemetryController, FcTelemetry>(TelemetryController.new);
