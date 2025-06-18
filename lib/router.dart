import 'package:celeb_voice/features/authentication/login_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/", // 앱의 시작 경로
  routes: [
    GoRoute(
      path: "/", // 기본 경로
      builder: (context, state) => const LoginScreen(), // LoginScreen을 보여줌
    ),
  ],
);
