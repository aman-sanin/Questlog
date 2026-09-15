import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/keeper/expressions.dart';
import '../theme/tokens.dart';

/// Rotates the current expression's thought lines every few seconds (¬7).
class KeeperThoughtCarousel extends StatefulWidget {
  final KeeperExpression expression;
  final double maxWidth;
  const KeeperThoughtCarousel({
    super.key,
    required this.expression,
    this.maxWidth = 220,
  });

  @override
  State<KeeperThoughtCarousel> createState() => _KeeperThoughtCarouselState();
}

class _KeeperThoughtCarouselState extends State<KeeperThoughtCarousel> {
  int _pick = 0;
  Timer? _rotate;

  @override
  void initState() {
    super.initState();
    _rotate = Timer.periodic(
      const Duration(seconds: 7),
      (_) => setState(() => _pick++),
    );
  }

  @override
  void didUpdateWidget(KeeperThoughtCarousel old) {
    super.didUpdateWidget(old);
    if (old.expression != widget.expression && mounted) {
      setState(() => _pick = 0);
    }
  }

  @override
  void dispose() {
    _rotate?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThoughtBubble(
      text: KeeperThought.pick(widget.expression, _pick),
      maxWidth: widget.maxWidth,
    );
  }
}

/// A small monochrome thought bubble with a downward tail, used near the
/// Keeper's face ("Kiko Thinks"-style rotation, keeper.md §7).
class ThoughtBubble extends StatelessWidget {
  final String text;
  final double maxWidth;
  const ThoughtBubble({super.key, required this.text, this.maxWidth = 220});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: tokens.bg,
            border: Border.all(color: tokens.lineRest, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: tokens.body(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: tokens.textPrimary,
            ),
          ),
        ),
        CustomPaint(size: const Size(14, 7), painter: _TailPainter(tokens)),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  final AppTokens tokens;
  _TailPainter(this.tokens);

  @override
  void paint(Canvas canvas, Size size) {
    final triangle = Path()
      ..moveTo(0, 8)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, 8);
    canvas.drawPath(triangle, Paint()..color = tokens.bg);
    final edge = Paint()
      ..color = tokens.lineRest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, 8), Offset(size.width / 2, 0), edge);
    canvas.drawLine(Offset(size.width, 8), Offset(size.width / 2, 0), edge);
  }

  @override
  bool shouldRepaint(_TailPainter old) => true;
}