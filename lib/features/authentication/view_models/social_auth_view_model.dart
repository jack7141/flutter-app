import 'dart:async';

import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class SocialAuthViewModel extends AsyncNotifier<void> {
  late final AuthenticationRepo _authRepo;

  @override
  FutureOr<void> build() {
    _authRepo = ref.read(authRepoProvider);
  }

  Future<void> googleSignIn() async {
    print("✅ [1/5] Google Sign-In process started.");
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            "978445308352-i3il5vk7n161tsm0556lgfc4ksak2ld8.apps.googleusercontent.com",
      );

      await googleSignIn.signOut(); // 로그아웃

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("🚨 Google login cancelled by user.");
        throw Exception("Google login cancelled.");
      }

      print(
        "✅ [2/5] Google user info received: ${googleUser.displayName} (${googleUser.email})",
      );

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken; // ✅ 수정: idToken 사용
      print("idToken: $idToken");
      print("accessToken: ${googleAuth.accessToken}");

      if (idToken == null) {
        print("🚨 Failed to get Google ID token.");
        throw Exception("Failed to get Google ID token.");
      }

      print(
        "✅ [3/5] Google ID token received successfully. Length: ${idToken.length}",
      );

      print("✅ [4/5] Sending ID token to our backend...");
      await _authRepo.googleSocialLogin(idToken);

      print("✅ [5/5] Backend communication successful.");
    });

    if (state.hasError) {
      print("❌ An error occurred during the process: ${state.error}");
    }
  }

  Future<void> kakaoSignIn() async {
    print("✅ [1/5] Kakao Sign-In process started.");
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      OAuthToken token;

      // 카카오톡 설치 여부 확인
      bool kakaoTalkInstalled = await isKakaoTalkInstalled();
      print("📱 KakaoTalk installed: $kakaoTalkInstalled");

      try {
        if (kakaoTalkInstalled) {
          // 카카오톡으로 로그인 시도
          print("✅ [2/5] Attempting KakaoTalk app login.");
          print("⏱️ Waiting for KakaoTalk app response...");

          // 타임아웃 설정 (10초)
          token = await UserApi.instance.loginWithKakaoTalk().timeout(
            Duration(seconds: 10),
            onTimeout: () {
              print(
                "⏰ KakaoTalk login timed out after 10 seconds, switching to web login",
              );
              throw TimeoutException(
                "KakaoTalk login timed out",
                Duration(seconds: 10),
              );
            },
          );
          print("✅ [3/5] KakaoTalk login successful.");
        } else {
          throw Exception("KakaoTalk not installed, will use web login");
        }
      } catch (error) {
        // 카카오톡 로그인 실패 시 웹 로그인으로 fallback
        print("⚠️ KakaoTalk login failed: $error");
        print("✅ [2/5] Trying Kakao Account web login instead...");
        try {
          // 웹 로그인 시도 전 잠시 대기
          await Future.delayed(Duration(milliseconds: 500));
          token = await UserApi.instance.loginWithKakaoAccount().timeout(
            Duration(seconds: 60),
            onTimeout: () {
              print("⏰ Kakao web login timed out");
              throw TimeoutException(
                "Kakao web login timed out",
                Duration(seconds: 60),
              );
            },
          );
          print("✅ [3/5] Kakao Account login successful.");
        } catch (webError) {
          print("🚨 Both KakaoTalk and Account login failed.");
          print("🚨 Web login error: $webError");

          // 사용자가 취소한 경우와 다른 에러 구분
          if (webError.toString().contains("CANCELED")) {
            throw Exception("카카오 로그인이 취소되었습니다. 로그인을 완료해주세요.");
          } else {
            throw Exception("카카오 로그인 오류: 앱 설정을 확인하고 다시 시도해주세요.");
          }
        }
      }

      // 사용자 정보 요청
      User user = await UserApi.instance.me();

      print(
        "✅ [4/5] Kakao user info received: ${user.kakaoAccount?.profile?.nickname} (${user.kakaoAccount?.email})",
      );

      // 카카오 사용자 정보를 Map으로 변환 (구글과 동일한 방식)
      final kakaoUserInfo = {
        'id': user.id,
        'kakaoAccount': {
          'profile': {
            'nickname': user.kakaoAccount?.profile?.nickname,
            'profileImageUrl': user.kakaoAccount?.profile?.profileImageUrl,
            'thumbnailImageUrl': user.kakaoAccount?.profile?.thumbnailImageUrl,
          },
          'email': user.kakaoAccount?.email,
        },
      };

      // 백엔드에 카카오 토큰과 사용자 정보 함께 전송
      print("✅ [4/5] Sending Kakao token to our backend...");
      await _authRepo.kakaoSocialLogin(token.accessToken, kakaoUserInfo);

      print("✅ [5/5] Backend communication successful.");
    });

    if (state.hasError) {
      print("❌ Kakao login error occurred: ${state.error}");
    }
  }

  Future<void> naverSignIn() async {
    print("✅ [1/5] Naver Sign-In process started.");
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // 네이버 로그아웃 (기존 세션 정리)
      try {
        await FlutterNaverLogin.logOut();
        print("🚪 Naver logout completed for fresh login.");
      } catch (e) {
        print("⚠️ Naver logout failed (might be already logged out): $e");
      }

      // 네이버 로그인 시도 (1.8.0 버전)
      print("🚀 Starting Naver login...");
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status != NaverLoginStatus.loggedIn) {
        print("🚨 Naver login failed or cancelled: ${result.status}");
        throw Exception("Naver login cancelled or failed.");
      }

      print("✅ [2/5] Naver login successful.");

      // 네이버 사용자 정보 가져오기
      final NaverAccessToken accessToken =
          await FlutterNaverLogin.currentAccessToken;
      final NaverAccountResult accountResult =
          await FlutterNaverLogin.currentAccount();

      print("🔍 Account ID: ${accountResult.id}");
      print("🔍 Account Email: ${accountResult.email}");
      print("🔍 Account Name: ${accountResult.name}");

      final naverUserInfo = {
        'id': accountResult.id,
        'email': accountResult.email,
        'name': accountResult.name,
        'nickname': accountResult.nickname,
        'profileImage': accountResult.profileImage,
        'age': accountResult.age,
        'gender': accountResult.gender,
        'birthday': accountResult.birthday,
        'birthyear': accountResult.birthyear,
        'mobile': accountResult.mobile,
      };

      print(
        "✅ [3/5] Naver user info received: ${accountResult.nickname} (${accountResult.email})",
      );

      print("✅ [4/5] Sending Naver token to our backend...");
      await _authRepo.naverSocialLogin(accessToken.accessToken, naverUserInfo);

      print("✅ [5/5] Backend communication successful.");
    });

    if (state.hasError) {
      print("❌ Naver login error occurred: ${state.error}");
    }
  }
}

final socialAuthProvider = AsyncNotifierProvider<SocialAuthViewModel, void>(
  () => SocialAuthViewModel(),
);
