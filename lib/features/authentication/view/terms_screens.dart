import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/widget/circular_checkbox.dart';
import 'package:celeb_voice/services/dio_service.dart'; // DioService 추가
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // SecureStorage 추가
import 'package:go_router/go_router.dart';

// 이용약관 동의 화면
class TermsScreen extends StatefulWidget {
  static const String routeName = "terms";
  static const String routePath = "/terms";

  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _agreeAll = false; // 전체 동의
  bool _agreeService = false; // 서비스 이용약관 동의
  bool _agreePrivacy = false; // 개인정보 수집 및 이용 동의
  bool _agreeMarketing = false; // 광고 및 마케팅 활용 동의
  bool _isLoading = false; // 로딩 상태 추가

  // DioService와 SecureStorage 추가
  Dio get _dio => DioService().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 전체 동의 체크박스 처리
  void _onAgreeAllChanged(bool value) {
    setState(() {
      _agreeAll = value;
      _agreeService = _agreeAll;
      _agreePrivacy = _agreeAll;
      _agreeMarketing = _agreeAll;
    });
  }

  // 개별 체크박스 처리
  void _onIndividualChanged() {
    setState(() {
      _agreeAll = _agreeService && _agreePrivacy && _agreeMarketing;
    });

    // 디버깅 로그 추가
    print('🔍 체크박스 상태 변경:');
    print('   - _agreeService: $_agreeService');
    print('   - _agreePrivacy: $_agreePrivacy');
    print('   - _agreeMarketing: $_agreeMarketing');
    print('   - _agreeAll: $_agreeAll');
    print('   - _canProceed: $_canProceed');
  }

  void _onPressIconButton() {
    Navigator.of(context).pop();
  }

  // 다음 버튼 활성화 조건 (필수 항목만 체크되면 됨)
  bool get _canProceed => _agreeService && _agreePrivacy;

  // 약관 동의 API 호출 메서드 수정 (디버깅 강화)
  Future<void> _confirmTerms() async {
    print('🔍 _confirmTerms 메서드 호출됨');

    setState(() {
      _isLoading = true;
    });

    try {
      // 저장된 user_id 가져오기
      final userId = await _storage.read(key: 'user_id');

      print('🔍 저장된 User ID: $userId');

      if (userId == null || userId.isEmpty) {
        throw Exception('사용자 ID를 찾을 수 없습니다.');
      }

      print('🚀 약관 동의 API 호출 시작');
      print('📤 요청 URL: /api/v1/users/$userId/');
      print('📤 요청 데이터: {"is_confirm": true}');

      // PATCH 요청으로 is_confirm만 true로 업데이트
      final response = await _dio.patch(
        '/api/v1/users/$userId/',
        data: {'is_confirm': true},
      );

      print('📥 응답 상태코드: ${response.statusCode}');
      print('📥 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ 약관 동의 처리 성공');

        if (context.mounted) {
          // 뒤로가기 불가능하게 이동
          context.pushReplacement('/nickname');
        }
      } else {
        throw Exception('약관 동의 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 약관 동의 처리 에러: $e');
      print('❌ 에러 타입: ${e.runtimeType}');

      if (e is DioException) {
        print('❌ DioException 상세:');
        print('   - 상태코드: ${e.response?.statusCode}');
        print('   - 응답 데이터: ${e.response?.data}');
        print('   - 에러 메시지: ${e.message}');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('약관 동의 처리에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
  Widget build(BuildContext context) {
    // 디버깅을 위한 상태 출력
    print('🔍 [BUILD] _canProceed: $_canProceed');
    print('🔍 [BUILD] _agreeService: $_agreeService');
    print('🔍 [BUILD] _agreePrivacy: $_agreePrivacy');
    print('🔍 [BUILD] _isLoading: $_isLoading');

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "이용약관",
          style: TextStyle(fontSize: Sizes.size20, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => _onPressIconButton(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.size20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전체 동의
            Row(
              children: [
                CircularCheckbox(
                  value: _agreeAll,
                  onChanged: _onAgreeAllChanged,
                ),
                Gaps.h12,
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onAgreeAllChanged(!_agreeAll),
                    child: const Text(
                      "전체 동의",
                      style: TextStyle(
                        fontSize: Sizes.size18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Gaps.v10,

            // 구분선
            const Divider(),
            Gaps.v10,

            // 서비스 이용약관 동의 (필수)
            Row(
              children: [
                CircularCheckbox(
                  value: _agreeService,
                  onChanged: (value) {
                    setState(() {
                      _agreeService = value;
                    });
                    _onIndividualChanged();
                  },
                ),
                Gaps.h12,
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeService = !_agreeService;
                      });
                      _onIndividualChanged();
                    },
                    child: const Text(
                      "(필수) 서비스 이용약관 동의",
                      style: TextStyle(
                        color: Color(0xff463e8d),
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff868e96),
                  ),
                  onPressed: () {
                    // 약관 상세보기 기능
                  },
                  child: const Text(
                    "보기",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            Gaps.v10,

            // 개인정보 수집 동의 (필수)
            Row(
              children: [
                CircularCheckbox(
                  value: _agreePrivacy,
                  onChanged: (value) {
                    setState(() {
                      _agreePrivacy = value;
                    });
                    _onIndividualChanged();
                  },
                ),
                Gaps.h12,
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreePrivacy = !_agreePrivacy;
                      });
                      _onIndividualChanged();
                    },
                    child: const Text(
                      "(필수) 개인정보 수집 및 이용 동의",
                      style: TextStyle(
                        color: Color(0xff463e8d),
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff868e96),
                  ),
                  onPressed: () {
                    // 약관 상세보기 기능
                  },
                  child: const Text(
                    "보기",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            Gaps.v10,

            // 마케팅 동의 (선택)
            Row(
              children: [
                CircularCheckbox(
                  value: _agreeMarketing,
                  onChanged: (value) {
                    setState(() {
                      _agreeMarketing = value;
                    });
                    _onIndividualChanged();
                  },
                ),
                Gaps.h12,
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeMarketing = !_agreeMarketing;
                      });
                      _onIndividualChanged();
                    },
                    child: const Text(
                      "(선택) 광고 및 마케팅 활용 동의",
                      style: TextStyle(
                        color: Color(0xff463e8d),
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff868e96),
                  ),
                  onPressed: () {
                    // 약관 상세보기 기능
                  },
                  child: const Text(
                    "보기",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: _canProceed ? const Color(0xff9e9ef4) : Colors.grey,
        child: GestureDetector(
          onTap: () {
            print('🔍 GestureDetector onTap 호출됨');
            print('🔍 _canProceed: $_canProceed');
            print('🔍 _isLoading: $_isLoading');

            if (_canProceed && !_isLoading) {
              print('🔍 조건 통과 - _confirmTerms 호출');
              _confirmTerms();
            } else {
              print('❌ 조건 실패');
              print('   - _canProceed: $_canProceed');
              print('   - _isLoading: $_isLoading');
            }
          },
          child: Container(
            width: double.infinity,
            height: 60,
            color: Colors.transparent, // 터치 영역 확인을 위해 투명색 추가
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Text(
                    "다음",
                    style: TextStyle(
                      color: _canProceed ? Colors.white : Colors.white70,
                      fontSize: Sizes.size24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
