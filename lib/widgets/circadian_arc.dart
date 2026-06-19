import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../domain/circadian_models.dart';
import '../theme/dawn_palette.dart';

class CircadianArc extends StatelessWidget {
  final List<DayBand> bands;
  final double sunHour;
  final double moonHour;
  final double height;

  const CircadianArc({
    super.key,
    required this.bands,
    this.sunHour = 13,
    this.moonHour = 1,
    this.height = 168,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ArcPainter(
          bands: bands,
          sunHour: sunHour,
          moonHour: moonHour,
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final List<DayBand> bands;
  final double sunHour;
  final double moonHour;

  _ArcPainter({
    required this.bands,
    required this.sunHour,
    required this.moonHour,
  });

  static const double _start = math.pi;
  static const double _sweep = math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.94);
    final radius = math.min(size.width / 2 - 18, size.height * 0.86);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = DawnPalette.canvasDeep;
    canvas.drawArc(rect, _start, _sweep, false, track);

    for (final band in bands) {
      final a = _angle(band.fromHour);
      final b = _angle(band.toHour);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = _bandColor(band.kind);
      canvas.drawArc(rect, a, b - a, false, paint);
    }

    _drawGlyph(canvas, center, radius, sunHour, _Glyph.sun);
    _drawGlyph(canvas, center, radius, moonHour, _Glyph.moon);
  }

  double _angle(double hour) => _start + (hour / 24.0) * _sweep;

  Color _bandColor(BandKind kind) {
    switch (kind) {
      case BandKind.seekLight:
        return DawnPalette.noon;
      case BandKind.avoidLight:
        return DawnPalette.dusk;
      case BandKind.sleep:
        return DawnPalette.duskDeep;
      case BandKind.move:
        return DawnPalette.dawn;
    }
  }

  void _drawGlyph(
      Canvas canvas, Offset center, double radius, double hour, _Glyph glyph) {
    final angle = _angle(hour);
    final pos = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    final halo = Paint()..color = DawnPalette.surface;
    canvas.drawCircle(pos, 13, halo);
    if (glyph == _Glyph.sun) {
      final core = Paint()..color = DawnPalette.noon;
      canvas.drawCircle(pos, 8, core);
      final ray = Paint()
        ..color = DawnPalette.noon
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 8; i++) {
        final ra = i * math.pi / 4;
        canvas.drawLine(
          Offset(pos.dx + 10 * math.cos(ra), pos.dy + 10 * math.sin(ra)),
          Offset(pos.dx + 13 * math.cos(ra), pos.dy + 13 * math.sin(ra)),
          ray,
        );
      }
    } else {
      final core = Paint()..color = DawnPalette.dusk;
      canvas.drawCircle(pos, 8, core);
      final notch = Paint()..color = DawnPalette.surface;
      canvas.drawCircle(Offset(pos.dx + 3.4, pos.dy - 2.4), 6.4, notch);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.bands != bands ||
      old.sunHour != sunHour ||
      old.moonHour != moonHour;
}

enum _Glyph { sun, moon }
