import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/user_info/views/birthday_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:celeb_voice/features/user_info/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/features/user_info/widgets/form_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GernerateMessageScreen extends StatefulWidget {
  static const String routeName = "gernerateMessage";
  static const String routePath = "/gernerateMessage";

  const GernerateMessageScreen({super.key});

  @override
  State<GernerateMessageScreen> createState() => _GernerateMessageScreenState();
}

class _GernerateMessageScreenState extends State<GernerateMessageScreen> {
  void _onNextTap(BuildContext context) {
    context.pushNamed(BirthdayScreen.routeName);
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
              Text(
                "듣고 싶은 메세지를\n적어보세요.",
                style: TextStyle(
                  fontSize: Sizes.size28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              CelebAvatar(),
              Gaps.v20,
              Text(
                "MBTI가 어떻게 돼요?\n 혹시 잘 모른다면 마음에 드는거로 선택해주세요",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FormButton(text: '들어보기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
