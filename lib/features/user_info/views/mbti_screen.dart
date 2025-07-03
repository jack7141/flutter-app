import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/views/birthday_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:celeb_voice/features/user_info/widgets/interest_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// MBTI 선택 화면
const mbti = [
  "ISTJ",
  "ISFJ",
  "INFJ",
  "INTJ",
  "ISTP",
  "ISFP",
  "INFP",
  "INTP",
  "ESTP",
  "ESFP",
  "ENFP",
  "ESTJ",
  "ESFJ",
  "ENTP",
  "ENTJ",
  "ENFJ",
];

class MbtiScreen extends StatelessWidget {
  static const String routeName = "mbti";
  final CelebModel? celeb; // 셀럽 정보 추가

  const MbtiScreen({super.key, this.celeb});

  void _onNextTap(BuildContext context) {
    if (celeb != null) {
      context.push('/birthday', extra: celeb);
    } else {
      context.pushNamed(BirthdayScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CelebAvatar(currentCeleb: celeb), // 셀럽 정보 전달
              Gaps.v20,
              Text(
                "MBTI가 뭐예요?",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              Wrap(
                runSpacing: Sizes.size8,
                spacing: Sizes.size8,
                children: [
                  for (var mbtiType in mbti)
                    InterestButton(interest: mbtiType, id: 0),
                ],
              ),
              Gaps.v24,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FormButton(text: '이런 성격이에요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
