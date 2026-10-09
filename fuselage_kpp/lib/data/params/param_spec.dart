/// Screens of the app that edit parameters, mirroring the K++ assistant's
/// Basic / Advanced / Tools groupings.
enum ParamSection {
  installation,
  remoteControl,
  rcCalibration,
  flight,
  basicGains,
  controlGains,
  speedGains,
  protection,
  pump,
  liquid,
  spraying,
  fence,
  extensions,
  channels,
  system,
}

/// Describes one flight-controller parameter and how to edit it.
///
/// [options] is only set where the numeric value of each choice is known.
/// Choices whose values are unconfirmed are described in [help] instead, so
/// the user always sees and writes the raw number.
class ParamSpec {
  const ParamSpec({
    required this.id,
    required this.label,
    required this.section,
    required this.simulatedDefault,
    this.unit = '',
    this.min,
    this.max,
    this.decimals = 0,
    this.options,
    this.help,
    this.readOnly = false,
  });

  final String id;
  final String label;
  final ParamSection section;
  final String unit;
  final double? min;
  final double? max;
  final int decimals;
  final Map<int, String>? options;
  final String? help;
  final bool readOnly;

  /// Value used only by the built-in simulator.
  final double simulatedDefault;

  /// Returns an error message, or null when [value] is acceptable.
  String? validate(double value) {
    if (min != null && value < min!) {
      return 'Minimum is ${formatValue(min!)}';
    }
    if (max != null && value > max!) {
      return 'Maximum is ${formatValue(max!)}';
    }
    if (options != null && !options!.containsKey(value.round())) {
      return 'Choose one of the listed options';
    }
    return null;
  }

  String formatValue(double value) => value.toStringAsFixed(decimals);
}
