import 'package:fc_frontend/data/models/flight_parameters.dart';
import 'package:fuselage_kpp/data/session/fc_session.dart';

/// Pushes FC-frontend flight settings onto the live K++ when those params exist.
Future<void> syncFlightParametersToFc(
  FcSession session,
  FlightParameters parameters,
) async {
  final values = session.parameters.values;
  Future<void> setIfPresent(String id, double value) async {
    if (!values.containsKey(id)) {
      return;
    }
    await session.parameters.setParam(id, value);
  }

  // ANGLE_MAX is centi-degrees on ArduPilot-style stacks.
  await setIfPresent('ANGLE_MAX', parameters.maxRollAngle * 100);
  await setIfPresent('ABPOINT_SPEED', parameters.cruiseSpeed);
  await setIfPresent('WPNAV_LOIT_SPEED', parameters.cruiseSpeed * 100);
  await setIfPresent('LAND_SPEED', (parameters.cruiseSpeed * 0.5).clamp(0.5, 5));
}

/// Adjusts BATT_VOLT_MULT so the FC voltage matches a meter reading.
Future<void> calibrateBatteryVoltage({
  required FcSession session,
  required double meterVolts,
}) async {
  final reported = session.telemetry.current.voltage;
  if (reported == null || reported <= 0) {
    throw StateError('No battery voltage from the live flight controller yet.');
  }
  if (meterVolts <= 0) {
    throw StateError('Enter a valid meter voltage.');
  }
  final currentMult = session.parameters.values['BATT_VOLT_MULT'] ?? 1.0;
  final nextMult = currentMult * (meterVolts / reported);
  await session.parameters.setParam('BATT_VOLT_MULT', nextMult);
}
