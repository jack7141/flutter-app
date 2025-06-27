// 인증 관련 레포지토리
// 서버와 통신 담당

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationRepo {
  final _dio = Dio();

  // Create storage
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>?> googleSocialLogin(String idToken) async {
    try {
      print("🚀 Google Social Login 시작");
      print("📤 전송할 idToken: $idToken");

      const url = "http://127.0.0.1:8000/api/v1/users/social/google";
      print("🌐 요청 URL: $url");

      final response = await _dio.post(url, data: {"id_token": idToken});

      print("📥 Django Response Status: ${response.statusCode}");
      print("📥 Django Response Data: ${response.data}");

      // 성공적인 응답 (200 또는 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print("✅ 로그인 성공!");

        // Write values to secure storage
        print("💾 토큰 저장 시작...");
        await storage.write(key: 'access_token', value: data['accessToken']);
        print("💾 Access Token 저장 완료: ${data['accessToken']}");

        await storage.write(key: 'token_type', value: data['tokenType']);
        print("💾 Token Type 저장 완료: ${data['tokenType']}");

        await storage.write(
          key: 'expires_in',
          value: data['expiresIn'].toString(),
        );
        print("💾 Expires In 저장 완료: ${data['expiresIn']}");
        print("🎉 모든 토큰 정보 저장 완료!");

        return data;
      } else {
        print("❌ 예상하지 못한 상태코드: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("💥 Login error 발생: $e");
      if (e is DioException) {
        print("🔍 DioException 상세:");
        print("   - Status Code: ${e.response?.statusCode}");
        print("   - Response Data: ${e.response?.data}");
        print("   - Error Message: ${e.message}");
      }
      return null;
    }
  }

  // Read value - 저장된 토큰 가져오기
  Future<String?> getAccessToken() async {
    print("🔍 저장된 Access Token 조회 중...");
    String? token = await storage.read(key: 'access_token');
    print("📖 조회된 Access Token: ${token ?? '없음'}");
    return token;
  }

  // Read all values - 모든 저장된 값 가져오기
  Future<Map<String, String>> getAllTokens() async {
    print("🔍 모든 저장된 토큰 조회 중...");
    Map<String, String> allValues = await storage.readAll();
    print("📖 모든 토큰: $allValues");
    return allValues;
  }

  // Delete value - 특정 토큰 삭제
  Future<void> deleteAccessToken() async {
    print("🗑️ Access Token 삭제 중...");
    await storage.delete(key: 'access_token');
    print("✅ Access Token 삭제 완료!");
  }

  // Delete all - 로그아웃 (모든 토큰 삭제)
  Future<void> logout() async {
    print("🚪 로그아웃 시작 - 모든 토큰 삭제 중...");
    await storage.deleteAll();
    print("🗑️ 모든 토큰 삭제 완료!");
  }
}

final authRepoProvider = Provider((ref) => AuthenticationRepo());
