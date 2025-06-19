// 인증 관련 레포지토리
// 서버와 통신 담당

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationRepo {
  final _dio = Dio();
  Future<void> googleSocialLogin(String idToken) async {
    // 구글 로그인 로직
    const url = "http://127.0.0.1:8000/api/v1/users/social/google";
    final response = await _dio.post(url, data: {"id_token": idToken});
    print("Django Response: ${response.data}");
  }
}

final authRepoProvider = Provider((ref) => AuthenticationRepo());
