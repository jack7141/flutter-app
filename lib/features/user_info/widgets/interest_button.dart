import 'package:flutter/material.dart';

import '../../../constants/sizes.dart';

class InterestButton extends StatelessWidget {
  final String interest;
  final int? id;
  final bool isSelected;
  final VoidCallback? onTap;

  const InterestButton({
    super.key,
    required this.interest,
    this.id,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.size12,
          horizontal: Sizes.size20,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(255, 218, 218, 248) : Colors.white,
          borderRadius: BorderRadius.circular(Sizes.size32),
          border: Border.all(
            color: isSelected
                ? const Color(0xff4d458e)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Text(
          interest,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Color(0xff4d458e) : Colors.black87,
          ),
        ),
      ),
    );
  }
}
