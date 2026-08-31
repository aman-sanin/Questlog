import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;
  final bool autofocus;
  final Widget? prefix;
  final Widget? suffix;

  const AppInput({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: tokens.body(
        fontSize: 18,
        color: tokens.textPrimary,
      ),
      cursorColor: tokens.accent,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: tokens.body(
          fontSize: 18,
          color: tokens.textSecondary.withOpacity(0.6),
        ),
        prefixIcon: prefix,
        suffixIcon: suffix,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: tokens.lineRest,
            width: 1.0,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: tokens.accent,
            width: 2.0,
          ),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: tokens.lineRest,
            width: 1.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
