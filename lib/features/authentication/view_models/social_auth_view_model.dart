import 'dart:async';
import 'dart:convert'; // JSON 파싱을 위한 import 추가

import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:naver_login_sdk/naver_login_sdk.dart'; // 변경됨
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
          print("🌐 Starting Kakao web login...");

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
          print("🔑 Received token: ${token.accessToken.substring(0, 10)}...");
        } catch (webError) {
          print("🚨 Both KakaoTalk and Account login failed.");
          print("🚨 Web login error: $webError");
          print("🚨 Error type: ${webError.runtimeType}");
          print("🚨 Error details: ${webError.toString()}");

          // 사용자가 취소한 경우와 다른 에러 구분
          if (webError.toString().contains("CANCELED") ||
              webError.toString().contains("cancelled") ||
              webError.toString().contains("cancel")) {
            throw Exception("카카오 로그인이 취소되었습니다. 로그인을 완료해주세요.");
          } else {
            throw Exception("카카오 로그인 오류: 앱 설정을 확인하고 다시 시도해주세요. ($webError)");
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
      // 네이버 로그아웃 (기존 세션 정리) - 더 안전한 방식
      try {
        print("🚪 Attempting Naver logout for fresh login...");
        NaverLoginSDK.logout();
        // 로그아웃 완료를 위한 짧은 대기
        await Future.delayed(const Duration(milliseconds: 100));
        print("🚪 Naver logout completed for fresh login.");
      } catch (e) {
        print("⚠️ Naver logout failed (might be already logged out): $e");
      }

      // 네이버 로그인 시도 (Completer 사용)
      print("🚀 Starting Naver login...");

      final loginCompleter = Completer<void>();
      NaverLoginSDK.authenticate(
        callback: OAuthLoginCallback(
          onSuccess: () {
            print("✅ [2/5] Naver login successful.");
            if (!loginCompleter.isCompleted) {
              loginCompleter.complete();
            }
          },
          onFailure: (httpStatus, message) {
            print("🚨 Naver login failed: $httpStatus - $message");
            if (!loginCompleter.isCompleted) {
              loginCompleter.completeError(
                Exception("Naver login failed: $message"),
              );
            }
          },
          onError: (errorCode, message) {
            print("🚨 Naver login error: $errorCode - $message");

            // 더 자세한 에러 분석
            if (message == 'user_cancel') {
              print("⚠️ User cancelled Naver login");
              print("⚠️ This might be due to:");
              print("   1. User manually cancelled login");
              print("   2. Network issue during login");
              print("   3. Android configuration issue");
              print("   4. Naver app authentication issue");
            }

            // 네이버 앱이 설치되지 않은 경우 특별 처리
            if (message == 'naverapp_not_installed') {
              print("⚠️ Naver app not installed, will try web login");
              // 웹 로그인은 자동으로 시도됨
            }

            if (!loginCompleter.isCompleted) {
              loginCompleter.completeError(
                Exception("Naver login error: $message"),
              );
            }
          },
        ),
      );

      // 로그인 완료 대기
      await loginCompleter.future;

      // 액세스 토큰 가져오기
      final accessToken = await NaverLoginSDK.getAccessToken();
      if (accessToken.isEmpty) {
        throw Exception("Failed to get Naver access token");
      }

      print(
        "🔑 Naver access token received: ${accessToken.substring(0, 10)}...",
      );

      // 프로필 정보 가져오기 (JSON 파싱 추가)
      print("✅ [3/5] Getting Naver profile...");

      Map<String, dynamic>? profileData;
      bool profileReceived = false;
      String? profileError;

      NaverLoginSDK.profile(
        callback: ProfileCallback(
          onSuccess: (resultCode, message, response) {
            try {
              print("✅ Profile received: $response");
              print("Response type: ${response.runtimeType}");

              Map<String, dynamic> parsedData;

              if (response is Map<String, dynamic>) {
                // 이미 Map 타입인 경우
                parsedData = response;
              } else if (response is String) {
                // String(JSON) 타입인 경우 파싱
                print("🔧 Parsing JSON string...");
                parsedData = jsonDecode(response);
              } else {
                // 기타 타입인 경우 toString 후 파싱 시도
                print("🔧 Converting to string and parsing...");
                parsedData = jsonDecode(response.toString());
              }

              profileData = Map<String, dynamic>.from(parsedData);
              print("✅ Profile data parsed successfully: $profileData");
              profileReceived = true;
            } catch (e) {
              print("⚠️ Error processing profile response: $e");
              print("⚠️ Raw response: $response");
              profileError = e.toString();
              profileReceived = true;
            }
          },
          onFailure: (httpStatus, message) {
            print("🚨 Profile fetch failed: $httpStatus - $message");
            profileError = "Profile fetch failed: $message";
            profileReceived = true;
          },
          onError: (errorCode, message) {
            print("🚨 Profile error: $errorCode - $message");
            profileError = "Profile error: $message";
            profileReceived = true;
          },
        ),
      );

      // 프로필 수신 대기 (polling 방식)
      int waitCount = 0;
      while (!profileReceived && waitCount < 50) {
        // 5초 대기
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }

      if (profileError != null) {
        throw Exception("Failed to get Naver profile: $profileError");
      }

      if (profileData == null || profileData!.isEmpty) {
        throw Exception("Failed to get Naver profile data");
      }

      print("🔍 Profile data validation passed");

      // 안전한 값 추출 함수
      String? safeString(dynamic value) {
        try {
          return value?.toString();
        } catch (e) {
          print("⚠️ Error converting value to string: $e");
          return null;
        }
      }

      // 네이버 사용자 정보 구성
      final naverUserInfo = <String, dynamic>{};

      try {
        naverUserInfo['id'] = safeString(profileData!['id']);
        naverUserInfo['email'] = safeString(profileData!['email']);
        naverUserInfo['name'] = safeString(profileData!['name']);
        naverUserInfo['nickname'] = safeString(profileData!['nickname']);
        naverUserInfo['profileImage'] = safeString(
          profileData!['profile_image'] ?? profileData!['profileImage'],
        );
        naverUserInfo['age'] = safeString(profileData!['age']);
        naverUserInfo['gender'] = safeString(profileData!['gender']);
        naverUserInfo['birthday'] = safeString(profileData!['birthday']);
        naverUserInfo['birthyear'] = safeString(profileData!['birthyear']);
        naverUserInfo['mobile'] = safeString(profileData!['mobile']);

        print("🔍 Processed Naver user info:");
        naverUserInfo.forEach((key, value) {
          print("  - $key: $value");
        });
      } catch (e) {
        print("⚠️ Error processing user info: $e");
        throw Exception("Error processing Naver user info: $e");
      }

      print(
        "✅ [4/5] Naver user info processed: ${naverUserInfo['nickname']} (${naverUserInfo['email']})",
      );

      print("✅ [5/5] Sending Naver token to our backend...");
      await _authRepo.naverSocialLogin(accessToken, naverUserInfo);

      print("✅ Backend communication successful.");
    });

    if (state.hasError) {
      print("❌ Naver login error occurred: ${state.error}");
    }
  }
}

final socialAuthProvider = AsyncNotifierProvider<SocialAuthViewModel, void>(
  () => SocialAuthViewModel(),
);
