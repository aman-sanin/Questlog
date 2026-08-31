import 'package:flutter/material.dart';
import '../../domain/model/models.dart';
import '../theme/sigils.dart';
import '../theme/tokens.dart';

enum SigilMode {
  outline,
  drawOn,
  watermark,
}

class SigilWidget extends StatelessWidget {
  final CallingDomain domain;
  final double size;
  final SigilMode mode;
  final Color? color;

  const SigilWidget({
    super.key,
    required this.domain,
    this.size = 24.0,
    this.mode = SigilMode.outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Color strokeColor;

    if (color != null) {
      strokeColor = color!;
    } else if (mode == SigilMode.watermark) {
      strokeColor = tokens.textPrimary.withOpacity(0.04);
    } else {
      strokeColor = tokens.accent;
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: SigilPainter(
          domain: domain.name,
          color: strokeColor,
          strokeWidth: size > 48 ? 2.5 : 1.5,
        ),
      ),
    );
  }
}
