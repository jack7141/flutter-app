import 'package:flutter/material.dart';

class CircularCheckbox extends StatelessWidget {
  const CircularCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final Function(bool p1) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: value ? const Color(0xff9e9ef4) : Colors.grey,
            width: 2,
          ),
          color: value ? const Color(0xff9e9ef4) : Colors.transparent,
        ),
        child: value
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }
}
