import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/app_config.dart';

class UserProfileRepo {
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();
  final AuthenticationRepo authRepo;

  UserProfileRepo({required this.authRepo});

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (AppConfig.enableDebugLogs) {
        print("👤 사용자 프로필 조회 시작");
      }

      final result = await _makeProfileRequest();

      if (result != null) {
        return result;
      }

      if (AppConfig.enableDebugLogs) {
        print("🔄 토큰 새로고침 후 재시도...");
      }
      final refreshSuccess = await authRepo.refreshAccessToken();

      if (refreshSuccess) {
        return await _makeProfileRequest();
      } else {
        if (AppConfig.enableDebugLogs) {
          print("❌ 토큰 새로고침 실패. 재로그인이 필요합니다.");
        }
        await storage.deleteAll();
        return null;
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 사용자 프로필 조회 최종 에러: $e");
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> _makeProfileRequest() async {
    try {
      String? accessToken = await storage.read(key: AppConfig.accessTokenKey);
      String? tokenType = await storage.read(key: AppConfig.tokenTypeKey);

      if (accessToken == null) {
        if (AppConfig.enableDebugLogs) {
          print("❌ 액세스 토큰이 없습니다");
        }
        return null;
      }

      final url = "${AppConfig.baseUrl}${AppConfig.usersMeEndpoint}";
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            ...AppConfig.defaultHeaders,
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
          },
        ),
      );

      if (AppConfig.enableDebugLogs) {
        print("📥 사용자 프로필 응답: ${response.data}");
      }

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        if (AppConfig.enableDebugLogs) {
          print("🔒 401 Unauthorized - 토큰이 유효하지 않습니다");
        }
        return null;
      }

      if (AppConfig.enableDebugLogs) {
        print("💥 프로필 요청 에러: $e");
      }
      rethrow;
    }
  }

  // 유효하지 않은 토큰 삭제
  Future<void> _clearInvalidTokens() async {
    print("🗑️ 유효하지 않은 토큰들을 삭제합니다...");
    await storage.deleteAll();
    print("✅ 토큰 삭제 완료");
  }

  // 토큰 새로고침 (필요시)
  Future<bool> refreshToken() async {
    try {
      print("🔄 토큰 새로고침 시도...");
      // 여기에 토큰 새로고침 로직 구현
      // 서버에서 refresh token을 지원한다면
      return false;
    } catch (e) {
      print("💥 토큰 새로고침 실패: $e");
      return false;
    }
  }
}
