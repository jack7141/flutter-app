import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';

class CelebCard extends StatelessWidget {
  const CelebCard({
    super.key,
    required this.screenHeight,
    required this.celebs,
    this.pageViewHeightFactor = 0.78,
  });

  final double screenHeight;
  final List<CelebModel> celebs;
  final double pageViewHeightFactor;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: SizedBox(
        height: screenHeight * pageViewHeightFactor, // 전체화면에서 78% 높이
        child: PageView.builder(
          controller: PageController(
            viewportFraction: 0.85,
            initialPage: 10000, // 큰 숫자로 시작해서 양방향 무한 스크롤
          ),
          clipBehavior: Clip.none, // ← 이거 추가해보세요!
          itemBuilder: (context, index) {
            final celebIndex = index % celebs.length; // 실제 데이터 인덱스
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  // 빨간색 카드
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
                          onTap: () {},
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size20,
                                vertical: 20,
                              ),
                              child: FormButton(text: '구독하기'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 파란색 카드 (연동)
                  Gaps.v24,
                  Container(
                    width: screenWidth * 0.8,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 199, 199, 246),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size16,
                        vertical: Sizes.size20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${celebs[celebIndex].name}님에게서 메세지가 도착했어요.',
                            style: TextStyle(
                              color: Color(0xff211772),
                              fontWeight: FontWeight.w400,
                              fontSize: Sizes.size16,
                            ),
                          ),
                          Gaps.v8,
                          _buildMessageBanner(celebIndex, '민지야 어제 하루 잘 보냈어?'),
                          Gaps.v10,
                          _buildMessageBanner(celebIndex, '오늘은 뭐해? 보고싶다.'),
                        ],
                      ),
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
            Text(
              celebs[celebIndex].description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            child: Image.asset(
              celebs[celebIndex].imagePath,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}
