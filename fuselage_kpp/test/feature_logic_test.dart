import 'package:flutter_test/flutter_test.dart';
import 'package:fuselage_kpp/features/channels/channels_page.dart';
import 'package:fuselage_kpp/features/parameters/param_file.dart';
import 'package:fuselage_kpp/features/params/param_rules.dart';
import 'package:fuselage_kpp/features/remote_control/stick_calibration.dart';

void main() {
  group('StickCalibration', () {
    test('records extremes and centre into RC params', () {
      final calibration = StickCalibration()
        ..recordExtremes([1500, 1500, 1500, 1500])
        ..recordExtremes([1095, 1102, 1090, 1100])
        ..recordExtremes([1905, 1898, 1910, 1900])
        ..recordCentre([1501, 1499, 1100, 1500]);

      expect(calibration.results().first.toParams(), {'RC1_MIN': 1095, 'RC1_MAX': 1905, 'RC1_TRIM': 1501});
      expect(calibration.invalidChannels(), isEmpty);
    });

    test('flags channels with too little travel or no data', () {
      final calibration = StickCalibration()
        ..recordExtremes([1400, 1100, 1100, 0])
        ..recordExtremes([1600, 1900, 1900, 0])
        ..recordCentre([1500, 1500, 1500, 0]);

      expect(calibration.invalidChannels(), [1, 4]);
    });
  });

  group('ParamFile', () {
    test('round-trips values and ignores comments', () {
      final text = ParamFile.encode({'RTL_ALT': 1500, 'FS_BATT_WARNING': 44.5}, header: 'test');

      expect(text, startsWith('# test'));
      expect(ParamFile.decode(text), {'RTL_ALT': 1500, 'FS_BATT_WARNING': 44.5});
    });

    test('names the first malformed line', () {
      expect(
        () => ParamFile.decode('RTL_ALT,1500\nBROKEN LINE HERE'),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Line 2'))),
      );
    });
  });

  test('level 2 battery voltage must stay below level 1', () {
    final values = {'FS_BATT_WARNING': 44.4, 'FS_BATT_VOLTAGE': 43.2};

    expect(crossParamError('FS_BATT_VOLTAGE', 45, values), contains('lower'));
    expect(crossParamError('FS_BATT_WARNING', 43, values), contains('higher'));
    expect(crossParamError('FS_BATT_VOLTAGE', 42, values), isNull);
  });

  test('duplicate channel functions are reported, unused (0) is ignored', () {
    final duplicates = duplicateChannelFunctions({
      'CH6_OPT': 3,
      'CH7_OPT': 0,
      'CH8_OPT': 0,
      'CH9_OPT': 3,
      'CH10_OPT': 5,
    });

    expect(duplicates, ['function 3 on CH6, CH9']);
  });
}
