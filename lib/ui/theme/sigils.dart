import 'dart:math' as math;
import 'package:flutter/material.dart';

class SigilPaths {
  /// Returns a canonical Path drawn on a 24x24 unit grid based on the design construction law:
  /// - Warrior: Shield
  /// - Sage: Orb
  /// - Monk: Ensō
  /// - Bard: Three Bars
  /// - Ranger: Peaks
  /// - Artificer: Hex-Dot
  static Path getPath(String domain) {
    final path = Path();
    switch (domain.toLowerCase()) {
      case 'warrior':
        // Shield
        path.moveTo(4, 4);
        path.lineTo(20, 4);
        path.lineTo(20, 13);
        path.quadraticBezierTo(20, 19, 12, 22);
        path.quadraticBezierTo(4, 19, 4, 13);
        path.close();
        // Shield vertical midline
        path.moveTo(12, 4);
        path.lineTo(12, 22);
        break;

      case 'sage':
        // Orb: Outer ring + inner nucleus + equator
        path.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9));
        path.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 4));
        path.moveTo(3, 12);
        path.lineTo(21, 12);
        break;

      case 'monk':
        // Ensō: Open circular brush arc + stillness dot
        path.addArc(
          Rect.fromCircle(center: const Offset(12, 12), radius: 8.5),
          -math.pi / 2 + 0.3,
          math.pi * 1.75,
        );
        path.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 2));
        break;

      case 'bard':
        // Three Bars: Left, tall center, right, connected by wave chord
        path.moveTo(6, 8);
        path.lineTo(6, 16);
        path.moveTo(12, 3);
        path.lineTo(12, 21);
        path.moveTo(18, 8);
        path.lineTo(18, 16);
        path.moveTo(3, 12);
        path.quadraticBezierTo(9, 8, 12, 12);
        path.quadraticBezierTo(15, 16, 21, 12);
        break;

      case 'ranger':
        // Peaks: Double angular mountain peaks
        path.moveTo(2, 20);
        path.lineTo(10, 5);
        path.lineTo(16, 15);
        path.lineTo(19, 9);
        path.lineTo(23, 20);
        path.close();
        path.moveTo(10, 5);
        path.lineTo(10, 20);
        break;

      case 'artificer':
      default:
        // Hex-Dot: Precise regular hexagon with central core dot
        path.moveTo(12, 2.5);
        path.lineTo(20.5, 7.5);
        path.lineTo(20.5, 16.5);
        path.lineTo(12, 21.5);
        path.lineTo(3.5, 16.5);
        path.lineTo(3.5, 7.5);
        path.close();
        path.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 2.5));
        break;
    }
    return path;
  }
}

class SigilPainter extends CustomPainter {
  final String domain;
  final Color color;
  final double strokeWidth;
  final double progress; // For draw-on animation (0.0 to 1.0)

  SigilPainter({
    required this.domain,
    required this.color,
    this.strokeWidth = 2.0,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final baseRawPath = SigilPaths.getPath(domain);

    // Scale path from 24x24 to widget size
    final matrix = Matrix4.identity()
      ..scale(size.width / 24.0, size.height / 24.0);
    final scaledPath = baseRawPath.transform(matrix.storage);

    if (progress >= 1.0) {
      canvas.drawPath(scaledPath, paint);
    } else if (progress > 0.0) {
      // Draw partially for the animation
      for (final pathMetric in scaledPath.computeMetrics()) {
        final extractPath = pathMetric.extractPath(0.0, pathMetric.length * progress);
        canvas.drawPath(extractPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SigilPainter oldDelegate) {
    return oldDelegate.domain != domain ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progress != progress;
  }
}
