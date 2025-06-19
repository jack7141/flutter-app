import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/view_models/social_auth_view_model.dart';
import 'package:celeb_voice/features/authentication/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        // 상단 노치, 하단 인디케이터 등 시스템 UI를 피해서 UI를 그려줍니다.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.size40),
          child: Column(
            children: [
              Gaps.v80,
              Text(
                'Log in',
                style: GoogleFonts.abrilFatface(fontSize: Sizes.size40),
                textAlign: TextAlign.center,
              ),
              Gaps.v40,
              GestureDetector(
                onTap: () {
                  ref.read(socialAuthProvider.notifier).googleSignIn();
                },
                child: const AuthButton(
                  icon: FontAwesomeIcons.google,
                  text: "Continue with Google",
                ),
              ),
              // 다른 SNS 버튼들도 이런 식으로 추가할 수 있습니다.
              // Gaps.v16,
              // const AuthButton(
              //   icon: FontAwesomeIcons.apple,
              //   text: "Continue with Apple",
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// 재사용 가능한 공용 인증 버튼 위젯
