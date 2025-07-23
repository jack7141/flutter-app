// 인증 관련 레포지토리
// 서버와 통신 담당

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/app_config.dart';

class AuthenticationRepo {
  final _dio = Dio();

  // Create storage
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>?> googleSocialLogin(String idToken) async {
    try {
      if (AppConfig.enableDebugLogs) {
        print("🚀 Google Social Login 시작");
        print("📤 전송할 idToken: $idToken");
      }

      // ID 토큰에서 사용자 정보 추출
      final googleUserInfo = _decodeIdToken(idToken);
      if (AppConfig.enableDebugLogs) {
        print("👤 구글 사용자 정보: $googleUserInfo");
      }

      final url = "${AppConfig.baseUrl}${AppConfig.socialGoogleEndpoint}";
      if (AppConfig.enableDebugLogs) {
        print("🌐 요청 URL: $url");
      }

      final response = await _dio.post(
        url,
        data: {"id_token": idToken},
        options: Options(headers: AppConfig.defaultHeaders),
      );

      if (AppConfig.enableDebugLogs) {
        print("📥 Django Response Status: ${response.statusCode}");
        print("📥 Django Response Data: ${response.data}");
      }

      // 성공적인 응답 (200 또는 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (AppConfig.enableDebugLogs) {
          print("✅ 로그인 성공!");
        }

        // 토큰 저장
        await _saveTokens(data);

        // 구글 사용자 정보를 서버에 전송
        await _sendUserProfileToServer(data['accessToken'], googleUserInfo);

        return data;
      } else {
        if (AppConfig.enableDebugLogs) {
          print("❌ 예상하지 못한 상태코드: ${response.statusCode}");
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 Login error 발생: $e");
      }
      if (e is DioException) {
        if (AppConfig.enableDebugLogs) {
          print("🔍 DioException 상세:");
          print("   - Status Code: ${e.response?.statusCode}");
          print("   - Response Data: ${e.response?.data}");
          print("   - Error Message: ${e.message}");
        }
      }
      return null;
    }
  }

  // ID 토큰 디코딩 (JWT 페이로드 부분만 추출)
  Map<String, dynamic> _decodeIdToken(String idToken) {
    try {
      // JWT는 헤더.페이로드.시그니처 형태
      final parts = idToken.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT format');
      }

      // 페이로드 부분 디코딩
      final payload = parts[1];

      // Base64 URL 디코딩을 위한 패딩 추가
      String normalizedPayload = payload
          .replaceAll('-', '+')
          .replaceAll('_', '/');
      while (normalizedPayload.length % 4 != 0) {
        normalizedPayload += '=';
      }

      final decodedBytes = base64Decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final userInfo = jsonDecode(decodedString);

      if (AppConfig.enableDebugLogs) {
        print("🔍 디코딩된 사용자 정보: $userInfo");
      }
      return userInfo;
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 ID 토큰 디코딩 에러: $e");
      }
      return {};
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    if (AppConfig.enableDebugLogs) {
      print("💾 토큰 저장 시작...");
      print("📥 백엔드에서 받은 전체 데이터: $data");

      // 각 필드별로 상세 출력
      print("🔍 데이터 상세 분석:");
      data.forEach((key, value) {
        print("  - $key: $value (타입: ${value.runtimeType})");
      });
    }

    await storage.write(
      key: AppConfig.accessTokenKey,
      value: data['accessToken'],
    );
    await storage.write(key: AppConfig.tokenTypeKey, value: data['tokenType']);
    await storage.write(
      key: AppConfig.expiresInKey,
      value: data['expiresIn'].toString(),
    );

    if (data['refreshToken'] != null) {
      await storage.write(
        key: AppConfig.refreshTokenKey,
        value: data['refreshToken'],
      );
    }

    // user_id도 함께 저장
    if (data['userId'] != null) {
      // user_id → userId 변경
      await storage.write(key: 'user_id', value: data['userId'].toString());
      if (AppConfig.enableDebugLogs) {
        print("💾 User ID 저장 완료: ${data['userId']}");
      }
    } else {
      if (AppConfig.enableDebugLogs) {
        print("⚠️ userId가 응답에 없습니다!");
      }
    }

    if (AppConfig.enableDebugLogs) {
      print("🎉 모든 토큰 정보 저장 완료!");
    }
  }

  // 카카오 사용자 정보를 서버에 전송
  Future<void> _sendKakaoUserProfileToServer(
    String accessToken,
    Map<String, dynamic> kakaoUserInfo,
  ) async {
    try {
      if (AppConfig.enableDebugLogs) {
        print("👤 카카오 사용자 프로필 서버 전송 시작");
        print("📤 전송할 카카오 사용자 정보: $kakaoUserInfo");
      }

      final profileData = <String, dynamic>{
        "profile": <String, dynamic>{},
        "user_id": kakaoUserInfo['id']?.toString() ?? "unknown_user_id",
      };

      // 카카오에서 받은 정보가 있는 경우에만 추가
      if (kakaoUserInfo['kakaoAccount']?['profile']?['nickname'] != null) {
        profileData["profile"]["nickname"] =
            kakaoUserInfo['kakaoAccount']['profile']['nickname'];
      }

      // 카카오 프로필 이미지가 있는 경우 추가
      if (kakaoUserInfo['kakaoAccount']?['profile']?['profileImageUrl'] !=
          null) {
        profileData["profile"]["images"] = [
          {
            "image_url":
                kakaoUserInfo['kakaoAccount']['profile']['profileImageUrl'],
            "scale": "AVATAR",
          },
        ];
      }

      // 이메일 정보가 있는 경우 추가
      if (kakaoUserInfo['kakaoAccount']?['email'] != null) {
        profileData["profile"]["email"] =
            kakaoUserInfo['kakaoAccount']['email'];
      }

      final profileUrl = "${AppConfig.baseUrl}${AppConfig.usersEndpoint}";
      if (AppConfig.enableDebugLogs) {
        print("🌐 카카오 프로필 전송 URL: $profileUrl");
        print("📤 전송할 카카오 프로필 데이터: $profileData");
      }

      final profileResponse = await _dio.post(
        profileUrl,
        data: profileData,
        options: Options(
          headers: {
            ...AppConfig.defaultHeaders,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (AppConfig.enableDebugLogs) {
        print("📥 카카오 프로필 전송 응답 상태: ${profileResponse.statusCode}");
        print("✅ 카카오 사용자 프로필 서버 전송 성공!");
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 카카오 사용자 프로필 서버 전송 에러: $e");
      }
      if (e is DioException) {
        if (AppConfig.enableDebugLogs) {
          print("🔍 카카오 프로필 전송 DioException 상세:");
          print("   - Status Code: ${e.response?.statusCode}");
          print("   - Response Data: ${e.response?.data}");
        }
      }
    }
  }

  // 구글 사용자 정보를 서버에 전송
  Future<void> _sendUserProfileToServer(
    String accessToken,
    Map<String, dynamic> googleUserInfo,
  ) async {
    try {
      if (AppConfig.enableDebugLogs) {
        print("👤 사용자 프로필 서버 전송 시작");
      }

      final profileData = <String, dynamic>{
        "profile": <String, dynamic>{},
        "user_id": googleUserInfo['sub'] ?? "unknown_user_id",
      };

      // 구글에서 받은 정보가 있는 경우에만 추가
      if (googleUserInfo['name'] != null) {
        profileData["profile"]["nickname"] = googleUserInfo['name'];
      }

      // 이미지 정보를 profile 안에 배열로 추가 (필드명: images)
      if (googleUserInfo['picture'] != null) {
        profileData["profile"]["images"] = [
          {"image_url": googleUserInfo['picture'], "scale": "AVATAR"},
        ];
      }

      final profileUrl = "${AppConfig.baseUrl}${AppConfig.usersEndpoint}";
      if (AppConfig.enableDebugLogs) {
        print("🌐 프로필 전송 URL: $profileUrl");
        print("📤 전송할 프로필 데이터: $profileData");
      }

      final profileResponse = await _dio.post(
        profileUrl,
        data: profileData,
        options: Options(
          headers: {
            ...AppConfig.defaultHeaders,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (AppConfig.enableDebugLogs) {
        print("📥 프로필 전송 응답 상태: ${profileResponse.statusCode}");
        print("✅ 사용자 프로필 서버 전송 성공!");
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 사용자 프로필 서버 전송 에러: $e");
      }
      if (e is DioException) {
        if (AppConfig.enableDebugLogs) {
          print("🔍 프로필 전송 DioException 상세:");
          print("   - Status Code: ${e.response?.statusCode}");
          print("   - Response Data: ${e.response?.data}");
        }
      }
    }
  }

  // Read value - 저장된 토큰 가져오기
  Future<String?> getAccessToken() async {
    if (AppConfig.enableDebugLogs) {
      print("🔍 저장된 Access Token 조회 중...");
    }
    String? token = await storage.read(key: AppConfig.accessTokenKey);
    if (AppConfig.enableDebugLogs) {
      print("📖 조회된 Access Token: ${token ?? '없음'}");
    }
    return token;
  }

  // Read all values - 모든 저장된 값 가져오기
  Future<Map<String, String>> getAllTokens() async {
    if (AppConfig.enableDebugLogs) {
      print("🔍 모든 저장된 토큰 조회 중...");
    }
    Map<String, String> allValues = await storage.readAll();
    if (AppConfig.enableDebugLogs) {
      print("📖 모든 토큰: $allValues");
    }
    return allValues;
  }

  // Delete value - 특정 토큰 삭제
  Future<void> deleteAccessToken() async {
    if (AppConfig.enableDebugLogs) {
      print("🗑️ Access Token 삭제 중...");
    }
    await storage.delete(key: AppConfig.accessTokenKey);
    if (AppConfig.enableDebugLogs) {
      print("✅ Access Token 삭제 완료!");
    }
  }

  // Delete all - 로그아웃 (모든 토큰 삭제)
  Future<void> logout() async {
    if (AppConfig.enableDebugLogs) {
      print("🚪 로그아웃 시작 - 모든 토큰 삭제 중...");
    }
    await storage.deleteAll();
    if (AppConfig.enableDebugLogs) {
      print("🗑️ 모든 토큰 삭제 완료!");
    }
  }

  // 토큰 새로고침 함수
  Future<bool> refreshAccessToken() async {
    try {
      if (AppConfig.enableDebugLogs) {
        print("🔄 토큰 새로고침 시작...");
      }

      String? refreshToken = await storage.read(key: AppConfig.refreshTokenKey);
      if (refreshToken == null) {
        if (AppConfig.enableDebugLogs) {
          print("❌ Refresh Token이 없습니다. 재로그인이 필요합니다.");
        }
        return false;
      }

      if (AppConfig.enableDebugLogs) {
        print("🔑 사용할 Refresh Token: $refreshToken");
      }

      final refreshUrl =
          "${AppConfig.baseUrl}${AppConfig.refreshTokenEndpoint}";
      final response = await _dio.post(
        refreshUrl,
        data: {"refresh_token": refreshToken},
        options: Options(headers: AppConfig.defaultHeaders),
      );

      if (AppConfig.enableDebugLogs) {
        print("📥 토큰 새로고침 응답 상태: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        await _saveTokens(response.data);
        if (AppConfig.enableDebugLogs) {
          print("✅ 토큰 새로고침 성공!");
        }
        return true;
      }

      return false;
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 토큰 새로고침 에러: $e");
      }
      if (e is DioException) {
        if (AppConfig.enableDebugLogs) {
          print("🔍 Refresh DioException 상세:");
          print("   - Status Code: ${e.response?.statusCode}");
          print("   - Response Data: ${e.response?.data}");
        }
      }
      return false;
    }
  }

  Future<Map<String, dynamic>?> kakaoSocialLogin(
    String accessToken, [
    Map<String, dynamic>? kakaoUserInfo,
  ]) async {
    try {
      if (AppConfig.enableDebugLogs) {
        print("🚀 Kakao Social Login 시작");
        print("📤 전송할 accessToken: $accessToken");
      }

      final url = "${AppConfig.baseUrl}${AppConfig.socialKakaoEndpoint}";
      if (AppConfig.enableDebugLogs) {
        print("🌐 요청 URL: $url");
      }

      final response = await _dio.post(
        url,
        data: {"access_token": accessToken},
        options: Options(headers: AppConfig.defaultHeaders),
      );

      if (AppConfig.enableDebugLogs) {
        print("📥 Django Response Status: ${response.statusCode}");
        print("📥 Django Response Data: ${response.data}");
      }

      // 성공적인 응답 (200 또는 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (AppConfig.enableDebugLogs) {
          print("✅ 카카오 로그인 성공!");
        }

        // 토큰 저장
        await _saveTokens(data);

        // 카카오 사용자 정보를 서버에 전송 (구글과 동일한 방식)
        if (kakaoUserInfo != null) {
          await _sendKakaoUserProfileToServer(
            data['accessToken'],
            kakaoUserInfo,
          );
        }

        return data;
      } else {
        if (AppConfig.enableDebugLogs) {
          print("❌ 예상하지 못한 상태코드: ${response.statusCode}");
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 카카오 로그인 에러: $e");
      }
      if (e is DioException) {
        if (AppConfig.enableDebugLogs) {
          print("🔍 Kakao DioException 상세:");
          print("   - Status Code: ${e.response?.statusCode}");
          print("   - Response Data: ${e.response?.data}");
        }
      }
      rethrow;
    }
  }

  Future<void> naverSocialLogin(
    String accessToken,
    Map<String, dynamic> userInfo,
  ) async {
    try {
      print("👤 네이버 사용자 정보 서버 전송 시작");
      print("📤 전송할 네이버 사용자 정보: $userInfo");

      final dio = Dio();

      // 네이버 소셜 로그인 API 호출
      final Response naverResponse = await dio.post(
        '${AppConfig.baseUrl}/api/v1/users/social/naver', // AppConfig.baseUrl 사용
        data: {'access_token': accessToken, 'user_info': userInfo},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (AppConfig.enableDebugLogs) {
        print(
          "🌐 네이버 소셜 로그인 URL: ${AppConfig.baseUrl}/api/v1/users/social/naver",
        ); // 수정
        print(
          "📤 전송할 네이버 로그인 데이터: ${{'access_token': accessToken, 'user_info': userInfo}}",
        );
        print("📥 네이버 소셜 로그인 응답 상태: ${naverResponse.statusCode}");
      }

      if (naverResponse.statusCode == 200 || naverResponse.statusCode == 201) {
        // 토큰 저장
        await _saveTokens(naverResponse.data);

        if (AppConfig.enableDebugLogs) {
          print("✅ 네이버 소셜 로그인 성공!");
        }

        // 네이버 사용자 프로필 전송 (필요한 경우)
        await _sendNaverUserProfile(userInfo);
      } else {
        throw Exception("네이버 소셜 로그인 실패: ${naverResponse.statusCode}");
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 네이버 소셜 로그인 에러: $e");
      }
      rethrow;
    }
  }

  Future<void> _sendNaverUserProfile(Map<String, dynamic> userInfo) async {
    try {
      print("👤 네이버 사용자 프로필 서버 전송 시작");
      print("📤 받은 네이버 사용자 정보: $userInfo");

      final dio = Dio();
      final storage = FlutterSecureStorage();

      print("🔑 토큰 읽기 시작...");
      final token = await storage.read(key: AppConfig.accessTokenKey);

      if (token == null) {
        print("❌ 토큰이 null입니다!");
        throw Exception("인증 토큰이 없습니다.");
      }

      print("🔑 토큰 확인: ${token.substring(0, 10)}...");

      // 생일 데이터 변환
      String? formattedBirthday;
      if (userInfo['birthday'] != null && userInfo['birthyear'] != null) {
        try {
          final birthday = userInfo['birthday'] as String; // MM-DD 형식 예상
          final birthyear = userInfo['birthyear'] as String; // YYYY 형식 예상

          print("🎂 원본 생일 데이터: birthday=$birthday, birthyear=$birthyear");

          // MM-DD 형식을 YYYY-MM-DD로 변환
          if (birthday.contains('-') && birthday.length >= 5) {
            formattedBirthday = '$birthyear-$birthday';
            print("🎂 변환된 생일: $formattedBirthday");
          } else {
            print("⚠️ 생일 형식을 인식할 수 없어 제외합니다: $birthday");
          }
        } catch (e) {
          print("⚠️ 생일 데이터 변환 중 에러 발생: $e");
          print("⚠️ 생일 데이터를 제외하고 진행합니다.");
        }
      } else {
        print("⚠️ 생일 또는 생년 데이터가 없습니다.");
      }

      final requestData = {
        'profile': {
          'nickname': userInfo['nickname'],
          'images': [
            if (userInfo['profileImage'] != null)
              {'image_url': userInfo['profileImage'], 'scale': 'AVATAR'},
          ],
          'email': userInfo['email'],
          'name': userInfo['name'],
          'mobile': userInfo['mobile'],
          'gender': userInfo['gender'],
          'age': userInfo['age'],
          // 변환된 생일만 포함 (형식이 올바른 경우에만)
          if (formattedBirthday != null) 'birthday': formattedBirthday,
          'birthyear': userInfo['birthyear'],
        },
        'user_id': userInfo['id'],
      };

      print("📤 전송할 프로필 데이터: $requestData");
      print("🌐 요청 URL: ${AppConfig.baseUrl}/api/v1/users/");
      print("🔑 Authorization 헤더: Bearer ${token.substring(0, 10)}...");

      final Response profileResponse = await dio.post(
        '${AppConfig.baseUrl}/api/v1/users/',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          // 409 상태 코드도 성공으로 처리
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print("📥 프로필 전송 응답 상태: ${profileResponse.statusCode}");
      print("📥 프로필 전송 응답 데이터: ${profileResponse.data}");

      if (profileResponse.statusCode == 201) {
        print("✅ 네이버 사용자 프로필 서버 전송 성공! (새 사용자 생성)");
      } else if (profileResponse.statusCode == 409) {
        print("✅ 네이버 사용자 프로필 처리 완료! (이미 가입된 사용자)");
        // 409는 이미 가입된 사용자라는 의미이므로 정상적으로 처리
      } else {
        print("⚠️ 예상치 못한 응답 상태: ${profileResponse.statusCode}");
        print("⚠️ 응답 내용: ${profileResponse.data}");
      }
    } catch (e) {
      print("💥 네이버 사용자 프로필 서버 전송 에러: $e");

      if (e is DioException) {
        print("🔍 DioException 상세 정보:");
        print("  - 상태 코드: ${e.response?.statusCode}");
        print("  - 응답 데이터: ${e.response?.data}");

        // 409는 이미 가입된 사용자이므로 에러가 아님
        if (e.response?.statusCode == 409) {
          print("✅ 이미 가입된 사용자입니다. 정상 처리됨.");
          return; // 에러를 다시 던지지 않고 정상 완료
        }
      }

      rethrow;
    }
  }
}

final authRepoProvider = Provider((ref) => AuthenticationRepo());
