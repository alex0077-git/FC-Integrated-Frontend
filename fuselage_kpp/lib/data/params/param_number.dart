/// Formats a FC parameter value the way Mission Planner-style files expect.
String formatParamNumber(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
