import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';
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
  void _onTapCelebCard(int celebIndex, BuildContext context) async {
    final selectedCeleb = widget.celebs[celebIndex];
    print("🔍 셀럽 카드 클릭: ${selectedCeleb.name}");
    print("🔍 클릭한 셀럽 ID: ${selectedCeleb.id}");

    // 바로 TTS로 이동
    if (context.mounted) {
      print("✅ TTS로 이동");
      context.push('/generateMessage', extra: selectedCeleb);
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

  // 구독 버튼 빌드
  Widget _buildSubscriptionButton(int celebIndex) {
    return FormButton(text: '보이스 생성하기');
  }

  Widget _buildCelebInfo(int celebIndex) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 85, left: Sizes.size20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.celebs[celebIndex].name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Gaps.v4,
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
                            color: Color(0xff463E8D),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff463E8D),
                            fontWeight: FontWeight.w600,
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
