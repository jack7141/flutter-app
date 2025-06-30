import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HobbyRepo {
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();

  Future<List<Map<String, dynamic>>?> getHobbies() async {
    try {
      print("🎯 취미 목록 조회 시작");

      // 토큰 가져오기
      String? accessToken = await storage.read(key: 'access_token');
      String? tokenType = await storage.read(key: 'token_type');

      if (accessToken == null) {
        print("❌ 액세스 토큰이 없습니다");
        return null;
      }

      final response = await dio.get(
        'http://localhost:8000/api/v1/users/hobby/',
        options: Options(
          headers: {
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      print("📥 취미 목록 응답 상태: ${response.statusCode}");
      print("📥 취미 목록 응답 데이터: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        final results = data['results'] as List;
        return results.cast<Map<String, dynamic>>();
      }

      return null;
    } catch (e) {
      print("💥 취미 목록 조회 에러: $e");
      if (e is DioException) {
        print("🔍 DioException 상세:");
        print("   - Status Code: ${e.response?.statusCode}");
        print("   - Response Data: ${e.response?.data}");
      }
      return null;
    }
  }
}
