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

    if (AppConfig.enableDebugLogs) {
      print("🎉 모든 토큰 정보 저장 완료!");
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
}

final authRepoProvider = Provider((ref) => AuthenticationRepo());
