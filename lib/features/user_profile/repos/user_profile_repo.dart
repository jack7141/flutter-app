import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final userProfileRepoProvider = Provider((ref) {
  final authRepo = ref.read(authRepoProvider);
  return UserProfileRepo(authRepo: authRepo);
});

class UserProfileRepo {
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();
  final AuthenticationRepo authRepo;

  UserProfileRepo({required this.authRepo});

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      print("👤 사용자 프로필 조회 시작");

      // 첫 번째 시도
      final result = await _makeProfileRequest();

      if (result != null) {
        return result;
      }

      // 401 에러가 발생했다면 토큰 새로고침 시도
      print("🔄 토큰 새로고침 후 재시도...");
      final refreshSuccess = await authRepo.refreshAccessToken();

      if (refreshSuccess) {
        // 토큰 새로고침 성공 후 재시도
        return await _makeProfileRequest();
      } else {
        print("❌ 토큰 새로고침 실패. 재로그인이 필요합니다.");
        await storage.deleteAll(); // 모든 토큰 삭제
        return null;
      }
    } catch (e) {
      print("💥 사용자 프로필 조회 최종 에러: $e");
      return null;
    }
  }

  // 실제 프로필 요청을 수행하는 함수
  Future<Map<String, dynamic>?> _makeProfileRequest() async {
    try {
      String? accessToken = await storage.read(key: 'access_token');
      String? tokenType = await storage.read(key: 'token_type');

      if (accessToken == null) {
        print("❌ 액세스 토큰이 없습니다");
        return null;
      }

      print("🔑 토큰 확인: ${tokenType ?? 'Bearer'} $accessToken");

      final response = await dio.get(
        'http://127.0.0.1:8000/api/v1/users/me',
        options: Options(
          headers: {
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      print("📥 사용자 프로필 응답: ${response.data}");
      print("📊 응답 상태코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print("🔒 401 Unauthorized - 토큰이 유효하지 않습니다");
        return null; // null을 반환하여 상위에서 토큰 새로고침 시도
      }

      print("💥 프로필 요청 에러: $e");
      rethrow; // 다른 에러는 다시 throw
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
