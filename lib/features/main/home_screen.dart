// lib/features/main/home_screen.dart

import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart'; // 추가
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:celeb_voice/features/user_profile/repos/user_profile_repo.dart'; // 추가
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 추가

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

    _loadUserNickname(); // 사용자 nickname 로드 추가
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
      appBar: _buildAppBar(), // 간단한 AppBar
      body: RefreshIndicator(
        onRefresh: () async {
          await _celebData.refreshCelebs();
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
                  celebs: _celebData.celebs, // 모든 셀럽 목록 전달
                  pageViewHeightFactor: 0.5,
                  onPageChanged: (index) {
                    _currentCelebIndex.value = index % _celebData.celebs.length;
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
              _buildNonSubscriberMenu(screenHeight, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  // 간단한 AppBar 생성
  PreferredSizeWidget _buildAppBar() {
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
                '이런 보이스는 어때요?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Gaps.v8,
            ],
          ),
        ),
        // TODO: 이런 보이스는 어때요 위젯 필요
        Gaps.v20,
        // TODO: 이런 보이스는 어때요 위젯 필요
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.v16,
              Text(
                "Who's Next?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Gaps.v12,
              SizedBox(
                width: screenWidth * 0.9,
                child: Image.asset(
                  'assets/images/whosnext.png',
                  fit: BoxFit.contain,
                ),
              ),
              Gaps.v12,
            ],
          ),
        ),
      ],
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
