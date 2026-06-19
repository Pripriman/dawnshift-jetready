import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/dawn_palette.dart';

class PhaseDial extends StatelessWidget {
  final double size;
  final double readiness;
  final double stroke;
  final Widget? child;

  const PhaseDial({
    super.key,
    required this.size,
    required this.readiness,
    this.stroke = 12,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DialPainter(
          readiness: readiness.clamp(0, 1).toDouble(),
          stroke: stroke,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double readiness;
  final double stroke;

  _DialPainter({required this.readiness, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = DawnPalette.canvasDeep;
    canvas.drawCircle(center, radius, track);

    if (readiness <= 0) return;

    final sweep = 2 * math.pi * readiness;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [DawnPalette.dawn, DawnPalette.noon, DawnPalette.dusk],
        startAngle: 0,
        endAngle: math.pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.readiness != readiness || old.stroke != stroke;
}
