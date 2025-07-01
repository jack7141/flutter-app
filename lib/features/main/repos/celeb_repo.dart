import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/app_config.dart';
import '../models/celeb_models.dart';

class CelebRepo {
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();

  Future<List<CelebModel>?> getCelebs() async {
    try {
      if (AppConfig.enableDebugLogs) {
        print("🌟 연예인 목록 조회 시작");
      }

      String? accessToken = await storage.read(key: AppConfig.accessTokenKey);
      String? tokenType = await storage.read(key: AppConfig.tokenTypeKey);

      if (accessToken == null) {
        if (AppConfig.enableDebugLogs) {
          print("❌ 액세스 토큰이 없습니다");
        }
        return null;
      }

      final url = "${AppConfig.baseUrl}${AppConfig.celebEndpoint}";
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
        print("📥 연예인 목록 응답 상태: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final data = response.data;
        final results = data['results'] as List;

        List<CelebModel> celebs = results.map((celebData) {
          return CelebModel.fromJson({
            'id': celebData['id'],
            'name': celebData['name'],
            'imagePath': celebData['images'].isNotEmpty
                ? _convertToCloudFrontUrl(celebData['images'][0]['imageUrl'])
                : '',
            'description': celebData['description'] ?? '',
            'category': celebData['category'] ?? '',
            'tags': List<String>.from(celebData['tags'] ?? []),
            'status': celebData['status'],
            'index': celebData['index'],
          });
        }).toList();

        if (AppConfig.enableDebugLogs) {
          print("✅ 연예인 목록 변환 완료: ${celebs.length}개");
        }
        return celebs;
      }

      return null;
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 연예인 목록 조회 에러: $e");
      }
      return null;
    }
  }

  String _convertToCloudFrontUrl(String s3Url) {
    if (s3Url.startsWith(AppConfig.s3Domain)) {
      return s3Url.replaceFirst(AppConfig.s3Domain, AppConfig.cloudFrontDomain);
    }
    return s3Url;
  }
}
