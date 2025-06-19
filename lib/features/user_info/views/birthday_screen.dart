import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/user_info/views/mbti_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BirthdayScreen extends StatelessWidget {
  static const String routeName = "birthday";

  const BirthdayScreen({super.key});

  void _onNextTap(BuildContext context) {
    context.pushNamed(MbtiScreen.routeName);
  }

  void _onPressIconButton(BuildContext context) {
    context.pop();
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
                "생일은 언제에요?",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
