// lib/features/main/home_screen.dart

import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "home";
  static const String routePath = "/home";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                height: 1000, // 빨간색(500) + 파란색(500)
                child: PageView.builder(
                  controller: PageController(
                    viewportFraction: 0.85,
                    initialPage: 10000, // 큰 숫자로 시작해서 양방향 무한 스크롤
                  ),
                  itemBuilder: (context, index) {
                    final celebIndex = index % celebs.length; // 실제 데이터 인덱스
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          // 빨간색 카드
                          Container(
                            height: 500,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '빨간 카드 $celebIndex',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // 파란색 카드 (연동)
                          Container(
                            height: 500,
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
