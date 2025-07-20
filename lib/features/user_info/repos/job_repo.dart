import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/app_config.dart';

class JobRepo {
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();

  Future<List<Map<String, dynamic>>?> getJobs() async {
    try {
      String? accessToken = await storage.read(key: 'access_token');
      String? tokenType = await storage.read(key: 'token_type');
      final response = await dio.get(
        '${AppConfig.baseUrl}/api/v1/users/job/',
        options: Options(
          headers: {
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final results = data['data'] as List;
        return results.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        print("🔍 DioException 상세:");
        print("   - Status Code: ${e.response?.statusCode}");
        print("   - Response Data: ${e.response?.data}");
      }
      return null;
    }
  }
}
