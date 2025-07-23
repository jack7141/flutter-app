import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/features/user_profile/widgets/mypage_formbutton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const String routeName = 'update_profile';
  static const String routeURL = '/update_profile';
  final String? userId;
  final String? userName;
  const UpdateProfileScreen({super.key, this.userId, this.userName});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _secureStorage = FlutterSecureStorage();

  // 로그아웃 모달 표시
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '로그아웃',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text('로그아웃하시겠습니까?', style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 모달 닫기
              },
              child: Text(
                '취소',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 모달 닫기
                _performLogout(); // 로그아웃 실행
              },
              child: Text(
                '확인',
                style: TextStyle(
                  color: Color(0xff9e9ef4),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 로그아웃 API 호출
  Future<void> _performLogout() async {
    try {
      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('로그아웃 중...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      // 저장된 토큰 가져오기
      final accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        throw Exception('토큰이 없습니다.');
      }

      final dio = Dio();

      // 로그아웃 API 호출
      final response = await dio.post(
        '${AppConfig.baseUrl}/api/v1/users/logout',
        options: Options(
          headers: {'accept': '*/*', 'Authorization': 'Bearer $accessToken'},
        ),
      );

      print("✅ 로그아웃 API 응답: ${response.statusCode}");

      // 200과 204 모두 성공으로 처리
      if (response.statusCode == 200 || response.statusCode == 204) {
        // 로그아웃 성공 - 저장된 토큰들 삭제
        await _secureStorage.deleteAll();
        print("✅ 로그아웃 성공 - 토큰 삭제 완료");

        if (context.mounted) {
          // 로딩 다이얼로그 닫기
          Navigator.of(context).pop();

          // 로그인 페이지로 이동
          context.go('/login');
        }
      } else {
        throw Exception('로그아웃 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ 로그아웃 에러: $e");

      if (context.mounted) {
        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();

        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 회원 탈퇴 모달 표시
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '회원 탈퇴',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('정말로 회원 탈퇴하시겠습니까?', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(
                '• 모든 개인정보가 삭제됩니다\n• 구독 정보도 모두 삭제됩니다\n• 이 작업은 되돌릴 수 없습니다',
                style: TextStyle(fontSize: 14, color: Colors.red.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 모달 닫기
              },
              child: Text(
                '취소',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 모달 닫기
                _performDeleteAccount(); // 회원 탈퇴 실행
              },
              child: Text(
                '탈퇴',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 회원 탈퇴 API 호출
  Future<void> _performDeleteAccount() async {
    try {
      // 로딩 다이얼로그 표시
      if (!mounted) {
        print("❌ 위젯이 unmounted 상태 - 초기 체크");
        return;
      }

      print("📱 로딩 다이얼로그 표시 시작");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('회원 탈퇴 처리 중...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      // 저장된 토큰과 사용자 ID 가져오기
      final accessToken = await _secureStorage.read(key: 'access_token');
      final userId = await _secureStorage.read(key: 'user_id');

      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다');
      }

      if (userId == null) {
        throw Exception('사용자 ID가 없습니다');
      }

      print("🗑️ 회원 탈퇴 API 호출: userId=$userId");

      // 회원 탈퇴 API 호출
      final response = await Dio().delete(
        '${AppConfig.baseUrl}/api/v1/users/$userId/',
        options: Options(
          headers: {'accept': '*/*', 'Authorization': 'Bearer $accessToken'},
        ),
      );

      print("✅ 회원 탈퇴 API 응답: ${response.statusCode}");

      if (response.statusCode == 204 || response.statusCode == 200) {
        // 성공 시 모든 로컬 데이터 삭제
        await _secureStorage.deleteAll();
        print("✅ 회원 탈퇴 성공 - 모든 데이터 삭제 완료");

        print("🔍 mounted 상태 체크: $mounted");
        // mounted 체크 후 UI 업데이트
        if (!mounted) {
          print("❌ 위젯이 unmounted 상태 - UI 업데이트 불가");
          return;
        }

        print("🚪 로딩 다이얼로그 닫기 시도");
        // 로딩 다이얼로그 닫기
        try {
          if (Navigator.of(context).canPop()) {
            print("✅ Navigator canPop: true - 다이얼로그 닫기");
            Navigator.of(context).pop();
          } else {
            print("⚠️ Navigator canPop: false");
          }
        } catch (e) {
          print("❌ 다이얼로그 닫기 실패: $e");
        }

        print("🔍 두번째 mounted 상태 체크: $mounted");
        if (!mounted) {
          print("❌ 위젯이 unmounted 상태 - 페이지 이동 불가");
          return;
        }

        print("�� 로그인 페이지로 바로 이동");
        // 성공 메시지와 1초 대기 제거하고 바로 페이지 이동
        context.go('/login');
        print("✅ 페이지 이동 완료");
      } else {
        throw Exception('회원 탈퇴 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ 회원 탈퇴 에러: $e");

      if (mounted) {
        print("🚪 에러 발생 - 로딩 다이얼로그 닫기");
        // 로딩 다이얼로그 닫기
        try {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } catch (popError) {
          print("❌ 에러 시 다이얼로그 닫기 실패: $popError");
        }

        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원 탈퇴 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print("❌ 위젯이 unmounted 상태 - 에러 UI 표시 불가");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CommonAppBar(title: '계정 정보'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '연동 로그인',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                Gaps.v10,
                Text(
                  'user@example.com',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Gaps.v32,
                Text(
                  '이름',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                Gaps.v10,
                Text(
                  '홍길동',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Gaps.v32,
                Text(
                  '휴대폰 번호',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                Gaps.v10,
                Text(
                  '+82 10-1234-5678',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Gaps.v32,
                Divider(color: Colors.grey.shade300, thickness: 1),
                Gaps.v32,
                GestureDetector(
                  onTap: _showLogoutDialog, // 모달 다이얼로그 표시
                  child: MyPageFormButton(
                    title: "로그아웃",
                    icon: Icons.arrow_forward_ios,
                  ),
                ),
                Gaps.v32,
                GestureDetector(
                  onTap: _showDeleteAccountDialog, // 회원 탈퇴 모달 다이얼로그 표시
                  child: MyPageFormButton(
                    title: "회원탈퇴",
                    icon: Icons.arrow_forward_ios,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
