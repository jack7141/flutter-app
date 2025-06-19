import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String text;
  const FormButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: Sizes.size16),
        decoration: BoxDecoration(
          color: const Color(0xff9e9ef4),
          borderRadius: BorderRadius.circular(Sizes.size64),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: Sizes.size18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: Sizes.size18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
