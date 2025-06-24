import 'package:flutter/material.dart';

import '../../../constants/sizes.dart';

class InterestButton extends StatefulWidget {
  const InterestButton({super.key, required this.interest});

  final String interest;

  @override
  State<InterestButton> createState() => _InterestButtonState();
}

class _InterestButtonState extends State<InterestButton> {
  bool _isSelected = false;

  void _onTap() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.size12,
          horizontal: Sizes.size20,
        ),
        decoration: BoxDecoration(
          color: _isSelected
              ? Color.fromARGB(255, 218, 218, 248)
              : Colors.white,
          borderRadius: BorderRadius.circular(Sizes.size32),
          border: Border.all(
            color: _isSelected
                ? const Color(0xff4d458e)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Text(
          widget.interest,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isSelected ? Color(0xff4d458e) : Colors.black87,
          ),
        ),
      ),
    );
  }
}
