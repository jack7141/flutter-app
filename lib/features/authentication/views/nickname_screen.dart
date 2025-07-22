import 'dart:convert';

import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class NicknameScreen extends StatefulWidget {
  static const String routeName = "nickname";
  static const String routePath = "/nickname";

  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _onSaveTap() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('닉네임을 입력해주세요.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _secureStorage.read(key: AppConfig.accessTokenKey);

      print('🔑 찾은 토큰: $token');

      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      // PATCH 요청으로 닉네임 업데이트
      final response = await http.patch(
        Uri.parse('${AppConfig.baseUrl}/api/v1/users/profile/'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'nickname': nickname}),
      );

      print('📤 닉네임 업데이트 요청: $nickname');
      print('📡 응답 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ 닉네임 업데이트 성공');

        // 성공시 localStorage에 닉네임 저장
        await _secureStorage.write(key: 'user_nickname', value: nickname);
        print('💾 닉네임 로컬 저장 완료: $nickname');

        if (context.mounted) {
          context.pushReplacement('/home');
        }
      } else {
        throw Exception('닉네임 업데이트 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 닉네임 업데이트 에러: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('닉네임 저장에 실패했습니다. 다시 시도해주세요.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '셀럽에게 불릴\n이름을 설정해주세요.',
              style: TextStyle(
                fontSize: Sizes.size28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gaps.v20,
            TextField(
              controller: _nicknameController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: '이름을 입력해주세요.',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            Gaps.v20,
            GestureDetector(
              onTap: _isLoading ? null : _onSaveTap,
              child: FormButton(text: _isLoading ? '저장 중...' : '저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
