import 'dart:math' as math;

import 'package:flutter/material.dart';

/// K++-assistant style motor layout: yellow nose, M1… ports, CW / CCW arrows.
///
/// Drawn top-down with the aircraft nose toward the top of the widget.
class FrameLayoutDiagram extends StatelessWidget {
  const FrameLayoutDiagram({
    super.key,
    required this.frameId,
    this.size = 128,
    this.selected = false,
  });

  /// 1 Quad X, 2 Quad +, 3 Hexa X, 4 Hexa +, 5 Octo X, 6 Octo +.
  final int frameId;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FrameLayoutPainter(
          frameId: frameId,
          armColor: selected ? scheme.primary : scheme.outline,
          bodyColor: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          motorFill: selected ? scheme.primary : scheme.secondaryContainer,
          motorInk: selected ? scheme.onPrimary : scheme.onSecondaryContainer,
          noseColor: const Color(0xFFF5C518),
          cwColor: const Color(0xFFE11D48),
          ccwColor: const Color(0xFF2563EB),
        ),
      ),
    );
  }
}

enum _Spin { clockwise, anticlockwise }

class _MotorSpot {
  const _MotorSpot({
    required this.number,
    required this.offset,
    required this.spin,
  });

  final int number;
  final Offset offset;
  final _Spin spin;
}

class _FrameLayoutPainter extends CustomPainter {
  _FrameLayoutPainter({
    required this.frameId,
    required this.armColor,
    required this.bodyColor,
    required this.motorFill,
    required this.motorInk,
    required this.noseColor,
    required this.cwColor,
    required this.ccwColor,
  });

  final int frameId;
  final Color armColor;
  final Color bodyColor;
  final Color motorFill;
  final Color motorInk;
  final Color noseColor;
  final Color cwColor;
  final Color ccwColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    final motors = _motors(frameId, radius);
    final motorR = size.shortestSide * 0.105;

    final armPaint = Paint()
      ..color = armColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Yellow nose arm first (K++ assistant convention).
    final noseArm = motors.isEmpty
        ? Offset(0, -radius)
        : motors.map((m) => m.offset).reduce(
              (a, b) => a.dy <= b.dy ? a : b,
            );
    canvas.drawLine(
      center,
      center + noseArm,
      Paint()
        ..color = noseColor
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    for (final motor in motors) {
      if ((motor.offset - noseArm).distance < 0.5) {
        continue;
      }
      canvas.drawLine(center, center + motor.offset, armPaint);
    }

    final bodyR = radius * 0.26;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: bodyR * 1.7, height: bodyR * 1.7),
        const Radius.circular(6),
      ),
      Paint()..color = bodyColor,
    );

    // Nose chevron.
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - bodyR * 1.05)
        ..lineTo(center.dx - 5, center.dy - bodyR * 0.35)
        ..lineTo(center.dx + 5, center.dy - bodyR * 0.35)
        ..close(),
      Paint()..color = noseColor,
    );

    final numberStyle = TextStyle(
      color: motorInk,
      fontSize: size.shortestSide * 0.095,
      fontWeight: FontWeight.w800,
    );

    for (final motor in motors) {
      final pos = center + motor.offset;
      final spinColor = motor.spin == _Spin.clockwise ? cwColor : ccwColor;

      canvas.drawCircle(pos, motorR, Paint()..color = motorFill);
      canvas.drawCircle(
        pos,
        motorR,
        Paint()
          ..color = spinColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      _drawSpinArrow(canvas, pos, motorR * 1.55, motor.spin, spinColor);

      final tp = TextPainter(
        text: TextSpan(text: 'M${motor.number}', style: numberStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    _drawLegend(canvas, size);
  }

  void _drawSpinArrow(
    Canvas canvas,
    Offset center,
    double radius,
    _Spin spin,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Screen y grows downward; clockwise on screen matches aircraft top-view CW.
    final start = spin == _Spin.clockwise ? -2.2 : -0.9;
    final sweep = spin == _Spin.clockwise ? 1.8 : -1.8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      paint,
    );

    final endAngle = start + sweep;
    final tip = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    final tangent = spin == _Spin.clockwise
        ? Offset(-math.sin(endAngle), math.cos(endAngle))
        : Offset(math.sin(endAngle), -math.cos(endAngle));
    final normal = Offset(-tangent.dy, tangent.dx);
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - tangent.dx * 7 + normal.dx * 3.5,
        tip.dy - tangent.dy * 7 + normal.dy * 3.5,
      )
      ..lineTo(
        tip.dx - tangent.dx * 7 - normal.dx * 3.5,
        tip.dy - tangent.dy * 7 - normal.dy * 3.5,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = color);
  }

  void _drawLegend(Canvas canvas, Size size) {
    final style = TextStyle(
      fontSize: size.shortestSide * 0.07,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF334155),
    );
    final cw = TextPainter(
      text: TextSpan(text: 'CW ↻', style: style.copyWith(color: cwColor)),
      textDirection: TextDirection.ltr,
    )..layout();
    final ccw = TextPainter(
      text: TextSpan(text: 'CCW ↺', style: style.copyWith(color: ccwColor)),
      textDirection: TextDirection.ltr,
    )..layout();
    cw.paint(canvas, Offset(4, size.height - cw.height - 2));
    ccw.paint(canvas, Offset(size.width - ccw.width - 4, size.height - ccw.height - 2));
  }

  /// Motor spots matching K++ assistant port order (M1…) and spin.
  List<_MotorSpot> _motors(int id, double radius) {
    // Angle 0 = right, −90° = nose (up). Order matches JIYI M1… numbering.
    final specs = switch (id) {
      2 => const [
          // Quad +: Front, Right, Rear, Left
          (1, -90.0, _Spin.anticlockwise),
          (2, 0.0, _Spin.clockwise),
          (3, 90.0, _Spin.anticlockwise),
          (4, 180.0, _Spin.clockwise),
        ],
      3 => const [
          // Hexa X
          (1, -60.0, _Spin.anticlockwise),
          (2, 0.0, _Spin.clockwise),
          (3, 60.0, _Spin.anticlockwise),
          (4, 120.0, _Spin.clockwise),
          (5, 180.0, _Spin.anticlockwise),
          (6, -120.0, _Spin.clockwise),
        ],
      4 => const [
          // Hexa +
          (1, -90.0, _Spin.anticlockwise),
          (2, -30.0, _Spin.clockwise),
          (3, 30.0, _Spin.anticlockwise),
          (4, 90.0, _Spin.clockwise),
          (5, 150.0, _Spin.anticlockwise),
          (6, -150.0, _Spin.clockwise),
        ],
      5 => const [
          // Octo X
          (1, -67.5, _Spin.anticlockwise),
          (2, -22.5, _Spin.clockwise),
          (3, 22.5, _Spin.anticlockwise),
          (4, 67.5, _Spin.clockwise),
          (5, 112.5, _Spin.anticlockwise),
          (6, 157.5, _Spin.clockwise),
          (7, -157.5, _Spin.anticlockwise),
          (8, -112.5, _Spin.clockwise),
        ],
      6 => const [
          // Octo +
          (1, -90.0, _Spin.anticlockwise),
          (2, -45.0, _Spin.clockwise),
          (3, 0.0, _Spin.anticlockwise),
          (4, 45.0, _Spin.clockwise),
          (5, 90.0, _Spin.anticlockwise),
          (6, 135.0, _Spin.clockwise),
          (7, 180.0, _Spin.anticlockwise),
          (8, -135.0, _Spin.clockwise),
        ],
      _ => const [
          // Quad X (default) — K++: FR M1 CCW, RR M2 CW, RL M3 CCW, FL M4 CW
          (1, -45.0, _Spin.anticlockwise),
          (2, 45.0, _Spin.clockwise),
          (3, 135.0, _Spin.anticlockwise),
          (4, -135.0, _Spin.clockwise),
        ],
    };

    return [
      for (final (number, deg, spin) in specs)
        _MotorSpot(
          number: number,
          spin: spin,
          offset: Offset(
            radius * math.cos(deg * math.pi / 180),
            radius * math.sin(deg * math.pi / 180),
          ),
        ),
    ];
  }

  @override
  bool shouldRepaint(covariant _FrameLayoutPainter oldDelegate) {
    return oldDelegate.frameId != frameId ||
        oldDelegate.armColor != armColor ||
        oldDelegate.motorFill != motorFill ||
        oldDelegate.noseColor != noseColor;
  }
}

/// Simple shape cue for SHAPE param (Standard / Coaxial / Y6).
class FrameShapeDiagram extends StatelessWidget {
  const FrameShapeDiagram({
    super.key,
    required this.shapeId,
    this.size = 72,
    this.selected = false,
  });

  final int shapeId;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapePainter(
          shapeId: shapeId,
          color: selected ? scheme.primary : scheme.outline,
          fill: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          upperColor: const Color(0xFF2563EB),
          lowerColor: const Color(0xFFF97316),
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({
    required this.shapeId,
    required this.color,
    required this.fill,
    required this.upperColor,
    required this.lowerColor,
  });

  final int shapeId;
  final Color color;
  final Color fill;
  final Color upperColor;
  final Color lowerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.28;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final fillPaint = Paint()..color = fill;

    if (shapeId == 1) {
      // Coaxial — blue upper / orange lower (K++ assistant).
      final top = c.translate(0, -r * 0.35);
      final bottom = c.translate(0, r * 0.35);
      canvas.drawCircle(top, r * 0.7, Paint()..color = upperColor.withValues(alpha: 0.35));
      canvas.drawCircle(top, r * 0.7, Paint()
        ..color = upperColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
      canvas.drawCircle(bottom, r * 0.7, Paint()..color = lowerColor.withValues(alpha: 0.35));
      canvas.drawCircle(bottom, r * 0.7, Paint()
        ..color = lowerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
      return;
    }
    if (shapeId == 2) {
      for (final deg in const [-90.0, 150.0, 30.0]) {
        final o = Offset(
          r * 1.4 * math.cos(deg * math.pi / 180),
          r * 1.4 * math.sin(deg * math.pi / 180),
        );
        canvas.drawLine(c, c + o, stroke);
        canvas.drawCircle(c + o, r * 0.55, fillPaint);
        canvas.drawCircle(c + o, r * 0.55, stroke);
      }
      return;
    }
    canvas.drawCircle(c, r, fillPaint);
    canvas.drawCircle(c, r, stroke);
    canvas.drawLine(c.translate(-r * 1.3, 0), c.translate(r * 1.3, 0), stroke);
    canvas.drawLine(c.translate(0, -r * 1.3), c.translate(0, r * 1.3), stroke);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.shapeId != shapeId || oldDelegate.color != color;
  }
}
