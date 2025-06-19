import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/user_info/views/interest_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:celeb_voice/features/user_info/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/features/user_info/widgets/form_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 환영 화면
class WelcomeScreen extends StatelessWidget {
  static const String routeName = "welcome";
  static const String routePath = "/welcome";
  const WelcomeScreen({super.key});

  void _onNextTap(BuildContext context) {
    context.pushNamed(InterestScreen.routeName);
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
                '안녕하세요, 우리 오늘부터 자주 볼 사이니까 궁금한 거 몇 가지 물어봐도 될까요?',
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FormButton(text: '네, 그럼요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
