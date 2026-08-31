import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final clamped = progress.clamp(0.0, 1.0);
    final isDone = progress >= 1.0;

    return Container(
      height: height,
      width: double.infinity,
      color: tokens.tonal,
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: clamped,
        child: Container(
          color: isDone ? tokens.hero : tokens.accent,
        ),
      ),
    );
  }
}
