import 'package:celeb_voice/common/main_navigation_screen.dart';
import 'package:celeb_voice/features/authentication/views/login_screen.dart';
import 'package:celeb_voice/features/authentication/views/nickname_screen.dart';
import 'package:celeb_voice/features/authentication/views/terms_screens.dart';
import 'package:celeb_voice/features/generation/views/generate_my_message_screen.dart';
import 'package:celeb_voice/features/generation/views/my_message_tts_screen.dart';
import 'package:celeb_voice/features/generation/views/preview_tts_screen.dart';
import 'package:celeb_voice/features/main/home_screen.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/storage/views/voice_storage_screen.dart';
import 'package:celeb_voice/features/user_info/views/attitude_screen.dart';
import 'package:celeb_voice/features/user_info/views/birthday_screen.dart';
import 'package:celeb_voice/features/user_info/views/interest_screen.dart';
import 'package:celeb_voice/features/user_info/views/job_screen.dart';
import 'package:celeb_voice/features/user_info/views/mbti_screen.dart';
import 'package:celeb_voice/features/user_info/views/welcome_screen.dart';
import 'package:celeb_voice/features/user_profile/user_profile_screen.dart';
import 'package:go_router/go_router.dart';

// 공통 셀럽 데이터 파싱 함수
CelebModel? _parseCelebFromQuery(GoRouterState state) {
  print("🔍 Router - 전체 URI: ${state.uri}");
  print("🔍 Router - Query Parameters: ${state.uri.queryParameters}");

  final celebId = state.uri.queryParameters['celebId'];
  final celebName = state.uri.queryParameters['celebName'];
  final celebImage = state.uri.queryParameters['celebImage'];

  print("🔍 Router - celebId: $celebId");
  print("🔍 Router - celebName: $celebName");
  print("🔍 Router - celebImage: $celebImage");

  if (celebId != null && celebName != null && celebImage != null) {
    final celeb = CelebModel(
      id: celebId,
      name: celebName,
      imagePath: celebImage,
      detailImagePath: 'sample_detail_image_path', // 추가
      tags: [],
      description: '',
      status: '',
      index: 0,
    );
    print("🔍 Router - 생성된 셀럽: ${celeb.name}");
    return celeb;
  }

  print("🔍 Router - 셀럽 데이터 null 반환");
  return null;
}

final router = GoRouter(
  initialLocation: "/login",
  routes: [
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
          path: "/voiceStorage",
          name: VoiceStorageScreen.routeName,
          builder: (context, state) => const VoiceStorageScreen(),
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
