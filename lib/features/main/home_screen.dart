// lib/features/main/home_screen.dart

import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:flutter/material.dart';

import '../../../config/app_config.dart';
import 'widgets/celeb_card_widget.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CelebData _celebData;
  final ValueNotifier<int> _currentCelebIndex = ValueNotifier<int>(
    0,
  ); // 현재 페이지 인덱스 추적

  @override
  void initState() {
    super.initState();
    _celebData = CelebData();
    // loadCelebs() 줄 제거
  }

  @override
  void dispose() {
    _currentCelebIndex.dispose();
    _celebData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(AppConfig.backgroundColorValue),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffeff0f4),
        centerTitle: false,
        title: Image.asset(
          'assets/images/header_logo.png',
          height: 32,
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _celebData.refreshCelebs(),
        color: Color(0xff9e9ef4),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // pull-to-refresh가 작동하도록
          child: Column(
            children: [
              // 셀럽 카드 목록 전체 화면 높이 78%
              if (_celebData.isLoading)
                SizedBox(
                  height: screenHeight * 0.5,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_celebData.celebs.isNotEmpty)
                CelebCard(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  celebs: _celebData.celebs,
                  pageViewHeightFactor: 0.5,
                  onPageChanged: (index) {
                    _currentCelebIndex.value =
                        index % _celebData.celebs.length; // 페이지 변경 시 인덱스 업데이트
                  },
                )
              else
                Center(
                  child: Text(
                    '연예인 정보를 불러올 수 없습니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              // 데일리 메세지
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '데일리 메세지',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.v16,
                    if (_celebData.celebs.isNotEmpty)
                      ValueListenableBuilder<int>(
                        valueListenable: _currentCelebIndex,
                        builder: (context, currentIndex, child) {
                          return _buildMessageBanner(
                            currentIndex,
                            '민지야 어제 하루 잘 보냈어?',
                          );
                        },
                      ),
                  ],
                ),
              ),
              // 데일리 메시지 구독하기
              MainEventWidget(
                title: '데일리 메시지 구독하기',
                description: '오직 나만을 위한 셀럽의 이야기',
                icon: Icons.favorite_border,
              ),
              Gaps.v16,
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나만의 메시지',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // 나만의 메시지 만들기
              MainEventWidget(
                title: '나만의 메시지 만들기',
                description: '셀럽에게 듣고 싶은 말이 있나요?',
                icon: Icons.add,
              ),
              Gaps.v16,
              // 친구에게 메시지 보내기
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '친구에게 메시지 보내기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.v16,
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.05,
                      ),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/present_icon.png',
                              fit: BoxFit.contain,
                              height: 32,
                              width: 32,
                            ),
                          ),
                          Gaps.v16,
                          Text(
                            '친구에게 셀럽의 목소리로\n특별한 메시지를 선물해보세요!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff868e96),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBanner(int celebIndex, String message) {
    return Container(
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
                  _celebData.celebs[celebIndex].name,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: Sizes.size15,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.black, fontSize: Sizes.size14),
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
    );
  }
}

class MainEventWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const MainEventWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xff9e9ef4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 25),
          ),
          Gaps.h16,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff211772),
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Color(0xff868e96)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
