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
        if (AppConfig.enableDebugLogs) {
          print("📄 연예인 API 원본 응답: $data");
        }

        try {
          final results = data['results'] as List;
          if (AppConfig.enableDebugLogs) {
            print("📋 results 배열: $results");
          }

          final celebList = <CelebModel>[];
          for (var celebJson in results) {
            try {
              final celeb = CelebModel.fromJson(celebJson);
              celebList.add(celeb);
            } catch (e) {
              print("💥 개별 연예인 파싱 에러: $e");
              // 개별 에러는 무시하고 계속 진행
            }
          }

          if (AppConfig.enableDebugLogs) {
            print("✅ 최종 파싱된 연예인 수: ${celebList.length}");
          }

          return celebList;
        } catch (e) {
          print("💥 전체 파싱 에러: $e");
          return null;
        }
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
