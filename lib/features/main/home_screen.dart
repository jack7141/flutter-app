// lib/features/main/home_screen.dart

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
            Container(height: 500, color: Colors.green),
            Container(height: 500, color: Colors.yellow),
            Container(height: 500, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
