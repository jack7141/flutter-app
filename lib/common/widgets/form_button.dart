import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  const FormButton({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: Sizes.size16),
        decoration: BoxDecoration(
          color: color ?? const Color(0xff9e9ef4),
          borderRadius: BorderRadius.circular(borderRadius ?? Sizes.size64),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: Sizes.size18,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.white,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: Sizes.size16,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
