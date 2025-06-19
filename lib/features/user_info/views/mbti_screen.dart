import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/user_info/views/birthday_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/form_button.dart';
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

  const MbtiScreen({super.key});

  void _onPressIconButton(BuildContext context) {
    context.pop();
  }

  void _onNextTap(BuildContext context) {
    context.pushNamed(BirthdayScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => _onPressIconButton(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    style: TextStyle(
                      fontSize: Sizes.size16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Gaps.v20,
              Text(
                "MBTI가 어떻게 돼요?\n 혹시 잘 모른다면 마음에 드는거로 선택해주세요",
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
                  for (var mbti in mbti) InterestButton(interest: mbti),
                ],
              ),
              Gaps.v24,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FormButton(text: '제 MBTI는 이거에요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
