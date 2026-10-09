/// Rules that involve more than one parameter, enforced before writing.
///
/// Returns an error message, or null when [value] is acceptable for [id]
/// given the other current values.
String? crossParamError(String id, double value, Map<String, double> values) {
  switch (id) {
    case 'FS_BATT_VOLTAGE':
      final level1 = values['FS_BATT_WARNING'];
      if (level1 != null && value >= level1) {
        return 'Level 2 voltage must be lower than level 1 (${level1.toStringAsFixed(1)} V)';
      }
    case 'FS_BATT_WARNING':
      final level2 = values['FS_BATT_VOLTAGE'];
      if (level2 != null && value <= level2) {
        return 'Level 1 voltage must be higher than level 2 (${level2.toStringAsFixed(1)} V)';
      }
  }
  return null;
}
