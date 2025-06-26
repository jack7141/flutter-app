// lib/features/main/home_screen.dart

import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:flutter/material.dart';

import 'widgets/celeb_card_widget.dart';

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
            // 카드 목록 전체 화면 높이 78%
            CelebCard(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              celebs: celebs,
              pageViewHeightFactor: 0.78,
            ),
            // 나만의 메시지 배너 카드 박스
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '나만의 메시지',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.info, color: Color(0xff9e9ef4)),
                    ],
                  ),
                  Gaps.v10,
                  SizedBox(
                    height: screenHeight * 0.18,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 11, // 예시: 1개(추가카드) + 10개(메시지카드)
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // 첫 번째 카드: "나만의 메시지를 만들어보세요"
                          return Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  height: screenHeight * 0.17,
                                  width: screenWidth * 0.3,
                                  decoration: BoxDecoration(
                                    color: Color(0xff9e9ef4),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 18,
                                              child: Icon(
                                                Icons.add,
                                                color: Color(
                                                  0xff9e9ef4,
                                                ), // 아이콘 색상
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            children: [
                                              Text(
                                                '나만의 메시지를\n만들어보세요',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: Sizes.size14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff211772),
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // 나머지 카드: 기존 메시지 카드
                          return Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  height: screenHeight * 0.17,
                                  width: screenWidth * 0.3,
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
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundImage: AssetImage(
                                                "assets/images/celebs/IU.png",
                                              ),
                                            ),
                                            Gaps.h8,
                                            Text(
                                              'IU',
                                              style: TextStyle(
                                                fontSize: Sizes.size14,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                            children: [
                                              Text(
                                                '헤어지자고?\n너 누군데?',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: Sizes.size14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 500, color: Colors.yellow),
            Container(height: 500, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
