import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/widgets/circular_checkbox.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  bool _isLoading = false; // API 호출 로딩 상태 추가

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    // Dio 직접 초기화
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 토큰 자동 추가 인터셉터
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔑 토큰 추가됨: Bearer ${token.substring(0, 10)}...');
          }
          handler.next(options);
        },
      ),
    );
  }

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
  }

  void _onPressIconButton() {
    Navigator.of(context).pop();
  }

  // 다음 버튼 활성화 조건 (필수 항목만 체크되면 됨)
  bool get _canProceed => _agreeService && _agreePrivacy;

  // 약관 동의 API 호출 메서드 추가
  Future<void> _confirmTerms() async {
    print('🚀 약관 동의 API 호출 시작');

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await _storage.read(key: 'user_id');

      if (userId == null || userId.isEmpty) {
        throw Exception('사용자 ID를 찾을 수 없습니다.');
      }

      print('📤 요청 URL: /api/v1/users/$userId/');
      print('📤 요청 데이터: {"is_confirm": true}');

      final response = await _dio.patch(
        '/api/v1/users/$userId/',
        data: {'is_confirm': true},
      );

      print('✅ 약관 동의 API 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('🎉 약관 동의 성공!');

        if (mounted) {
          // 약관 동의 완료 후 홈 화면으로 이동
          context.go('/home');
        }
      } else {
        throw Exception('약관 동의 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 약관 동의 처리 에러: $e');

      if (e is DioException) {
        // 이미 동의 완료된 경우
        if (e.response?.statusCode == 409) {
          print('⚠️ 이미 약관 동의 완료된 사용자 - 홈으로 이동');
          if (mounted) {
            context.go('/home');
          }
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('약관 동의 처리 중 오류가 발생했습니다: ${e.toString()}'),
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
          onTap: (_canProceed && !_isLoading)
              ? () {
                  print('🔍 다음 버튼 클릭됨!');
                  _confirmTerms(); // API 호출 추가
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
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
    );
  }
}
