import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/views/interest_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 환영 화면
class WelcomeScreen extends StatelessWidget {
  static const String routeName = "welcome";
  static const String routePath = "/welcome";

  final CelebModel? celeb; // 셀럽 정보 추가

  const WelcomeScreen({super.key, this.celeb});

  void _onNextTap(BuildContext context) {
    if (celeb != null) {
      context.push('/interest', extra: celeb);
    } else {
      context.pushNamed(InterestScreen.routeName);
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
