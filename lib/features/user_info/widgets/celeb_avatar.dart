import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';

class CelebAvatar extends StatelessWidget {
  final CelebModel? currentCeleb;

  const CelebAvatar({super.key, this.currentCeleb});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage:
              currentCeleb != null && currentCeleb!.imagePath.isNotEmpty
              ? NetworkImage(AppConfig.getImageUrl(currentCeleb!.imagePath))
              : NetworkImage("https://avatars.githubusercontent.com/u/3612017"),
          onBackgroundImageError: currentCeleb != null
              ? (exception, stackTrace) {
                  print("🖼️ 셀럽 이미지 로딩 에러: $exception");
                }
              : null,
          child: currentCeleb != null && currentCeleb!.imagePath.isEmpty
              ? Icon(Icons.person, size: 32, color: Colors.grey)
              : null,
        ),
        Gaps.h12,
        Text(
          currentCeleb?.name ?? '셀럽',
          style: TextStyle(fontSize: Sizes.size16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
