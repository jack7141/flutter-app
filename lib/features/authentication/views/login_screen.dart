import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/view_models/social_auth_view_model.dart';
import 'package:celeb_voice/features/authentication/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerWidget {
  static const String routeName = "login";
  static const String routePath = "/login";

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 로그인 상태 감시
    ref.listen(socialAuthProvider, (previous, next) {
      if (next.isLoading) return; // 로딩 중이면 무시

      next.when(
        data: (_) {
          // 로그인 성공 시 Terms 화면으로 이동
          context.push('/terms'); // 또는 context.pushNamed('terms')
        },
        error: (error, stackTrace) {
          // 에러 시 스낵바 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그인 실패: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        loading: () {}, // 로딩 상태는 버튼에서 처리
      );
    });

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
              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(socialAuthProvider);
                  return GestureDetector(
                    onTap: authState.isLoading
                        ? null
                        : () {
                            ref
                                .read(socialAuthProvider.notifier)
                                .googleSignIn();
                          },
                    child: AuthButton(
                      icon: FontAwesomeIcons.google,
                      text: "Google로 시작하기",
                      isLoading: authState.isLoading,
                      backgroundColor: Colors.white,
                    ),
                  );
                },
              ),
              // 다른 SNS 버튼들도 이런 식으로 추가할 수 있습니다.
              Gaps.v16,
              const AuthButton(
                icon: FontAwesomeIcons.apple,
                text: "Apple로 시작하기",
                backgroundColor: Colors.black,
                textColor: Colors.white,
              ),
              Gaps.v16,
              const AuthButton(
                icon: FontAwesomeIcons.solidComment,
                text: "카카오로 시작하기",
                backgroundColor: Colors.yellow,
                textColor: Colors.black,
              ),
              Gaps.v16,
              const AuthButton(
                icon: FontAwesomeIcons.solidCalendar,
                text: "네이버로 시작하기",
                backgroundColor: Color(0xFF03CF5D),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 재사용 가능한 공용 인증 버튼 위젯
