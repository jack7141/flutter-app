// lib/features/user_info/view_models/user_info_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/app_config.dart';
import '../models/user_info_model.dart';

class UserInfoService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveUserInfo(UserInfoModel userInfo) async {
    try {
      print("📤 사용자 정보 저장 시작");

      final jsonData = userInfo.toJson();
      print("📋 저장할 데이터: $jsonData");

      // hobbies 필드 특별 확인
      if (jsonData.containsKey('hobbies')) {
        print(
          "✅ hobbies 필드 존재: ${jsonData['hobbies']} (타입: ${jsonData['hobbies'].runtimeType})",
        );
      } else {
        print("❌ hobbies 필드 누락!");
      }

      // job 필드 확인
      if (jsonData.containsKey('job')) {
        print(
          "✅ job 필드 존재: ${jsonData['job']} (타입: ${jsonData['job'].runtimeType})",
        );
      } else {
        print("❌ job 필드 누락!");
      }

      // 빈 데이터면 저장하지 않음
      if (jsonData.isEmpty) {
        print("⚠️ 저장할 데이터가 없습니다");
        return;
      }

      // 토큰 가져오기
      String? accessToken = await _storage.read(key: AppConfig.accessTokenKey);
      String? tokenType = await _storage.read(key: AppConfig.tokenTypeKey);

      if (accessToken == null) {
        throw Exception('액세스 토큰이 없습니다');
      }

      print("🔗 API 호출: PATCH http://localhost:8000/api/v1/users/profile/");
      print("📤 전송 헤더: Authorization: ${tokenType ?? 'Bearer'} $accessToken");
      print("📤 전송 데이터: $jsonData");

      final response = await _dio.patch(
        'http://localhost:8000/api/v1/users/profile/',
        data: jsonData,
        options: Options(
          headers: {
            ...AppConfig.defaultHeaders,
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
          },
        ),
      );

      print("📥 API 응답 상태: ${response.statusCode}");
      print("📥 API 응답 데이터: ${response.data}");

      // 응답에서 hobbies 필드 확인 (스코프 문제 해결)
      if (response.data != null && response.data is Map) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('hobbies')) {
          print("📥 응답의 hobbies 필드: ${responseData['hobbies']}");
        } else {
          print("📥 응답에 hobbies 필드 없음");
        }

        if (responseData.containsKey('job')) {
          print("📥 응답의 job 필드: ${responseData['job']}");
        } else {
          print("📥 응답에 job 필드 없음");
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 사용자 정보 저장 성공');
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ API 호출 실패 (DioException)');
      print('   상태 코드: ${e.response?.statusCode}');
      print('   응답 데이터: ${e.response?.data}');
      print('   에러 메시지: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ 사용자 정보 저장 실패: $e');
      rethrow;
    }
  }
}
