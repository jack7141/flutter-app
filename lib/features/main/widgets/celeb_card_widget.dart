import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/subscription/services/subscription_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

// StatelessWidget에서 StatefulWidget으로 변경
class CelebCard extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final List<CelebModel> celebs;
  final double pageViewHeightFactor;
  final Function(int)? onPageChanged;

  const CelebCard({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.celebs,
    required this.pageViewHeightFactor,
    this.onPageChanged,
  });

  @override
  State<CelebCard> createState() => _CelebCardState();
}

class _CelebCardState extends State<CelebCard> {
  // 구독 상태를 추적하기 위한 Set
  Set<String> _subscribedCelebIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  // 구독 상태 로드
  Future<void> _loadSubscriptionStatus() async {
    try {
      final subscriptionService = SubscriptionService();
      final subscriptionStatus = await subscriptionService
          .getSubscriptionStatus();

      if (mounted) {
        setState(() {
          _subscribedCelebIds = subscriptionStatus.subscribedCelebIds.toSet();
        });
      }
    } catch (e) {
      print("❌ 구독 상태 로드 실패: $e");
    }
  }

  void _onTapCelebCard(int celebIndex, BuildContext context) async {
    final selectedCeleb = widget.celebs[celebIndex];
    print("🔍 셀럽 카드 클릭: ${selectedCeleb.name}");
    print("🔍 클릭한 셀럽 ID: ${selectedCeleb.id}");

    // 혹시 떠있는 로딩 다이얼로그 강제로 닫기
    try {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        print("🚪 기존 다이얼로그 닫기");
      }
    } catch (e) {
      print("⚠️ 다이얼로그 닫기 실패: $e");
    }

    try {
      final isSubscribed = _subscribedCelebIds.contains(selectedCeleb.id);
      print("✅ 구독 여부: $isSubscribed");

      if (isSubscribed) {
        // 이미 구독된 경우 → TTS로 이동
        print("✅ 이미 ${selectedCeleb.name} 구독자 → TTS로 이동");

        if (context.mounted) {
          context.go('/previewTts', extra: selectedCeleb);
        }
      } else {
        // 미구독 상태 → is_onboarded 상태 확인
        print("📝 미구독 셀럽 - 온보딩 상태 확인: ${selectedCeleb.name}");

        // 사용자 프로필에서 is_onboarded 상태 확인
        final isOnboarded = await _checkOnboardingStatus();

        if (isOnboarded) {
          // 온보딩 완료된 사용자 - 바로 구독 처리
          print("✅ 온보딩 완료 사용자 - 바로 구독 처리");
          await _subscribeDirectly(selectedCeleb, context);
        } else {
          // 온보딩 미완료 사용자 - 온보딩 시작
          print("📝 온보딩 미완료 사용자 - 온보딩 시작");
          if (context.mounted) {
            context.go('/welcome', extra: selectedCeleb);
          }
        }
      }
    } catch (e) {
      print("❌ 구독 상태 확인 실패: $e");
      if (context.mounted) {
        // 에러 시에도 온보딩으로 이동 (셀럽 정보 전달)
        context.go('/welcome', extra: selectedCeleb);
      }
    }
  }

  // 온보딩 상태 확인 메서드
  Future<bool> _checkOnboardingStatus() async {
    try {
      const storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');

      if (accessToken == null) {
        print('❌ 액세스 토큰 없음');
        return false;
      }

      print('🔍 사용자 프로필 조회 시작: /api/v1/users/me/');

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final response = await dio.get('/api/v1/users/me/');

      print('📥 사용자 프로필 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userData = response.data;
        final isOnboarded = userData['profile']?['isOnboarded'] ?? false;

        print('📋 사용자 온보딩 상태: $isOnboarded');
        print('📋 전체 사용자 데이터: $userData');

        return isOnboarded == true;
      } else {
        print('❌ 사용자 데이터 조회 실패');
        return false;
      }
    } catch (e) {
      print('💥 온보딩 상태 확인 에러: $e');
      if (e is DioException) {
        print('💥 DioException 상세:');
        print('   - 상태코드: ${e.response?.statusCode}');
        print('   - 응답 데이터: ${e.response?.data}');
        print('   - 에러 메시지: ${e.message}');
      }
      return false;
    }
  }

  // 직접 구독 처리 메서드 수정
  Future<void> _subscribeDirectly(
    CelebModel celeb,
    BuildContext context,
  ) async {
    print('🚀 직접 구독 처리 시작: ${celeb.name}');

    setState(() {
      _isLoading = true;
    });

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      const storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');
      final tokenType = await storage.read(key: 'token_type');

      if (accessToken == null) {
        throw Exception('액세스 토큰이 없습니다.');
      }

      print('📤 구독 API 호출: /api/v1/celeb/${celeb.id}/subscribe');

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await dio.post(
        '/api/v1/celeb/${celeb.id}/subscribe',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
          },
        ),
      );

      print('📥 구독 API 응답: ${response.statusCode}');
      print('📋 구독 API 응답 데이터: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 구독 성공: ${celeb.name}');

        // 구독 상태 업데이트
        if (mounted) {
          setState(() {
            _subscribedCelebIds.add(celeb.id);
            _isLoading = false;
          });
        }

        print('🔄 구독 완료 - UI 상태 업데이트 완료');
      } else {
        throw Exception('구독 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 구독 처리 에러: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // 에러 메시지 표시 (다이얼로그 닫은 후)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구독 처리 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // finally 블록에서 반드시 다이얼로그 닫기
      print('🚪 다이얼로그 닫기 시도...');

      if (context.mounted) {
        try {
          // 모든 다이얼로그 강제로 닫기
          Navigator.of(context, rootNavigator: true).pop();
          print('🚪 다이얼로그 닫기 성공');
        } catch (e) {
          print('💥 다이얼로그 닫기 실패: $e');

          // 다른 방법으로 시도
          try {
            Navigator.of(context).pop();
            print('🚪 대체 방법으로 다이얼로그 닫기 성공');
          } catch (e2) {
            print('💥 대체 방법도 실패: $e2');
          }
        }
      }

      // 성공 메시지는 다이얼로그 닫은 후에 표시
      if (context.mounted && _subscribedCelebIds.contains(celeb.id)) {
        await Future.delayed(const Duration(milliseconds: 200));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${celeb.name} 구독이 완료되었습니다!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: widget.screenHeight * widget.pageViewHeightFactor,
        child: PageView.builder(
          controller: PageController(
            viewportFraction: 0.85,
            initialPage: 10000,
          ),
          onPageChanged: widget.onPageChanged,
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            final celebIndex = index % widget.celebs.length;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    clipBehavior: Clip.none,
                    height: widget.screenHeight * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildCelebImage(celebIndex),
                        _buildCelebInfo(celebIndex),
                        GestureDetector(
                          onTap: () => _onTapCelebCard(celebIndex, context),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size20,
                                vertical: 20,
                              ),
                              child: _buildSubscriptionButton(celebIndex),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 구독 버튼 빌드 (상태에 따라 다른 텍스트 표시)
  Widget _buildSubscriptionButton(int celebIndex) {
    final celebId = widget.celebs[celebIndex].id;
    final isSubscribed = _subscribedCelebIds.contains(celebId);

    if (_isLoading) {
      return FormButton(text: '처리 중...');
    }

    return FormButton(text: isSubscribed ? '메세지 들으러가기' : '구독하기');
  }

  Widget _buildMessageBanner(int celebIndex, String message) {
    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Sizes.size18,
          vertical: Sizes.size10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Sizes.size16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/message/message_logo.png',
              fit: BoxFit.contain,
              height: 36,
              width: 36,
            ),
            Gaps.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.celebs[celebIndex].name,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: Sizes.size15,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: Sizes.size14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '2시간전',
                  style: TextStyle(
                    color: Color(0xff4968a1),
                    fontSize: Sizes.size11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebInfo(int celebIndex) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 100, left: Sizes.size20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.celebs[celebIndex].name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Gaps.v8,
            Container(
              child: Wrap(
                spacing: 10,
                runSpacing: 4,
                children: widget.celebs[celebIndex].tags
                    .map(
                      (tag) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xff0e0e0e),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff0e0e0e),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebImage(int celebIndex) {
    return Align(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.transparent],
            stops: [0.0, 0.65, 0.95],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Transform.translate(
          offset: Offset(0, -30),
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 1,
            child: Image.network(
              AppConfig.getImageUrl(widget.celebs[celebIndex].imagePath),
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              errorBuilder: (context, error, stackTrace) {
                print("🖼️ 이미지 로딩 에러: $error");
                return _buildFallbackImage(celebIndex);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage(int celebIndex) {
    String assetPath = 'assets/images/celebs/card.png';

    switch (widget.celebs[celebIndex].name) {
      case '아이유':
        assetPath = 'assets/images/celebs/IU.png';
        break;
      case '이연복':
        assetPath = 'assets/images/celebs/card.png';
        break;
      case '차은우':
        assetPath = 'assets/images/celebs/card2.png';
        break;
      default:
        assetPath = 'assets/images/celebs/card.png';
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 80, color: Colors.grey[600]),
              SizedBox(height: 8),
              Text(
                widget.celebs[celebIndex].name,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
