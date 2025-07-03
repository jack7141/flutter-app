import 'package:celeb_voice/common/main_navigation_screen.dart';
import 'package:celeb_voice/features/authentication/views/login_screen.dart';
import 'package:celeb_voice/features/authentication/views/terms_screens.dart';
import 'package:celeb_voice/features/generation/views/gernerate_message_screen.dart';
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
            final celebId = state.uri.queryParameters['celebId'];
            final celebName = state.uri.queryParameters['celebName'];
            final celebImage = state.uri.queryParameters['celebImage'];

            CelebModel? celeb;
            if (celebId != null && celebName != null && celebImage != null) {
              celeb = CelebModel(
                id: celebId,
                name: celebName,
                imagePath: celebImage,
                tags: [],
                description: '',
                status: '',
                index: 0,
              );
            }

            print("🔍 Query로 받은 셀럽: ${celeb?.name}");
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
            final celebId = state.uri.queryParameters['celebId'];
            final celebName = state.uri.queryParameters['celebName'];
            final celebImage = state.uri.queryParameters['celebImage'];

            CelebModel? celeb;
            if (celebId != null && celebName != null && celebImage != null) {
              celeb = CelebModel(
                id: celebId,
                name: celebName,
                imagePath: celebImage,
                tags: [],
                description: '',
                status: '',
                index: 0,
              );
            }

            print("🔍 Query로 받은 셀럽: ${celeb?.name}");
            return InterestScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/mbti",
          name: MbtiScreen.routeName,
          builder: (context, state) {
            final celebId = state.uri.queryParameters['celebId'];
            final celebName = state.uri.queryParameters['celebName'];
            final celebImage = state.uri.queryParameters['celebImage'];

            CelebModel? celeb;
            if (celebId != null && celebName != null && celebImage != null) {
              celeb = CelebModel(
                id: celebId,
                name: celebName,
                imagePath: celebImage,
                tags: [],
                description: '',
                status: '',
                index: 0,
              );
            }

            print("🔍 Query로 받은 셀럽: ${celeb?.name}");
            return MbtiScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/birthday",
          name: BirthdayScreen.routeName,
          builder: (context, state) {
            final celebId = state.uri.queryParameters['celebId'];
            final celebName = state.uri.queryParameters['celebName'];
            final celebImage = state.uri.queryParameters['celebImage'];

            CelebModel? celeb;
            if (celebId != null && celebName != null && celebImage != null) {
              celeb = CelebModel(
                id: celebId,
                name: celebName,
                imagePath: celebImage,
                tags: [],
                description: '',
                status: '',
                index: 0,
              );
            }

            print("🔍 Query로 받은 셀럽: ${celeb?.name}");
            return BirthdayScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/job",
          name: JobScreen.routeName,
          builder: (context, state) {
            final celebId = state.uri.queryParameters['celebId'];
            final celebName = state.uri.queryParameters['celebName'];
            final celebImage = state.uri.queryParameters['celebImage'];

            CelebModel? celeb;
            if (celebId != null && celebName != null && celebImage != null) {
              celeb = CelebModel(
                id: celebId,
                name: celebName,
                imagePath: celebImage,
                tags: [],
                description: '',
                status: '',
                index: 0,
              );
            }

            print("🔍 Query로 받은 셀럽: ${celeb?.name}");
            return JobScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/attitude",
          name: AttitudeScreen.routeName,
          builder: (context, state) {
            final celebId = state.uri.queryParameters['celebId'];
            final celebName = state.uri.queryParameters['celebName'];
            final celebImage = state.uri.queryParameters['celebImage'];

            CelebModel? celeb;
            if (celebId != null && celebName != null && celebImage != null) {
              celeb = CelebModel(
                id: celebId,
                name: celebName,
                imagePath: celebImage,
                tags: [],
                description: '',
                status: '',
                index: 0,
              );
            }

            print("🔍 Query로 받은 셀럽: ${celeb?.name}");
            return AttitudeScreen(celeb: celeb);
          },
        ),
        GoRoute(
          path: "/voiceStorage",
          name: VoiceStorageScreen.routeName,
          builder: (context, state) => const VoiceStorageScreen(),
        ),
        GoRoute(
          path: "/gernerateMessage",
          name: GernerateMessageScreen.routeName,
          builder: (context, state) => const GernerateMessageScreen(),
        ),
        GoRoute(
          path: "/previewTts",
          name: PreviewTtsScreen.routeName,
          builder: (context, state) => const PreviewTtsScreen(),
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
  ],
);
