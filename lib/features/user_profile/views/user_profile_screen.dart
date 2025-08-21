import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart';
import 'package:celeb_voice/features/user_profile/repos/user_profile_repo.dart';
import 'package:celeb_voice/features/user_profile/views/user_settings_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatefulWidget {
  static const String routeName = "userProfile";

  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final UserProfileRepo _userProfileRepo;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  // 사용자의 메시지 목록 (API에서 가져옴)
  List<Map<String, dynamic>> _userMessages = [];
  bool _isMessagesLoading = true;
  String? _messagesError;

  @override
  void initState() {
    super.initState();
    final authRepo = AuthenticationRepo();
    _userProfileRepo = UserProfileRepo(authRepo: authRepo);
    _loadUserProfile();
    _loadUserMessages(); // 사용자 메시지 목록 로드
  }

  Future<void> _loadUserProfile() async {
    print("🔄 사용자 프로필 로딩 시작");

    final profile = await _userProfileRepo.getUserProfile();

    setState(() {
      userProfile = profile;
      isLoading = false;
    });

    if (profile != null) {
      print("✅ 사용자 프로필 로딩 완료");
      print("📋 프로필 데이터: $profile");
    } else {
      print("❌ 사용자 프로필 로딩 실패");
    }
  }

  // 사용자 메시지 목록 로드
  Future<void> _loadUserMessages() async {
    try {
      print("🔄 사용자 메시지 로딩 시작");

      setState(() {
        _isMessagesLoading = true;
        _messagesError = null;
      });

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
        '/api/v1/celeb/message/my/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
          },
        ),
      );

      print("📥 메시지 API 응답: ${response.statusCode}");
      print("📋 응답 데이터: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data;
        final List<dynamic> messageData = responseData['data'] ?? [];

        if (mounted) {
          setState(() {
            _userMessages = messageData.cast<Map<String, dynamic>>();
            _isMessagesLoading = false;
          });
        }

        print("✅ 사용자 메시지 로딩 완료: ${_userMessages.length}개");
      } else {
        throw Exception('메시지 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ 사용자 메시지 로딩 실패: $e");

      if (mounted) {
        setState(() {
          _isMessagesLoading = false;
          _messagesError = '메시지를 불러올 수 없습니다.';
        });
      }
    }
  }

  void _navigateToSettings() {
    context.push(UserSettingsScreen.routeUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Text(
                  "마이페이지",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    onPressed: _navigateToSettings,
                    icon: Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              // 프로필 섹션 (패딩 있음)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gaps.v20,
                      // 기존 프로필 섹션
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xff9e9ef4).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(Sizes.size16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: _getProfileImage(),
                              child: _getProfileImage() == null
                                  ? Icon(
                                      Icons.person,
                                      size: 24,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            Gaps.h12,
                            Text(
                              _getDisplayName(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "4,000",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gaps.v10,
                    ],
                  ),
                ),
              ),
              // Divider (패딩 없음 - 화면 전체 너비)
              SliverToBoxAdapter(
                child: Divider(color: Colors.grey.shade300, thickness: 1),
              ),
              // 메시지 보관함 텍스트 (패딩 있음)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gaps.v20,
                      Text(
                        "메시지 보관함",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gaps.v10,
                    ],
                  ),
                ),
              ),
            ];
          },
          body: _buildMyMessagesList(),
        ),
      ),
    );
  }

  Widget _buildMyMessagesList() {
    // 로딩 상태
    if (_isMessagesLoading) {
      return Container(
        color: Color(0xffEFF0F4),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xff9e9ef4)),
        ),
      );
    }

    // 에러 상태
    if (_messagesError != null) {
      return Container(
        color: Color(0xffEFF0F4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              Gaps.v16,
              Text(
                _messagesError!,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              Gaps.v16,
              TextButton(
                onPressed: _loadUserMessages,
                child: Text(
                  '다시 시도',
                  style: TextStyle(color: Color(0xff9e9ef4)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 메시지가 없는 경우
    if (_userMessages.isEmpty) {
      return Container(
        color: Color(0xffEFF0F4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              Gaps.v16,
              Text(
                '아직 생성된 메시지가 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              Gaps.v8,
              Text(
                '첫 번째 음성 메시지를 만들어보세요!',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    // 실제 메시지 목록 표시
    return Container(
      color: Color(0xffEFF0F4),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _userMessages.length,
        itemBuilder: (context, index) {
          final message = _userMessages[index];
          final celebrity = message['celebrity'];
          final requestText = message['requestText'] ?? '';

          return Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    iconColor: Colors.transparent,
                    collapsedIconColor: Colors.transparent,
                    tilePadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    childrenPadding: EdgeInsets.zero,
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipOval(child: _buildCelebImage(celebrity)),
                    ),
                    title: Text(
                      celebrity?['name'] ?? '셀럽',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Text(
                      _formatMessageDate(message['created'] ?? ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    children: [
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              requestText,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 셀럽 이미지 빌드
  Widget _buildCelebImage(Map<String, dynamic>? celebrity) {
    if (celebrity == null) {
      return Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.person, size: 20, color: Colors.grey),
      );
    }

    final images = celebrity['images'];
    String? imageUrl;

    if (images != null && images is List && images.isNotEmpty) {
      imageUrl = images[0]['url'];
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        AppConfig.getImageUrl(imageUrl),
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

    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.person, size: 20, color: Colors.grey),
    );
  }

  // 메시지 날짜 포맷팅
  String _formatMessageDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}분 전';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}시간 전';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}일 전';
      } else {
        return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return '';
    }
  }

  // 프로필 이미지 가져오기
  ImageProvider? _getProfileImage() {
    if (isLoading) return null;

    final images = userProfile?['profile']?['images'];
    if (images != null && images is List && images.isNotEmpty) {
      final firstImage = images[0];
      final imageUrl = firstImage['imageUrl'];

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final cloudFrontUrl = AppConfig.getImageUrl(imageUrl);
        print("🖼️ 프로필 이미지 URL: $cloudFrontUrl");
        return NetworkImage(cloudFrontUrl);
      }
    }

    return null;
  }

  // 표시할 이름 가져오기
  String _getDisplayName() {
    if (isLoading) {
      return "로딩 중...";
    }

    final nickname = userProfile?['profile']?['nickname'];
    if (nickname != null && nickname.isNotEmpty) {
      print("👤 닉네임: $nickname");
      return nickname;
    }

    return "사용자";
  }
}
