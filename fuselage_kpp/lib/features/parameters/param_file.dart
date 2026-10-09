/// Plain-text parameter file: one `NAME,VALUE` per line, `#` for comments
/// (the format Mission Planner and QGroundControl also read).
abstract final class ParamFile {
  static String encode(Map<String, double> values, {required String header}) {
    final ids = values.keys.toList()..sort();
    return ['# $header', for (final id in ids) '$id,${_format(values[id]!)}'].join('\n');
  }

  /// Parses [text]; throws [FormatException] naming the first bad line.
  static Map<String, double> decode(String text) {
    final values = <String, double>{};
    final lines = text.split(RegExp(r'\r?\n'));
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }
      final parts = line.split(RegExp(r'[,\t ]+'));
      final value = parts.length == 2 ? double.tryParse(parts[1]) : null;
      if (value == null) {
        throw FormatException('Line ${i + 1} is not "NAME,VALUE": $line');
      }
      values[parts[0]] = value;
    }
    return values;
  }

  static String _format(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
}
