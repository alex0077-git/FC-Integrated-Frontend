import 'package:fc_frontend/data/kpp/telemetry_mapper.dart';
import 'package:fc_frontend/data/models/battery_level.dart';
import 'package:fc_frontend/data/models/battery_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

void main() {
  const settings = BatterySettings();

  test('shows exact FC remaining percent', () {
    final battery = BatteryDisplay.fromFc(remaining: 77, voltage: 24.0);
    expect(battery.percent, 77);
    expect(batteryAlertLevel(battery, settings), isNull);
  });

  test('does not invent percent from voltage', () {
    final battery = BatteryDisplay.fromFc(remaining: null, voltage: 25.33);
    expect(battery.percent, isNull);
    expect(battery.voltage, 25.33);
    expect(batteryAlertLevel(battery, settings), isNull);
  });

  test('exact 0% from FC is shown as 0 (not estimated)', () {
    final battery = BatteryDisplay.fromFc(remaining: 0, voltage: 25.33);
    expect(battery.percent, 0);
    expect(batteryAlertLevel(battery, settings), BatteryAlertLevel.critical);
  });

  test('low volts without percent still warn from voltage thresholds', () {
    final battery = BatteryDisplay.fromFc(remaining: null, voltage: 19.0);
    expect(battery.percent, isNull);
    expect(batteryAlertLevel(battery, settings), BatteryAlertLevel.critical);
  });

  test('mapper passes through FC remaining and voltage only', () {
    const source = FcTelemetry(
      voltage: 25.33,
      batteryRemaining: 64,
      customMode: 0,
    );
    final mapped = mapFcTelemetry(source);
    expect(mapped.battery, 64);
    expect(mapped.batteryVoltage, 25.33);
    expect(mapped.batteryRemainingRaw, 64);
  });
}
