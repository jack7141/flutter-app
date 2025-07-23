import 'package:flutter/material.dart';

class MyPageFormButton extends StatelessWidget {
  const MyPageFormButton({
    super.key,
    required this.title,
    required this.icon,
    this.color,
  });
  final String title;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
        Spacer(),
        Icon(icon, size: 20, color: color ?? Colors.grey.shade500),
      ],
    );
  }
}
