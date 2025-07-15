// lib/features/main/home_screen.dart

import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:celeb_voice/features/subscription/services/subscription_service.dart';
import 'package:celeb_voice/services/youtube_service.dart'; // import 추가
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  final ValueNotifier<int> _currentCelebIndex = ValueNotifier<int>(0);

  // 구독 상태 관리 변수 수정
  bool _hasSubscription = false; // 구독한 셀럽이 있는지 여부
  bool _isLoadingSubscription = false; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _celebData = CelebData();
    _celebData.loadInitialCelebs();
    _celebData.addListener(() {
      if (mounted) setState(() {});
    });
    _loadSubscriptionStatus();
  }

  // 구독 상태 조회 메서드 수정
  Future<void> _loadSubscriptionStatus() async {
    setState(() {
      _isLoadingSubscription = true;
    });

    try {
      final subscriptionService = SubscriptionService();
      final subscriptionStatus = await subscriptionService
          .getSubscriptionStatus();

      setState(() {
        _hasSubscription = subscriptionStatus
            .subscribedCelebIds
            .isNotEmpty; // 배열이 비어있지 않으면 true
        _isLoadingSubscription = false;
      });

      print("📋 구독 상태: ${_hasSubscription ? '구독 중' : '미구독'}");
    } catch (e) {
      print("❌ 구독 상태 로드 실패: $e");
      setState(() {
        _hasSubscription = false; // 에러 시 미구독으로 처리
        _isLoadingSubscription = false;
      });
    }
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
        onRefresh: () async {
          await _celebData.refreshCelebs();
          await _loadSubscriptionStatus(); // 구독 상태도 함께 새로고침
        },
        color: Color(0xff9e9ef4),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // pull-to-refresh가 작동하도록
          child: Column(
            children: [
              // 셀럽 카드 목록 전체 화면 높이 50%
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
                    _currentCelebIndex.value = index % _celebData.celebs.length;
                  },
                )
              else
                Column(
                  children: [
                    Text('연예인 정보를 불러올 수 없습니다.', style: TextStyle(fontSize: 16)),
                    // 디버깅용 정보 추가
                    Text('Loading: ${_celebData.isLoading}'),
                    Text('Celebs count: ${_celebData.celebs.length}'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _celebData.loadInitialCelebs();
                        });
                      },
                      child: Text('다시 시도'),
                    ),
                  ],
                ),
              // 구독 상태에 따른 메뉴 분기
              if (_hasSubscription)
                _buildSubscriberMenu(screenHeight, screenWidth)
              else
                _buildNonSubscriberMenu(screenHeight, screenWidth),
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

  Widget _buildNonSubscriberMenu(double screenHeight, double screenWidth) {
    // 데일리 메세지 - 비구독자만 보이게
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '데일리 메세지',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Gaps.v16,
              Container(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
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
    );
  }

  Widget _buildSubscriberMenu(double screenHeight, double screenWidth) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.8,
          height: screenHeight * 0.1,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Sizes.size16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/daily_message.png',
                    fit: BoxFit.contain,
                    height: 36,
                    width: 36,
                  ),
                  Gaps.v5,
                  Text('데일리 메시지', style: TextStyle(fontSize: 12)),
                ],
              ),
              Gaps.h24,
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/my_message.png',
                    fit: BoxFit.contain,
                    height: 36,
                    width: 36,
                  ),
                  Gaps.v5,
                  Text('나만의 메시지', style: TextStyle(fontSize: 12)),
                ],
              ),
              Gaps.h24,
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/present.png',
                    fit: BoxFit.contain,
                    height: 36,
                    width: 36,
                  ),
                  Gaps.v5,
                  Text('선물하기', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Gaps.v16,
        // YouTube 연동 섹션
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'YouTube',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Gaps.v12,
              // YouTube 썸네일 3개 표시
              _buildYouTubeVideos(screenWidth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYouTubeVideos(double screenWidth) {
    if (_celebData.celebs.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('동영상을 불러오는 중...')),
      );
    }

    return ValueListenableBuilder<int>(
      valueListenable: _currentCelebIndex,
      builder: (context, currentIndex, child) {
        final currentCeleb = _celebData.celebs[currentIndex];

        return FutureBuilder<List<YouTubeVideo>>(
          future: YouTubeService.getCelebVideos(currentCeleb.name),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(child: Text('동영상을 불러올 수 없습니다.')),
              );
            }

            final videos = snapshot.data!;
            // YouTube 비율 (16:9) 적용
            final videoWidth = screenWidth * 0.8;
            final videoHeight = videoWidth * (9 / 16);

            return SizedBox(
              height: videoHeight + 60, // 제목 공간 추가
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == videos.length - 1 ? 0 : 16,
                    ), // 마지막 아이템만 padding 없음
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _playYouTubeVideo(video.videoId),
                          child: Container(
                            width: videoWidth,
                            height: videoHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.network(
                                    video.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    width: videoWidth,
                                    height: videoHeight,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: videoWidth,
                                        height: videoHeight,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: videoWidth,
                                        height: videoHeight,
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          size: 60,
                                        ),
                                      );
                                    },
                                  ),
                                  // 재생 버튼 오버레이
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Gaps.v8,
                        // 동영상 제목
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Builder(
                            builder: (context) {
                              var unescape = HtmlUnescape();
                              final decodedTitle = unescape.convert(
                                video.title,
                              );
                              return Text(
                                decodedTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // YouTube 동영상 재생 메서드
  void _playYouTubeVideo(String videoId) {
    final YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 300,
          child: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            onReady: () {
              print('플레이어 준비됨');
            },
          ),
        ),
      ),
    ).then((_) {
      controller.dispose(); // 다이얼로그 닫힐 때 컨트롤러 해제
    });
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
