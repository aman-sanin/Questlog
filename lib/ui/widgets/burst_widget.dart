import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class BurstWidget extends StatefulWidget {
  final double size;
  final Widget? child;
  final bool animate;

  const BurstWidget({
    super.key,
    this.size = 180.0,
    this.child,
    this.animate = true,
  });

  @override
  State<BurstWidget> createState() => _BurstWidgetState();
}

class _BurstWidgetState extends State<BurstWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    Widget burstPaint = CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _BurstPainter(
        color: tokens.textPrimary.withOpacity(0.20),
        strokeWidth: 1.5,
      ),
    );

    if (widget.animate) {
      burstPaint = RotationTransition(
        turns: _controller,
        child: burstPaint,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          burstPaint,
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _BurstPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.75;
    const lobes = 12;

    final path = Path();
    for (int i = 0; i < lobes * 2; i++) {
      final angle = (i * pi) / lobes - pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
