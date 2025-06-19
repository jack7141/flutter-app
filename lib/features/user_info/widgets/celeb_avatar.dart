import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';

class CelebAvatar extends StatelessWidget {
  const CelebAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: NetworkImage(
            "https://avatars.githubusercontent.com/u/3612017",
          ),
        ),
        Gaps.h12,
        Text(
          '성시경',
          style: TextStyle(fontSize: Sizes.size16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
