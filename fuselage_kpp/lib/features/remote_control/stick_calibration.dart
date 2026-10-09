import 'dart:math' as math;

/// Result for one stick channel: RCn_MIN / RCn_MAX / RCn_TRIM.
class ChannelCalibration {
  const ChannelCalibration({required this.channel, required this.min, required this.max, required this.trim});

  final int channel;
  final int min;
  final int max;
  final int trim;

  Map<String, double> toParams() => {
    'RC${channel}_MIN': min.toDouble(),
    'RC${channel}_MAX': max.toDouble(),
    'RC${channel}_TRIM': trim.toDouble(),
  };
}

/// Stick calibration for channels 1-4, following the K++ flow:
/// move every stick to its extremes, then centre them, then finish.
class StickCalibration {
  static const int stickChannels = 4;
  static const int minimumTravel = 400;

  final List<int> _min = List.filled(stickChannels, 1 << 30);
  final List<int> _max = List.filled(stickChannels, 0);
  List<int>? _centre;

  /// Feed live channel values while the sticks are moved to their extremes.
  void recordExtremes(List<int> channels) {
    for (var i = 0; i < stickChannels && i < channels.length; i++) {
      if (channels[i] == 0) {
        continue;
      }
      _min[i] = math.min(_min[i], channels[i]);
      _max[i] = math.max(_max[i], channels[i]);
    }
  }

  /// Capture the centred stick positions as trims.
  void recordCentre(List<int> channels) {
    _centre = [for (var i = 0; i < stickChannels; i++) i < channels.length ? channels[i] : 0];
  }

  /// Channels (1-based) whose travel is too small or whose centre lies
  /// outside the recorded range — the K++ "通道最大最小不符合范围" error.
  List<int> invalidChannels() {
    final centre = _centre;
    return [
      for (var i = 0; i < stickChannels; i++)
        if (!_hasData(i) ||
            _max[i] - _min[i] < minimumTravel ||
            centre == null ||
            centre[i] <= _min[i] ||
            centre[i] >= _max[i])
          i + 1,
    ];
  }

  bool _hasData(int index) => _max[index] > 0;

  List<ChannelCalibration> results() {
    final centre = _centre ?? List.filled(stickChannels, 0);
    return [
      for (var i = 0; i < stickChannels; i++)
        ChannelCalibration(channel: i + 1, min: _hasData(i) ? _min[i] : 0, max: _max[i], trim: centre[i]),
    ];
  }
}
