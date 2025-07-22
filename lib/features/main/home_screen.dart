// lib/features/main/home_screen.dart

import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart'; // 추가
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:celeb_voice/features/subscription/services/subscription_service.dart';
import 'package:celeb_voice/features/user_profile/repos/user_profile_repo.dart'; // 추가
import 'package:celeb_voice/services/instagram_service.dart'; // 이 줄 추가
import 'package:celeb_voice/services/youtube_service.dart'; // import 추가
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 추가
import 'package:go_router/go_router.dart';
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

  // 구독 상태 관리
  bool _hasSubscription = false;
  bool _isLoadingSubscription = false;
  List<String> _subscribedCelebIds = []; // 구독한 셀럽 ID 목록 추가

  // AppBar 탭 상태 관리 추가
  int _selectedTabIndex = 0; // 0: 내 셀럽, 1: 모든 셀럽

  // 현재 필터링된 셀럽 목록을 가져오는 getter 추가
  List<CelebModel> get _filteredCelebs {
    if (!_hasSubscription || _selectedTabIndex == 1) {
      // 미구독자이거나 "모든 셀럽" 탭
      return _celebData.celebs;
    } else {
      // "내 셀럽" 탭 - 구독한 셀럽만 필터링
      return _celebData.celebs
          .where((celeb) => _subscribedCelebIds.contains(celeb.id))
          .toList();
    }
  }

  // 현재 선택된 셀럽을 가져오는 getter 추가
  CelebModel? get _currentCeleb {
    final filteredCelebs = _filteredCelebs;
    if (filteredCelebs.isEmpty) return null;

    final currentIndex = _currentCelebIndex.value % filteredCelebs.length;
    return filteredCelebs[currentIndex];
  }

  String _userNickname = "사용자"; // 기본값
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final UserProfileRepo _userProfileRepo; // 추가

  @override
  void initState() {
    super.initState();
    _celebData = CelebData();
    _celebData.loadInitialCelebs();
    _celebData.addListener(() {
      if (mounted) setState(() {});
    });

    // UserProfileRepo 초기화
    final authRepo = AuthenticationRepo();
    _userProfileRepo = UserProfileRepo(authRepo: authRepo);

    _loadSubscriptionStatus();
    _loadUserNickname(); // 사용자 nickname 로드 추가
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
        _subscribedCelebIds =
            subscriptionStatus.subscribedCelebIds; // 구독한 셀럽 ID 목록 저장
        _hasSubscription = subscriptionStatus
            .subscribedCelebIds
            .isNotEmpty; // 배열이 비어있지 않으면 true
        _isLoadingSubscription = false;
      });

      print("📋 구독 상태: ${_hasSubscription ? '구독 중' : '미구독'}");
      print("📋 구독한 셀럽 IDs: $_subscribedCelebIds");
    } catch (e) {
      print("❌ 구독 상태 로드 실패: $e");
      setState(() {
        _hasSubscription = false; // 에러 시 미구독으로 처리
        _subscribedCelebIds = []; // 에러 시 빈 목록으로 초기화
        _isLoadingSubscription = false;
      });
    }
  }

  // 사용자 nickname 로드 메서드 (localStorage 우선, 없으면 API 호출)
  Future<void> _loadUserNickname() async {
    try {
      print('📖 사용자 닉네임 로딩 시작...');

      // 1. 먼저 localStorage에서 확인
      final localNickname = await _secureStorage.read(key: 'user_nickname');
      if (localNickname != null && localNickname.isNotEmpty) {
        setState(() {
          _userNickname = localNickname;
        });
        print('✅ 로컬에서 닉네임 로드 완료: $localNickname');
        return;
      }

      print('⚠️ 로컬에 닉네임이 없음, API에서 가져오는 중...');

      // 2. localStorage에 없으면 profile API로 가져오기
      final userProfile = await _userProfileRepo.getUserProfile();
      if (userProfile != null) {
        final nickname = userProfile['profile']?['nickname'];
        if (nickname != null && nickname.isNotEmpty) {
          setState(() {
            _userNickname = nickname;
          });

          // API에서 가져온 닉네임을 localStorage에 저장 (캐싱)
          await _secureStorage.write(key: 'user_nickname', value: nickname);
          print('✅ API에서 닉네임 로드 및 로컬 저장 완료: $nickname');
          return;
        }
      }

      print('⚠️ 닉네임을 가져올 수 없어 기본값 사용: $_userNickname');
    } catch (e) {
      print('❌ 닉네임 로드 실패: $e');
      // 에러 발생시 기본값 유지
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
      appBar: _buildAppBar(), // AppBar를 조건부로 생성
      body: RefreshIndicator(
        onRefresh: () async {
          await _celebData.refreshCelebs();
          await _loadSubscriptionStatus();
        },
        color: Color(0xff9e9ef4),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
                  celebs: _filteredCelebs, // 필터링된 셀럽 목록 전달
                  pageViewHeightFactor: 0.5,
                  onPageChanged: (index) {
                    _currentCelebIndex.value = index % _filteredCelebs.length;
                  },
                )
              else
                Column(
                  children: [
                    Text('연예인 정보를 불러올 수 없습니다.', style: TextStyle(fontSize: 16)),
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

  // 구독 상태에 따른 AppBar 생성
  PreferredSizeWidget _buildAppBar() {
    if (_hasSubscription) {
      // 구독자용 AppBar
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffEFF0F4),
        centerTitle: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/header_logo.png',
              height: 32,
              width: 180,
              fit: BoxFit.contain,
            ),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ), // 두 버튼 패딩 동일
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0
                            ? Color(0xff9e9ef4)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20), // 외부보다 약간 작게
                      ),
                      child: Text(
                        '내 셀럽',
                        style: TextStyle(
                          color: _selectedTabIndex == 0
                              ? Colors.white
                              : Color(0xff868E96),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ), // 동일한 패딩
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1
                            ? Color(0xff9e9ef4)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20), // 동일한 테두리
                      ),
                      child: Text(
                        '모든 셀럽',
                        style: TextStyle(
                          color: _selectedTabIndex == 1
                              ? Colors.white
                              : Color(0xff868E96),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
    } else {
      // 미구독자용 AppBar (변경 없음)
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffEFF0F4),
        centerTitle: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/header_logo.png',
              height: 32,
              width: 180,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMessageBanner(double screenWidth, double screenHeight) {
    // 현재 선택된 셀럽들 (예시로 2명 고정)
    final currentCelebs = _celebData.celebs.take(2).toList();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.size20,
        vertical: Sizes.size10,
      ),
      margin: EdgeInsets.symmetric(horizontal: Sizes.size20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Sizes.size16),
      ),
      child: Column(
        children: [
          if (currentCelebs.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    AppConfig.getImageUrl(currentCelebs[0].imagePath),
                  ),
                  radius: 18,
                ),
                Gaps.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentCelebs[0].name,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: Sizes.size15,
                        ),
                      ),
                      Text(
                        '${_getNickName(_userNickname)} 어제 하루 잘 보냈어?', // 동적 닉네임 사용
                        style: TextStyle(
                          color: Color(0xff868e96),
                          fontSize: Sizes.size14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (currentCelebs.length > 1) ...[
            Gaps.v12,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    AppConfig.getImageUrl(currentCelebs[1].imagePath),
                  ),
                  radius: 18,
                ),
                Gaps.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentCelebs[1].name,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: Sizes.size15,
                        ),
                      ),
                      Text(
                        '${_getNickName(_userNickname)} 오늘도 좋은 하루 보내자!', // 동적 닉네임 사용
                        style: TextStyle(
                          color: Color(0xff868e96),
                          fontSize: Sizes.size14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          Gaps.v12,
          Container(
            alignment: Alignment.center,
            width: screenWidth * 0.8,
            height: screenHeight * 0.05,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Sizes.size4),
              border: Border.all(color: Color(0xffc3c7cb)),
            ),
            child: Text(
              '지금 들으러 가기',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: Sizes.size14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Gaps.v12,
        ],
      ),
    );
  }

  // 이미지 타입에 따라 적절한 ImageProvider 반환하는 헬퍼 메서드 추가
  String _getNickName(String name) {
    int lastCharCode = name.runes.last;

    // 한글 음절의 유니코드 범위 (가 ~ 힣)를 벗어나면 처리하지 않습니다.
    if (lastCharCode < 0xAC00 || lastCharCode > 0xD7A3) {
      return name;
    }

    // 받침이 있는지 계산합니다.
    bool hasJongseong = (lastCharCode - 0xAC00) % 28 != 0;

    if (hasJongseong) {
      return '$name아'; // 받침이 있으면 '아'를 붙입니다.
    } else {
      return '$name야'; // 받침이 없으면 '야'를 붙입니다.
    }
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
              Gaps.v8,
            ],
          ),
        ),
        _buildMessageBanner(screenWidth, screenHeight),
        Gaps.v20,
        // 데일리 메시지 구독하기
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
        GestureDetector(
          onTap: () {
            final currentCeleb = _currentCeleb;
            if (currentCeleb != null) {
              context.push('/generateMessage', extra: currentCeleb);
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('셀럽 정보를 불러올 수 없습니다.')));
            }
          },
          child: MainEventWidget(
            screenWidth: screenWidth,
            title: '나만의 메시지 만들기',
            description: '특별하게 듣고 싶은 메시지가 있나요?',
            icon: Icons.add,
          ),
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
              GestureDetector(
                onTap: () {
                  final currentCeleb = _currentCeleb;
                  if (currentCeleb != null) {
                    context.push('/previewTts', extra: currentCeleb);
                  }
                },
                child: Column(
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
              ),
              Gaps.h24,
              GestureDetector(
                onTap: () {
                  final currentCeleb = _currentCeleb;
                  if (currentCeleb != null) {
                    context.push('/generateMessage', extra: currentCeleb);
                  }
                },
                child: Column(
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instagram',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Gaps.v12,
              _buildInstagramImages(screenWidth),
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
        Gaps.v16,
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
                                maxLines: 1, // 2에서 1로 변경
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

  // Instagram 이미지 표시 메서드
  Widget _buildInstagramImages(double screenWidth) {
    if (_celebData.celebs.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(child: Text('이미지를 불러오는 중...')),
      );
    }

    return ValueListenableBuilder<int>(
      valueListenable: _currentCelebIndex,
      builder: (context, currentIndex, child) {
        final currentCeleb = _celebData.celebs[currentIndex];

        return FutureBuilder<List<InstagramImage>>(
          future: InstagramService.getCelebInstagramImages(currentCeleb.name),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 120,
                child: Center(child: Text('이미지를 불러올 수 없습니다.')),
              );
            }

            final images = snapshot.data!;
            final imageSize =
                (screenWidth - 64) / 3; // Container padding(32) + 이미지 간격(32) 고려

            return Row(
              mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
              children: images.take(3).map((image) {
                // 최대 3개만 표시
                final index = images.indexOf(image);
                return Container(
                  width: imageSize,
                  height: imageSize,
                  margin: EdgeInsets.only(
                    right: index == 2 ? 0 : 16, // 마지막 이미지는 오른쪽 여백 없음
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      image.imageUrl,
                      fit: BoxFit.cover, // cover로 변경해서 정사각형으로 채우기
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class MainEventWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double screenWidth;

  const MainEventWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Sizes.size16),
      ),
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
              Gaps.v4,
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Color(0xff868e96)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
