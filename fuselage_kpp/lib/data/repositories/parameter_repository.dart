import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/session/parameter_service.dart';

/// Latest parameter values from the connected flight controller, by id.
class ParamValuesController extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() {
    final session = ref.watch(fcSessionProvider);
    if (session == null) {
      return const {};
    }
    final subscription = session.parameters.updates.listen((update) {
      state = {...state, update.paramId: update.value};
    });
    ref.onDispose(subscription.cancel);
    return session.parameters.values;
  }

  /// Writes a parameter and returns the value the flight controller stored.
  Future<double> write(String id, double value) {
    final session = ref.read(fcSessionProvider);
    if (session == null) {
      throw const ParameterException('Not connected to a flight controller.');
    }
    return session.parameters.setParam(id, value);
  }
}

final paramValuesProvider = NotifierProvider<ParamValuesController, Map<String, double>>(ParamValuesController.new);
