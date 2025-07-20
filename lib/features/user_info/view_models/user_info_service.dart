// lib/features/user_info/view_models/user_info_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/app_config.dart';
import '../models/user_info_model.dart';

class UserInfoService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveUserInfo(UserInfoModel userInfo) async {
    try {
      final jsonData = userInfo.toJson();
      _logSaveAttempt(jsonData);

      if (jsonData.isEmpty) {
        throw Exception('저장할 데이터가 없습니다');
      }

      final token = await _getAuthToken();
      final response = await _sendRequest(jsonData, token);

      _logSaveResult(response);
    } catch (e) {
      _logError(e);
      rethrow;
    }
  }

  Future<String> _getAuthToken() async {
    final accessToken = await _storage.read(key: AppConfig.accessTokenKey);
    final tokenType = await _storage.read(key: AppConfig.tokenTypeKey);

    if (accessToken == null) {
      throw Exception('액세스 토큰이 없습니다');
    }

    return '${tokenType ?? 'Bearer'} $accessToken';
  }

  Future<Response> _sendRequest(
    Map<String, dynamic> data,
    String authToken,
  ) async {
    return await _dio.patch(
      '${AppConfig.baseUrl}/api/v1/users/profile/',
      data: data,
      options: Options(
        headers: {...AppConfig.defaultHeaders, 'Authorization': authToken},
      ),
    );
  }

  void _logSaveAttempt(Map<String, dynamic> data) {
    print("📤 사용자 정보 저장 시작");
    print("📋 저장할 데이터: $data");

    // 중요 필드만 체크
    final hasHobbies = data.containsKey('hobbies');
    final hasJob = data.containsKey('job');
    print("✅ 필수 필드 확인 - hobbies: $hasHobbies, job: $hasJob");
  }

  void _logSaveResult(Response response) {
    print("📥 API 응답: ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ 사용자 정보 저장 성공');
    } else {
      throw Exception('서버 응답 오류: ${response.statusCode}');
    }
  }

  void _logError(dynamic error) {
    if (error is DioException) {
      print('❌ API 호출 실패: ${error.response?.statusCode}');
      print('   응답: ${error.response?.data}');
    } else {
      print('❌ 저장 실패: $error');
    }
  }
}
