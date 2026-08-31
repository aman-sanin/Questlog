import 'package:flutter/material.dart';

class SigilPaths {
  // Returns a Path drawn on a 24x24 unit grid.
  static Path getPath(String domain) {
    final path = Path();
    switch (domain.toLowerCase()) {
      case 'warrior':
        // Sword / Cross / Shield
        path.moveTo(12, 2);
        path.lineTo(12, 22);
        path.moveTo(6, 6);
        path.lineTo(18, 6);
        path.moveTo(3, 10);
        path.lineTo(12, 2);
        path.lineTo(21, 10);
        break;
      case 'sage':
        // Diamond star / Concentric squares
        path.moveTo(12, 2);
        path.lineTo(22, 12);
        path.lineTo(12, 22);
        path.lineTo(2, 12);
        path.close();
        path.moveTo(12, 7);
        path.lineTo(17, 12);
        path.lineTo(12, 17);
        path.lineTo(7, 12);
        path.close();
        break;
      case 'monk':
        // Balance Lotus / Concentric Circles (drawn as diamonds for brutalist design)
        path.moveTo(12, 4);
        path.lineTo(20, 12);
        path.lineTo(12, 20);
        path.lineTo(4, 12);
        path.close();
        // Inner cross
        path.moveTo(12, 8);
        path.lineTo(12, 16);
        path.moveTo(8, 12);
        path.lineTo(16, 12);
        break;
      case 'bard':
        // Lyre / 12-lobe/8-lobe star
        path.moveTo(12, 2);
        path.quadraticBezierTo(15, 9, 22, 12);
        path.quadraticBezierTo(15, 15, 12, 22);
        path.quadraticBezierTo(9, 15, 2, 12);
        path.quadraticBezierTo(9, 9, 12, 2);
        path.close();
        break;
      case 'ranger':
        // Chevron Arrowhead
        path.moveTo(12, 2);
        path.lineTo(22, 12);
        path.lineTo(16, 12);
        path.lineTo(16, 22);
        path.lineTo(8, 22);
        path.lineTo(8, 12);
        path.lineTo(2, 12);
        path.close();
        break;
      case 'artificer':
      default:
        // Gear / Hammer shape (brutalist hammer)
        path.moveTo(6, 4);
        path.lineTo(18, 4);
        path.lineTo(18, 10);
        path.lineTo(6, 10);
        path.close();
        path.moveTo(12, 10);
        path.lineTo(12, 22);
        path.moveTo(9, 22);
        path.lineTo(15, 22);
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

class SigilWidget extends StatelessWidget {
  final String domain;
  final Color? color;
  final double size;
  final double strokeWidth;
  final double progress;

  const SigilWidget({
    super.key,
    required this.domain,
    this.color,
    this.size = 24.0,
    this.strokeWidth = 2.0,
    this.progress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).colorScheme.secondary; // Ember is default
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: SigilPainter(
          domain: domain,
          color: themeColor,
          strokeWidth: strokeWidth,
          progress: progress,
        ),
      ),
    );
  }
}
