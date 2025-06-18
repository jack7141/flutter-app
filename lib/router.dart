import 'package:celeb_voice/features/authentication/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider((ref) {
  // AuthenticationRepository의 변경 사항을 listen하여 로그인 상태 변화를 감지
  // GoRouter의 redirect 기능을 사용하기 위함
  return GoRouter(
    initialLocation: "/login", // 앱 시작 시 기본 로그인 화면으로 설정
    routes: [
      // 앱의 메인 내비게이션 (로그인 후 진입)
      ShellRoute(routes: [
        ],
      ),
      // 인증 관련 라우트 (로그인 전 화면)
      GoRoute(
        path: LoginScreen.routeUrl,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});
