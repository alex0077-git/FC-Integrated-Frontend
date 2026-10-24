import 'package:fc_frontend/data/kpp/telemetry_mapper.dart';
import 'package:fc_frontend/data/models/battery_level.dart';
import 'package:fc_frontend/data/models/battery_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';

void main() {
  const settings = BatterySettings();

  test('shows exact FC remaining percent when present', () {
    final battery = BatteryDisplay.fromFc(remaining: 77, voltage: 24.0);
    expect(battery.percent, 77);
    expect(battery.percentFromVoltage, isFalse);
    expect(battery.hudLabel, contains('77%'));
    expect(batteryAlertLevel(battery, settings), isNull);
  });

  test('estimates attached-pack charge from FC pack voltage', () {
    final battery = BatteryDisplay.fromFc(
      remaining: null,
      voltage: 25.20,
      settings: settings,
    );
    expect(battery.percent, isNotNull);
    expect(battery.percent!, closeTo(100, 1));
    expect(battery.percentFromVoltage, isTrue);
    expect(battery.voltage, 25.20);
    expect(battery.hudLabel, contains('%'));
    expect(battery.hudLabel, contains('V'));
  });

  test('exact 0% from FC is shown as 0 (not estimated)', () {
    final battery = BatteryDisplay.fromFc(remaining: 0, voltage: 25.33);
    expect(battery.percent, 0);
    expect(battery.percentFromVoltage, isFalse);
    expect(batteryAlertLevel(battery, settings), BatteryAlertLevel.second);
  });

  test('12S pack uses settings cell count when it matches the attached pack', () {
    const twelveS = BatterySettings(cellCount: 12, maxVoltage: 50.4, minVoltage: 42.0);
    final battery = BatteryDisplay.fromFc(
      remaining: null,
      voltage: 48.20,
      settings: twelveS,
    );
    expect(battery.cellCount, 12);
    expect(battery.percent, isNotNull);
    expect(battery.percent!, greaterThan(50));
    expect(battery.percent!, lessThanOrEqualTo(100));
    expect(battery.percentFromVoltage, isTrue);
  });

  test('low estimated charge warns from percent thresholds', () {
    // 6S near empty (~3.33 V/cell) → ~0% → second warning.
    final battery = BatteryDisplay.fromFc(
      remaining: null,
      voltage: 20.0,
      settings: settings,
    );
    expect(battery.cellCount, 6);
    expect(battery.percent, lessThan(settings.secondWarningPercent));
    expect(batteryAlertLevel(battery, settings), BatteryAlertLevel.second);
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
