import 'dart:convert';

import 'package:celeb_voice/config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DailyMessageService {
  static String get _baseUrl =>
      '${AppConfig.baseUrl}/api/v1/celeb/message/daily';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<List<DailyMessageResponse>> getDailyMessages(
    String celebId,
  ) async {
    print('🚀 getDailyMessages 시작! celebId: $celebId'); // 이 줄 추가

    try {
      print('🔍 토큰 조회 시작...');

      // 토큰 가져오기 (기존 subscription_service 방식과 동일)
      String? accessToken = await _storage.read(key: AppConfig.accessTokenKey);
      String? tokenType = await _storage.read(key: AppConfig.tokenTypeKey);

      print(
        '🔑 Access Token: ${accessToken != null ? '${accessToken.substring(0, 20)}...' : 'null'}',
      );
      print('🔑 Token Type: $tokenType');

      if (accessToken == null) {
        print('❌ 토큰이 없습니다');
        return [];
      }

      final headers = {
        ...AppConfig.defaultHeaders,
        'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
      };

      print('📋 최종 헤더: $headers');

      final response = await http.get(
        Uri.parse('$_baseUrl/$celebId/'),
        headers: headers,
      );

      print('📞 Daily Message API 호출: $celebId');
      print('📊 응답 상태: ${response.statusCode}');
      print('📄 응답 데이터: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return [DailyMessageResponse.fromJson(data)];
      } else {
        print('❌ API 호출 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Daily Message API 호출 에러: $e');
      return [];
    }
  }
}

class DailyMessageResponse {
  final String generatedText;
  final String audioFile;
  final String postedAt;

  DailyMessageResponse({
    required this.generatedText,
    required this.audioFile,
    required this.postedAt,
  });

  factory DailyMessageResponse.fromJson(Map<String, dynamic> json) {
    return DailyMessageResponse(
      generatedText: json['generatedText'],
      audioFile: json['audioFile'],
      postedAt: json['postedAt'],
    );
  }
}
