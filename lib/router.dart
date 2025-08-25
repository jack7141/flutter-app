import 'package:celeb_voice/common/main_navigation_screen.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/features/authentication/views/login_screen.dart';
import 'package:celeb_voice/features/authentication/views/nickname_screen.dart';
import 'package:celeb_voice/features/authentication/views/terms_screens.dart';
import 'package:celeb_voice/features/generation/views/generate_my_message_screen.dart';
import 'package:celeb_voice/features/generation/views/my_message_tts_screen.dart';
import 'package:celeb_voice/features/generation/views/preview_tts_screen.dart';
import 'package:celeb_voice/features/info/generate_message_info.dart';
import 'package:celeb_voice/features/main/home_screen.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/storage/views/send_message_choice_celeb.dart';
import 'package:celeb_voice/features/user_profile/views/update_profile_screen.dart';
import 'package:celeb_voice/features/user_profile/views/user_profile_screen.dart';
import 'package:celeb_voice/features/user_profile/views/user_settings_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 토큰 체크용
import 'package:go_router/go_router.dart';

// 자동 로그인 체크 함수 수정
Future<String> _checkAutoLogin() async {
  const storage = FlutterSecureStorage();

  // Dio 설정을 다른 곳과 동일하게 수정
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30), // 연결 타임아웃 30초
      receiveTimeout: const Duration(seconds: 30), // 응답 타임아웃 30초
      headers: AppConfig.defaultHeaders,
    ),
  );

  try {
    final accessToken = await storage.read(key: 'access_token');
    final userId = await storage.read(key: 'user_id');

    print('🔐 자동 로그인 체크 - Access Token: ${accessToken != null ? '존재' : '없음'}');
    print('🔐 자동 로그인 체크 - User ID: ${userId != null ? '존재' : '없음'}');

    // 토큰이 없으면 로그인 화면으로
    if (accessToken == null ||
        accessToken.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      print('❌ 토큰 없음 - 로그인 화면으로 이동');
      return "/login";
    }

    // 사용자 정보 조회로 상태 확인
    try {
      final tokenType = await storage.read(key: 'token_type');
      final response = await dio.get(
        AppConfig.usersMeEndpoint, // baseUrl이 이미 설정되어 있으므로 경로만
        options: Options(
          headers: {'Authorization': '${tokenType ?? 'Bearer'} $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        print('👤 사용자 정보 조회 성공: $userData');

        // is_confirm 상태 확인
        final isConfirm = userData['is_confirm'] ?? false;
        final nickname = userData['nickname'];

        print('🔍 사용자 상태 확인:');
        print('   - is_confirm: $isConfirm');
        print('   - nickname: $nickname');

        if (!isConfirm) {
          print('📋 약관 동의 미완료 - 약관 화면으로 이동');
          return "/terms";
        }

        if (nickname == null || nickname.toString().isEmpty) {
          print('📝 닉네임 미설정 - 닉네임 화면으로 이동');
          return "/nickname";
        }

        print('✅ 모든 조건 충족 - 홈 화면으로 이동');
        return "/home";
      } else {
        print('❌ 사용자 정보 조회 실패 - 로그인 화면으로 이동');
        return "/login";
      }
    } catch (apiError) {
      print('💥 사용자 정보 조회 에러: $apiError');
      // API 에러 시 토큰이 유효하지 않을 수 있으므로 로그인 화면으로
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
          path: "/profile",
          name: UserProfileScreen.routeName,
          builder: (context, state) => const UserProfileScreen(),
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
            // Map 형태의 데이터를 받아서 처리
            final extraData = state.extra;
            if (extraData is Map<String, dynamic>) {
              final celeb = extraData['celeb'] as CelebModel?;
              final messageData = extraData['messageData'];
              final requestText = extraData['requestText'] as String?;
              return MyMessageTtsScreen(
                celeb: celeb,
                messageData: messageData,
                requestText: requestText,
              );
            } else if (extraData is CelebModel) {
              // 이전 방식 호환성을 위해
              return MyMessageTtsScreen(celeb: extraData);
            } else {
              return MyMessageTtsScreen(celeb: null);
            }
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
        GoRoute(
          path: "/generateMessageInfo",
          name: GenerateMessageInfo.routeName,
          builder: (context, state) => const GenerateMessageInfo(),
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
