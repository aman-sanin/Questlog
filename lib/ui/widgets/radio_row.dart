import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class RadioRow<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String title;
  final String? subtitle;
  final ValueChanged<T> onChanged;
  final Widget? trailing;

  const RadioRow({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? tokens.tonal : Colors.transparent,
          border: Border.all(
            color: isSelected ? tokens.lineRest : tokens.lineRule,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Sharp custom indicator
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected ? tokens.textPrimary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? tokens.lineFull : tokens.lineRest,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 13,
                      color: tokens.onSolid,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tokens.body(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: tokens.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: tokens.body(
                        fontSize: 12,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
