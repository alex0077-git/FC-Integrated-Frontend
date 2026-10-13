import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Schematic motor layout for a K++ FRAME id (1–6).
///
/// Drawn top-down with the aircraft nose toward the top of the widget.
class FrameLayoutDiagram extends StatelessWidget {
  const FrameLayoutDiagram({
    super.key,
    required this.frameId,
    this.size = 112,
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
          accent: scheme.primary,
        ),
      ),
    );
  }
}

class _FrameLayoutPainter extends CustomPainter {
  _FrameLayoutPainter({
    required this.frameId,
    required this.armColor,
    required this.bodyColor,
    required this.motorFill,
    required this.motorInk,
    required this.accent,
  });

  final int frameId;
  final Color armColor;
  final Color bodyColor;
  final Color motorFill;
  final Color motorInk;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.38;
    final motors = _motorOffsets(frameId, radius);

    final armPaint = Paint()
      ..color = armColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final motor in motors) {
      canvas.drawLine(center, center + motor.offset, armPaint);
    }

    final bodyPaint = Paint()..color = bodyColor;
    final bodyR = radius * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: bodyR * 1.6, height: bodyR * 1.6),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Nose marker (front).
    final nosePaint = Paint()..color = accent;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - bodyR * 0.95)
        ..lineTo(center.dx - 5, center.dy - bodyR * 0.35)
        ..lineTo(center.dx + 5, center.dy - bodyR * 0.35)
        ..close(),
      nosePaint,
    );

    final motorPaint = Paint()..color = motorFill;
    final textStyle = TextStyle(
      color: motorInk,
      fontSize: size.shortestSide * 0.12,
      fontWeight: FontWeight.w700,
    );

    for (final motor in motors) {
      final pos = center + motor.offset;
      canvas.drawCircle(pos, size.shortestSide * 0.11, motorPaint);
      final tp = TextPainter(
        text: TextSpan(text: '${motor.number}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  /// Motor positions relative to center. Angle 0 = right, −90° = nose (up).
  List<_MotorSpot> _motorOffsets(int id, double radius) {
    final anglesDegrees = switch (id) {
      2 => const [-90.0, 0.0, 90.0, 180.0], // Quad +
      3 => const [-60.0, 0.0, 60.0, 120.0, 180.0, -120.0], // Hexa X
      4 => const [-90.0, -30.0, 30.0, 90.0, 150.0, -150.0], // Hexa +
      5 => const [-67.5, -22.5, 22.5, 67.5, 112.5, 157.5, -157.5, -112.5], // Octo X
      6 => const [-90.0, -45.0, 0.0, 45.0, 90.0, 135.0, 180.0, -135.0], // Octo +
      _ => const [-45.0, 45.0, 135.0, -135.0], // Quad X
    };

    return [
      for (var i = 0; i < anglesDegrees.length; i++)
        _MotorSpot(
          number: i + 1,
          offset: Offset(
            radius * math.cos(anglesDegrees[i] * math.pi / 180),
            radius * math.sin(anglesDegrees[i] * math.pi / 180),
          ),
        ),
    ];
  }

  @override
  bool shouldRepaint(covariant _FrameLayoutPainter oldDelegate) {
    return oldDelegate.frameId != frameId ||
        oldDelegate.armColor != armColor ||
        oldDelegate.motorFill != motorFill ||
        oldDelegate.accent != accent;
  }
}

class _MotorSpot {
  const _MotorSpot({required this.number, required this.offset});

  final int number;
  final Offset offset;
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
  });

  final int shapeId;
  final Color color;
  final Color fill;

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
      // Coaxial — stacked motors
      final top = c.translate(0, -r * 0.35);
      final bottom = c.translate(0, r * 0.35);
      canvas.drawCircle(top, r * 0.7, fillPaint);
      canvas.drawCircle(top, r * 0.7, stroke);
      canvas.drawCircle(bottom, r * 0.7, fillPaint);
      canvas.drawCircle(bottom, r * 0.7, stroke);
      return;
    }
    if (shapeId == 2) {
      // Y6 — Y layout
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
    // Standard
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
