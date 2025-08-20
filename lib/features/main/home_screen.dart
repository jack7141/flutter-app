// lib/features/main/home_screen.dart

import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart'; // 추가
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:celeb_voice/features/user_profile/repos/user_profile_repo.dart'; // 추가
import 'package:dio/dio.dart';
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

  // 샘플 메시지 상태 관리
  List<Map<String, dynamic>> _sampleMessages = [];
  bool _isSampleLoading = true;
  String? _sampleError;

  // 오디오 재생 상태 관리
  final Map<String, bool> _playingStates = {}; // 각 샘플별 재생 상태
  final Map<String, double> _progressStates = {}; // 각 샘플별 진행률

  @override
  void initState() {
    super.initState();
    _celebData = CelebData();
    _celebData.loadInitialCelebs();
    _celebData.addListener(() {
      if (mounted) {
        setState(() {});
        // 셀럽 데이터가 로드되면 샘플 메시지도 로드
        if (_celebData.celebs.isNotEmpty && _sampleMessages.isEmpty) {
          _loadSampleMessages();
        }
      }
    });

    // 셀럽 인덱스 변경 시 샘플 메시지 다시 로드
    _currentCelebIndex.addListener(() {
      if (mounted && _celebData.celebs.isNotEmpty) {
        _loadSampleMessages();
      }
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

  // 샘플 메시지 로드 메서드
  Future<void> _loadSampleMessages() async {
    try {
      setState(() {
        _isSampleLoading = true;
        _sampleError = null;
      });

      // 현재 선택된 셀럽의 ID 가져오기
      if (_celebData.celebs.isEmpty) {
        throw Exception('셀럽 데이터가 없습니다.');
      }

      final currentCelebIndex =
          _currentCelebIndex.value % _celebData.celebs.length;
      final currentCeleb = _celebData.celebs[currentCelebIndex];
      final sampleCelebId = currentCeleb.id;

      print('📤 샘플 메시지 API 호출: /api/v1/celeb/$sampleCelebId/sample');
      print('📋 현재 셀럽: ${currentCeleb.name} ($sampleCelebId)');

      // 토큰 가져오기
      final accessToken = await _secureStorage.read(key: 'access_token');
      final tokenType = await _secureStorage.read(key: 'token_type');

      if (accessToken == null) {
        throw Exception('액세스 토큰이 없습니다.');
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await dio.get(
        '/api/v1/celeb/$sampleCelebId/sample',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
          },
        ),
      );

      print('📥 샘플 메시지 API 응답: ${response.statusCode}');
      print('📋 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> sampleData = response.data;

        if (mounted) {
          setState(() {
            _sampleMessages = sampleData.cast<Map<String, dynamic>>();
            _isSampleLoading = false;
          });
        }

        print('✅ 샘플 메시지 로드 성공: ${_sampleMessages.length}개');
      } else {
        throw Exception('샘플 메시지 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 샘플 메시지 로드 에러: $e');

      if (mounted) {
        setState(() {
          _isSampleLoading = false;
          _sampleError = '샘플 메시지를 불러올 수 없습니다.';
        });
      }
    }
  }

  // 보이스 예시 위젯
  Widget _buildVoiceExamples() {
    // 로딩 상태
    if (_isSampleLoading) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 에러 상태
    if (_sampleError != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Column(
            children: [
              Text(
                _sampleError!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              SizedBox(height: 8),
              TextButton(onPressed: _loadSampleMessages, child: Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    // 데이터가 없는 경우
    if (_sampleMessages.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Text(
            '샘플 메시지가 없습니다.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }

    // 실제 데이터 표시
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _sampleMessages.map((sample) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 부분 (아바타, 셀럽 이름, 날짜)
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipOval(child: _buildCelebAvatar()),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getCurrentCelebName(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // 메시지 부분
                Text(
                  sample['message'] ?? '샘플 메시지',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 16),
                // 프로그레스 바
                _buildProgressBar(sample['id'] ?? ''),
                SizedBox(height: 12),
                // 재생 버튼
                _buildPlayButton(sample['id'] ?? ''),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 날짜 포맷팅 헬퍼 메서드
  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}분 전';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}시간 전';
      } else {
        return '${difference.inDays}일 전';
      }
    } catch (e) {
      return '';
    }
  }

  // 현재 셀럽의 아바타 이미지 빌드
  Widget _buildCelebAvatar() {
    if (_celebData.celebs.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.person, size: 20, color: Colors.grey),
      );
    }

    final currentCelebIndex =
        _currentCelebIndex.value % _celebData.celebs.length;
    final currentCeleb = _celebData.celebs[currentCelebIndex];

    return Image.network(
      AppConfig.getImageUrl(currentCeleb.imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: Icon(Icons.person, size: 20, color: Colors.grey),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
            ),
          ),
        );
      },
    );
  }

  // 현재 셀럽의 이름 가져오기
  String _getCurrentCelebName() {
    if (_celebData.celebs.isEmpty) {
      return '셀럽';
    }

    final currentCelebIndex =
        _currentCelebIndex.value % _celebData.celebs.length;
    final currentCeleb = _celebData.celebs[currentCelebIndex];
    return currentCeleb.name;
  }

  // 프로그레스 바 빌드
  Widget _buildProgressBar(String sampleId) {
    final progress = _progressStates[sampleId] ?? 0.0;

    return Column(
      children: [
        // 프로그레스 바
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9e9ef4)),
          minHeight: 4,
        ),
        SizedBox(height: 4),
      ],
    );
  }

  // 재생 버튼 빌드
  Widget _buildPlayButton(String sampleId) {
    final isPlaying = _playingStates[sampleId] ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 재생/일시정지 버튼
        GestureDetector(
          onTap: () => _togglePlayPause(sampleId),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Color(0xff463E8D),
              size: 24,
            ),
          ),
        ),

        // 오른쪽 버튼들
        Row(
          children: [
            // Export 버튼
            GestureDetector(
              onTap: () => _onExportTap(sampleId),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share,
                  color: Color(0xff9e9ef4),
                  size: Sizes.size20,
                ),
              ),
            ),
            SizedBox(width: 12),
            // 확대 버튼
            GestureDetector(
              onTap: () => _onExpandTap(sampleId),
              child: Container(
                width: Sizes.size32,
                height: Sizes.size32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fullscreen,
                  color: Color(0xff9e9ef4),
                  size: Sizes.size20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 재생/일시정지 토글
  void _togglePlayPause(String sampleId) {
    setState(() {
      final isCurrentlyPlaying = _playingStates[sampleId] ?? false;

      // 다른 모든 재생 중인 샘플 정지
      _playingStates.updateAll((key, value) => false);

      // 현재 샘플 재생 상태 토글
      _playingStates[sampleId] = !isCurrentlyPlaying;

      if (_playingStates[sampleId] == true) {
        // 재생 시작 - 임시 프로그레스 애니메이션
        _simulateProgress(sampleId);
      }
    });

    print('🎵 샘플 재생 토글: $sampleId, 재생중: ${_playingStates[sampleId]}');
  }

  // Export 버튼 핸들러
  void _onExportTap(String sampleId) {
    print('📤 Export 버튼 클릭: $sampleId');
    // TODO: 실제 export 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('샘플 메시지를 공유합니다.'), duration: Duration(seconds: 2)),
    );
  }

  // 확대 버튼 핸들러
  void _onExpandTap(String sampleId) {
    print('🔍 확대 버튼 클릭: $sampleId');
    // TODO: 실제 확대/상세 보기 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('상세 보기로 이동합니다.'), duration: Duration(seconds: 2)),
    );
  }

  // 임시 프로그레스 시뮬레이션 (실제 오디오 연동 전까지)
  void _simulateProgress(String sampleId) {
    if (_playingStates[sampleId] != true) return;

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted && _playingStates[sampleId] == true) {
        setState(() {
          final currentProgress = _progressStates[sampleId] ?? 0.0;
          final newProgress = currentProgress + 0.01; // 1% 씩 증가

          if (newProgress >= 1.0) {
            // 재생 완료
            _progressStates[sampleId] = 0.0;
            _playingStates[sampleId] = false;
          } else {
            _progressStates[sampleId] = newProgress;
            _simulateProgress(sampleId); // 재귀 호출로 계속 진행
          }
        });
      }
    });
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
        _buildVoiceExamples(),
        Gaps.v20,
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
