import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/user_info/views/mbti_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:celeb_voice/features/user_info/widgets/interest_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 관심사 선택 화면
const interests = [
  "음악/공연",
  "운동/스포츠",
  "게임",
  "여행",
  "미술/공예",
  "수집",
  "요리/음식",
  "학습/자기계발",
  "문학/글쓰기",
  "반려/자연",
];

class InterestScreen extends StatelessWidget {
  static const String routeName = "interest";

  const InterestScreen({super.key});

  void _onNextTap(BuildContext context) {
    context.pushNamed(MbtiScreen.routeName);
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
              CelebAvatar(),
              Gaps.v20,
              Text(
                "요즘 관심사가 뭐예요?",
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
                  for (var interest in interests)
                    InterestButton(interest: interest),
                ],
              ),
              Gaps.v24,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FormButton(text: '저는 이런 취미가 있어요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
