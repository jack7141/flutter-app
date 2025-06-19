import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/user_info/views/birthday_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 말투 선택 화면
class AttitudeScreen extends StatelessWidget {
  static const String routeName = "attitude";

  const AttitudeScreen({super.key});

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
                "질문이 많았네요,\n 어떤 사람인지 궁금했거든요 ㅎㅎ\n 마지막으로, 혹시 제가 어떻게 말하는게 편할까요?",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: Sizes.size16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.size64),
                      border: Border.all(
                        color: const Color(0xff211772), // 원하시는 테두리 색상
                        width: 2.0, // 테두리 두께 (원하는 값으로 조절)
                      ),
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: Sizes.size18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      child: Text(
                        '반말로 편하게 해주세요!',
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff211772),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Gaps.v20,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: Sizes.size16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.size64),
                      border: Border.all(
                        color: const Color(0xff211772), // 원하시는 테두리 색상
                        width: 2.0, // 테두리 두께 (원하는 값으로 조절)
                      ),
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: Sizes.size18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      child: Text(
                        '지금처럼 존댓말이 좋아요!',
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff211772),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Gaps.v20,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: Sizes.size16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.size64),
                      border: Border.all(
                        color: const Color(0xff211772), // 원하시는 테두리 색상
                        width: 2.0, // 테두리 두께 (원하는 값으로 조절)
                      ),
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: Sizes.size18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      child: Text(
                        '상관없어요, 편하신대로 해주세요',
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff211772),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
