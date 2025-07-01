import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/celeb_models.dart';

class CelebRepo {
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();

  Future<List<CelebModel>?> getCelebs() async {
    try {
      print("🌟 연예인 목록 조회 시작");

      // 토큰 가져오기
      String? accessToken = await storage.read(key: 'access_token');
      String? tokenType = await storage.read(key: 'token_type');

      if (accessToken == null) {
        print("❌ 액세스 토큰이 없습니다");
        return null;
      }

      final response = await dio.get(
        'http://localhost:8000/api/v1/celeb/',
        options: Options(
          headers: {
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      print("📥 연예인 목록 응답 상태: ${response.statusCode}");
      print("📥 연예인 목록 응답 데이터: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        final results = data['results'] as List;

        // API 응답을 CelebModel로 변환
        List<CelebModel> celebs = results.map((celebData) {
          // S3 URL을 CloudFront URL로 변환
          String imagePath = celebData['images'].isNotEmpty
              ? _convertToCloudFrontUrl(celebData['images'][0]['imageUrl'])
              : '';

          return CelebModel.fromJson({
            'id': celebData['id'],
            'name': celebData['name'],
            'imagePath': imagePath,
            'description': celebData['description'] ?? '',
            'category': celebData['category'] ?? '',
            'tags': List<String>.from(celebData['tags'] ?? []),
            'status': celebData['status'],
            'index': celebData['index'],
          });
        }).toList();

        print("✅ 연예인 목록 변환 완료: ${celebs.length}개");
        return celebs;
      }

      return null;
    } catch (e) {
      print("💥 연예인 목록 조회 에러: $e");
      if (e is DioException) {
        print("🔍 DioException 상세:");
        print("   - Status Code: ${e.response?.statusCode}");
        print("   - Response Data: ${e.response?.data}");
      }
      return null;
    }
  }

  // S3 URL을 CloudFront URL로 변환하는 함수
  String _convertToCloudFrontUrl(String s3Url) {
    const cloudFrontDomain = "https://d1v09q065yb59g.cloudfront.net";
    const s3Domain =
        "https://celebvoice-bucket.s3.ap-northeast-2.amazonaws.com";

    if (s3Url.startsWith(s3Domain)) {
      return s3Url.replaceFirst(s3Domain, cloudFrontDomain);
    }

    return s3Url;
  }
}
