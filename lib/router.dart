import 'package:celeb_voice/features/authentication/views/login_screen.dart';
import 'package:celeb_voice/features/authentication/views/terms_screens.dart';
import 'package:celeb_voice/features/user_info/views/interest_screen.dart';
import 'package:celeb_voice/features/user_info/views/mbti_screen.dart';
import 'package:celeb_voice/features/user_info/views/welcome_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/", // 앱의 시작 경로
  routes: [
    GoRoute(
      path: "/", // 기본 경로
      builder: (context, state) => const LoginScreen(), // LoginScreen을 보여줌
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/interest',
      name: 'interest',
      builder: (context, state) => const InterestScreen(),
    ),
    GoRoute(
      path: '/mbti',
      name: 'mbti',
      builder: (context, state) => const MbtiScreen(),
    ),
  ],
);
