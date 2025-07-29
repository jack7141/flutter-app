import 'package:celeb_voice/common/main_navigation_screen.dart';
import 'package:celeb_voice/features/authentication/views/login_screen.dart';
import 'package:celeb_voice/features/authentication/views/nickname_screen.dart';
import 'package:celeb_voice/features/authentication/views/terms_screens.dart';
import 'package:celeb_voice/features/generation/views/generate_my_message_screen.dart';
import 'package:celeb_voice/features/generation/views/my_message_tts_screen.dart';
import 'package:celeb_voice/features/generation/views/preview_tts_screen.dart';
import 'package:celeb_voice/features/main/home_screen.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/storage/views/send_message_choice_celeb.dart';
import 'package:celeb_voice/features/storage/views/send_message_screen.dart';
import 'package:celeb_voice/features/user_info/views/attitude_screen.dart';
import 'package:celeb_voice/features/user_info/views/birthday_screen.dart';
import 'package:celeb_voice/features/user_info/views/interest_screen.dart';
import 'package:celeb_voice/features/user_info/views/job_screen.dart';
import 'package:celeb_voice/features/user_info/views/mbti_screen.dart';
import 'package:celeb_voice/features/user_info/views/welcome_screen.dart';
import 'package:celeb_voice/features/user_profile/views/update_profile_screen.dart';
import 'package:celeb_voice/features/user_profile/views/user_profile_screen.dart';
import 'package:celeb_voice/features/user_profile/views/user_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 토큰 체크용
import 'package:go_router/go_router.dart';

// 자동 로그인 체크 함수 (간단하게)
Future<String> _checkAutoLogin() async {
  const storage = FlutterSecureStorage();

  try {
    final accessToken = await storage.read(key: 'access_token');
    final userId = await storage.read(key: 'user_id');

    print('🔐 자동 로그인 체크 - Access Token: ${accessToken != null ? '존재' : '없음'}');
    print('🔐 자동 로그인 체크 - User ID: ${userId != null ? '존재' : '없음'}');

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty) {
      print('✅ 토큰 존재 - 홈 화면으로 이동');
      return "/home";
    } else {
      print('❌ 토큰 없음 - 로그인 화면으로 이동');
      return "/login";
    }
  } catch (e) {
    print('💥 자동 로그인 체크 에러: $e');
    return "/login";
  }
}

String? _handleException(
  BuildContext context,
  GoRouterState state,
  GoRouter router,
) {
  // 카카오 OAuth 관련 에러는 무시하고 로그인 화면으로 이동
  if (state.uri.toString().contains('oauth') ||
      state.uri.toString().contains('kakao')) {
    return null;
  }
  return null;
}

final router = GoRouter(
  initialLocation: "/splash", // 스플래시에서 시작
  onException: _handleException,
  routes: [
    // 스플래시 화면 (자동 로그인 체크)
    GoRoute(
      path: "/splash",
      builder: (context, state) => FutureBuilder<String>(
        future: _checkAutoLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 결정된 라우트로 리다이렉트
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(snapshot.data ?? "/login");
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    ),

    // 카카오 OAuth 콜백만 처리하고 아무것도 하지 않음
    GoRoute(path: "/oauth", builder: (context, state) => const SizedBox()),

    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationScreen(child: child);
      },
      routes: [
        GoRoute(
          path: "/home",
          name: HomeScreen.routeName,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: "/welcome",
          name: WelcomeScreen.routeName,
          builder: (context, state) {
            final celeb = state.extra as CelebModel?;
            return WelcomeScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/profile",
          name: UserProfileScreen.routeName,
          builder: (context, state) => const UserProfileScreen(),
        ),
        GoRoute(
          path: "/interest",
          name: InterestScreen.routeName,
          builder: (context, state) {
            final celeb = state.extra as CelebModel?;
            return InterestScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/mbti",
          name: MbtiScreen.routeName,
          builder: (context, state) {
            print("🔍 Router - /mbti 경로 진입");
            print("🔍 Router - state.extra: ${state.extra}");
            print("🔍 Router - state.extra type: ${state.extra.runtimeType}");

            final celeb = state.extra as CelebModel?;
            print("🔍 Router - 변환된 celeb: ${celeb?.name}");

            return MbtiScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/birthday",
          name: BirthdayScreen.routeName,
          builder: (context, state) {
            final celeb = state.extra as CelebModel?;
            return BirthdayScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/job",
          name: JobScreen.routeName,
          builder: (context, state) {
            final celeb = state.extra as CelebModel?;
            return JobScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/attitude",
          name: AttitudeScreen.routeName,
          builder: (context, state) {
            final celeb = state.extra as CelebModel?;
            return AttitudeScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/sendMessage",
          name: SendMessageScreen.routeName,
          builder: (context, state) {
            final celeb = state.extra as CelebModel?;
            return SendMessageScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/generateMessage",
          name: GernerateMessageScreen.routeName,
          builder: (context, state) {
            final celeb = state.extra as CelebModel?;
            return GernerateMessageScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/previewTts",
          name: PreviewTtsScreen.routeName,
          builder: (context, state) {
            final celeb = state.extra as CelebModel?;
            return PreviewTtsScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/myMessageTts",
          name: MyMessageTtsScreen.routeName,
          builder: (context, state) {
            final celeb = state.extra as CelebModel?;
            return MyMessageTtsScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/settings",
          name: UserSettingsScreen.routeName,
          builder: (context, state) => const UserSettingsScreen(),
        ),
        GoRoute(
          path: "/update_profile",
          name: UpdateProfileScreen.routeName,
          builder: (context, state) => const UpdateProfileScreen(),
        ),
        GoRoute(
          path: "/sendMessageChoiceCeleb",
          name: SendMessageChoiceCeleb.routeName,
          builder: (context, state) => const SendMessageChoiceCeleb(),
        ),
      ],
    ),
    GoRoute(
      path: "/login",
      name: LoginScreen.routeName,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: "/terms",
      name: TermsScreen.routeName,
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: "/nickname",
      name: NicknameScreen.routeName,
      builder: (context, state) => const NicknameScreen(),
    ),
  ],
);
