// lib/features/main/home_screen.dart

import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/main/models/message_model.dart';
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:celeb_voice/features/main/widgets/celeb_message_card.dart';
import 'package:celeb_voice/features/main/widgets/create_new_message_card.dart';
import 'package:flutter/material.dart';

import 'widgets/celeb_card_widget.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "home";
  static const String routePath = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? selectedIndex;

  void _onTapAddMessage() {
    print("응생성");
  }

  void _onTapCelebMessage() {
    print("응 메세지");
  }

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
            // 셀럽 카드 목록 전체 화면 높이 78%
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
                      Icon(
                        Icons.info,
                        color: Color(0xff9e9ef4).withOpacity(0.64),
                      ),
                    ],
                  ),
                  Gaps.v10,
                  SizedBox(
                    height: screenHeight * 0.18,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          celebMessageModel.length +
                          1, // 예시: 1개(추가카드) + 10개(메시지카드)
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // 첫 번째 카드: "나만의 메시지를 만들어보세요"
                          return GestureDetector(
                            onTap: _onTapAddMessage,
                            child: CreateNewMessageCard(
                              screenHeight: screenHeight,
                              screenWidth: screenWidth,
                            ),
                          );
                        } else {
                          // 나머지 카드: 기존 메시지 카드
                          return GestureDetector(
                            onTap: _onTapCelebMessage,
                            child: CelebMessageCard(
                              index: index,
                              screenHeight: screenHeight,
                              screenWidth: screenWidth,
                              celebMessageModel: celebMessageModel,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Who's Next",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Gaps.v10,
                  SizedBox(
                    height: screenHeight * 0.18,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: celebs.length,
                      itemBuilder: (context, index) {
                        final celeb = celebs[index];
                        final isSelected = selectedIndex == index;
                        return Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = isSelected ? null : index;
                                  });
                                },
                                child: Container(
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
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        isSelected
                                            ? Colors.black
                                            : Color(0xff9e9ef4).withOpacity(1),
                                        BlendMode.srcATop,
                                      ),
                                      child: Image.asset(
                                        celeb.imagePath,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
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
                ],
              ),
            ),
            Container(height: 500, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
