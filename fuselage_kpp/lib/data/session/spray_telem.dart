import 'dart:typed_data';

import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';

/// Live spray / liquid readings from the K++ (flow meter on K1, level on K2).
class SprayTelemReading {
  const SprayTelemReading({
    this.flowRateLpm,
    this.liquidLevelPercent,
    this.sprayedLiters,
    this.liquidValue,
  });

  /// Instantaneous flow from the K1 flow meter (L/min), when known.
  final double? flowRateLpm;

  /// Tank / level sensor reading (0–100), when known.
  final double? liquidLevelPercent;

  /// Cumulative volume sprayed this session (L), when known.
  final double? sprayedLiters;

  /// Raw assistant-style `liquidValue` (flow L/min or level %), when known.
  final double? liquidValue;
}

/// Best-effort decode of K++ spray / liquid telemetry.
///
/// JIYI’s assistant shows `liquidValue` live; the exact proprietary msgid is
/// not confirmed on the wire yet. We accept short unknown payloads whose
/// floats look like flow (0–8 L/min) or level (0–100 %), and STATUS_TEXT
/// lines that mention flow / L/min.
abstract final class SprayTelem {
  static const double maxPlausibleFlowLpm = 8;
  static const double maxPlausibleLevelPercent = 100;

  /// Proprietary status ids that sit near liquid UI symbols in JIYI221014.
  static const Set<int> candidateMsgIds = {204, 210, 216, 221, 222, 223, 224};

  static SprayTelemReading? fromUnknown(UnknownMavMessage message) {
    if (!candidateMsgIds.contains(message.messageId)) {
      return null;
    }
    final payload = message.payload;
    if (payload.length < 4) {
      return null;
    }
    final data = ByteData.sublistView(payload);
    final floats = <double>[];
    for (var i = 0; i + 4 <= payload.length; i += 4) {
      final value = data.getFloat32(i, Endian.little);
      if (value.isFinite) {
        floats.add(value);
      }
    }
    if (floats.isEmpty) {
      return null;
    }

    double? flow;
    double? level;
    double? sprayed;
    double? liquidValue;

    for (final value in floats) {
      // 0–8 L/min → flow meter (K1). Above that up to 100 → level %.
      if (_isFlowLpm(value)) {
        flow ??= value;
        liquidValue ??= value;
      } else if (_isLevelPercent(value)) {
        level ??= value;
        liquidValue ??= value;
      } else if (_isSprayedLiters(value)) {
        sprayed ??= value;
      }
    }

    if (flow == null && level == null && sprayed == null) {
      return null;
    }

    return SprayTelemReading(
      flowRateLpm: flow,
      liquidLevelPercent: level,
      sprayedLiters: sprayed,
      liquidValue: liquidValue,
    );
  }

  static SprayTelemReading? fromStatusText(String text) {
    final lower = text.toLowerCase();
    final flowMatch = RegExp(
      r'(?:flow|l/?min|流量)\s*[:=]?\s*(-?\d+(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch(lower);
    final levelMatch = RegExp(
      r'(?:liquid|level|液位)\s*[:=]?\s*(-?\d+(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch(lower);
    final sprayedMatch = RegExp(
      r'(?:sprayed|dosage|已喷)\s*[:=]?\s*(-?\d+(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch(lower);

    double? flow;
    double? level;
    double? sprayed;
    if (flowMatch != null) {
      flow = double.tryParse(flowMatch.group(1)!);
      if (flow != null && !_isFlowLpm(flow)) {
        flow = null;
      }
    }
    if (levelMatch != null) {
      level = double.tryParse(levelMatch.group(1)!);
      if (level != null && !_isLevelPercent(level)) {
        level = null;
      }
    }
    if (sprayedMatch != null) {
      sprayed = double.tryParse(sprayedMatch.group(1)!);
      if (sprayed != null && !_isSprayedLiters(sprayed)) {
        sprayed = null;
      }
    }
    if (flow == null && level == null && sprayed == null) {
      return null;
    }
    return SprayTelemReading(
      flowRateLpm: flow,
      liquidLevelPercent: level,
      sprayedLiters: sprayed,
      liquidValue: flow ?? level,
    );
  }

  static bool _isFlowLpm(double value) => value >= 0 && value <= maxPlausibleFlowLpm;

  static bool _isLevelPercent(double value) =>
      value > maxPlausibleFlowLpm && value <= maxPlausibleLevelPercent;

  static bool _isSprayedLiters(double value) => value >= 0 && value <= 500;
}
