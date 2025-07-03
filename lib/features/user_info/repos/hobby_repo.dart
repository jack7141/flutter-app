import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/app_config.dart';

class HobbyRepo {
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();

  Future<List<Map<String, dynamic>>?> getHobbies() async {
    try {
      if (AppConfig.enableDebugLogs) {
        print("🎯 취미 목록 조회 시작");
      }

      String? accessToken = await storage.read(key: AppConfig.accessTokenKey);
      String? tokenType = await storage.read(key: AppConfig.tokenTypeKey);

      if (accessToken == null) {
        if (AppConfig.enableDebugLogs) {
          print("❌ 액세스 토큰이 없습니다");
        }
        return null;
      }

      final url = "${AppConfig.baseUrl}${AppConfig.hobbyEndpoint}";
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
        print("📥 취미 목록 응답 상태: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final data = response.data;
        final results = data['data'] as List;
        return results.cast<Map<String, dynamic>>();
      }

      return null;
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 취미 목록 조회 에러: $e");
      }
      return null;
    }
  }
}
