import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/subscription/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CelebCard extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final List<CelebModel> celebs;
  final double pageViewHeightFactor;
  final Function(int)? onPageChanged; // 페이지 변경 콜백 추가

  const CelebCard({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.celebs,
    required this.pageViewHeightFactor,
    this.onPageChanged, // 선택적 매개변수
  });

  void _onTapCelebCard(int celebIndex, BuildContext context) async {
    final selectedCeleb = celebs[celebIndex];
    print("🔍 셀럽 카드 클릭: ${selectedCeleb.name}");

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
      final subscriptionService = SubscriptionService();
      final subscriptionStatus = await subscriptionService
          .getSubscriptionStatus();
      final isSubscribed = subscriptionStatus.subscribedCelebIds.contains(
        selectedCeleb.id,
      );

      if (isSubscribed) {
        // 이미 구독된 경우 → TTS로 이동
        print("✅ 이미 ${selectedCeleb.name} 구독자 → TTS로 이동");

        if (context.mounted) {
          context.push('/previewTts', extra: selectedCeleb);
        }
      } else {
        // 미구독 상태 → 구독 API 호출하지 않고 바로 온보딩으로
        print("📝 미구독 셀럽 - 온보딩 시작: ${selectedCeleb.name}");
        if (context.mounted) {
          // 구독 API 호출 부분 제거하고 바로 온보딩으로 이동
          context.push('/welcome', extra: selectedCeleb);
        }
      }
    } catch (e) {
      print("❌ 구독 상태 확인 실패: $e");
      if (context.mounted) {
        // 에러 시에도 온보딩으로 이동 (셀럽 정보 전달)
        context.push('/welcome', extra: selectedCeleb);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: screenHeight * pageViewHeightFactor, // 전체화면에서 78% 높이
        child: PageView.builder(
          controller: PageController(
            viewportFraction: 0.85,
            initialPage: 10000, // 큰 숫자로 시작해서 양방향 무한 스크롤
          ),
          onPageChanged: onPageChanged, // 페이지 변경 콜백 연결
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            final celebIndex = index % celebs.length; // 실제 데이터 인덱스
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  // 셀럽 카드 박스
                  Container(
                    clipBehavior: Clip.none,
                    height: screenHeight * 0.5,
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
                        // 이미지
                        _buildCelebImage(celebIndex),
                        // 이름과 태그
                        _buildCelebInfo(celebIndex),
                        // 구독하기 버튼
                        GestureDetector(
                          onTap: () => _onTapCelebCard(celebIndex, context),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size20,
                                vertical: 20,
                              ),
                              child: FutureBuilder<bool>(
                                future: _checkSubscriptionStatus(
                                  celebs[celebIndex].id,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return FormButton(text: '확인 중...');
                                  }

                                  final isSubscribed = snapshot.data ?? false;
                                  return FormButton(
                                    text: isSubscribed ? '메세지 들으러가기' : '구독하기',
                                  );
                                },
                              ),
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
                    celebs[celebIndex].name,
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
          mainAxisSize: MainAxisSize.min, // Column이 필요한 만큼만 공간 차지
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Text(
              celebs[celebIndex].name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Gaps.v8,
            Container(
              child: Wrap(
                spacing: 10,
                runSpacing: 4,
                children: celebs[celebIndex].tags
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
              AppConfig.getImageUrl(celebs[celebIndex].imagePath),
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

  // 폴백 이미지 위젯
  Widget _buildFallbackImage(int celebIndex) {
    // 연예인 이름에 따라 기본 asset 이미지 매핑
    String assetPath = 'assets/images/celebs/card.png'; // 기본값

    switch (celebs[celebIndex].name) {
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
        // asset도 실패하면 기본 아이콘
        return Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 80, color: Colors.grey[600]),
              SizedBox(height: 8),
              Text(
                celebs[celebIndex].name,
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

  Future<bool> _checkSubscriptionStatus(String celebId) async {
    try {
      final subscriptionService = SubscriptionService();
      final subscriptionStatus = await subscriptionService
          .getSubscriptionStatus();

      print("🔍 구독 상태 확인 - 셀럽 ID: $celebId");
      print("📋 구독한 셀럽들: ${subscriptionStatus.subscribedCelebIds}");
      print(
        "✅ 구독 여부: ${subscriptionStatus.subscribedCelebIds.contains(celebId)}",
      );

      return subscriptionStatus.subscribedCelebIds.contains(celebId);
    } catch (e) {
      print("❌ 구독 상태 확인 실패: $e");
      return false;
    }
  }
}
