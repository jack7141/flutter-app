// lib/features/main/home_screen.dart

import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "home";
  static const String routePath = "/home";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    List<CelebModel> celebs = CelebData.getCelebs();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: false,
        title: Image.asset(
          'assets/images/header_logo.png',
          height: 32,
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 카드 목록
            Container(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: SizedBox(
                height: screenHeight * 0.78, // 전체화면에서 78% 높이
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
                                Align(
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white,
                                          Colors.white,
                                          Colors.transparent,
                                        ],
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
                                ),
                                // 이름과 태그
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 100,
                                      left: Sizes.size20,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Column이 필요한 만큼만 공간 차지
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start, // 왼쪽 정렬
                                      children: [
                                        Text(
                                          celebs[celebIndex].name,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Gaps.v8,
                                        Text(
                                          celebs[celebIndex].tags.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                            height: screenHeight * 0.2,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '파란 카드 $celebIndex',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(height: 500, color: Colors.green),
            Container(height: 500, color: Colors.yellow),
            Container(height: 500, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
