import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart';
import 'package:celeb_voice/features/user_profile/repos/user_profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserProfileScreen extends StatefulWidget {
  static const String routeName = "userProfile";

  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final UserProfileRepo _userProfileRepo;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  // 나만의 메시지 목록
  final List<Map<String, dynamic>> _myMessages = [
    {
      "title": "생일축하 메시지",
      "content": "생일 축하해! 항상 행복하길 바라♥",
      "celeb": "아이유",
      "date": "2024.01.15",
    },
    {
      "title": "응원 메시지",
      "content": "힘내! 넌 할 수 있어!",
      "celeb": "민지",
      "date": "2024.01.10",
    },
  ];

  // 친구와의 메시지 목록
  final List<Map<String, dynamic>> _friendMessages = [
    {
      "title": "데일리 메시지",
      "content": "오늘도 좋은 하루 보내!",
      "celeb": "뉴진스 하니",
      "date": "2024.01.20",
      "from": "김철수",
    },
    {
      "title": "감사 메시지",
      "content": "항상 고마워 친구야!",
      "celeb": "아이유",
      "date": "2024.01.18",
      "from": "이영희",
    },
  ];

  @override
  void initState() {
    super.initState();
    final authRepo = AuthenticationRepo();
    _userProfileRepo = UserProfileRepo(authRepo: authRepo);
    _loadUserProfile();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
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
                      onPressed: () {},
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
                            vertical: 25,
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
                              Gaps.h5,
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Color(0xff868e96),
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
                // TabBar (패딩 없음 - 화면 전체 너비)
                SliverPersistentHeader(
                  delegate: _MessageTabBarDelegate(),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                // 나만의 메시지 탭
                _buildMyMessagesList(),
                // 친구와의 메시지 탭
                _buildFriendMessagesList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyMessagesList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ), // 25 → 16으로 줄임
      itemCount: _myMessages.length,
      itemBuilder: (context, index) {
        final message = _myMessages[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff9e9ef4),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.heart,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          title: Text(
            message['title'],
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message['content'],
                style: TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Gaps.v4,
              Text(
                "${message['celeb']} • ${message['date']}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          trailing: FaIcon(
            FontAwesomeIcons.chevronRight,
            size: 16,
            color: Colors.grey.shade400,
          ),
          onTap: () {
            print("💌 나만의 메시지 클릭: ${message['title']}");
          },
        );
      },
    );
  }

  Widget _buildFriendMessagesList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ), // 25 → 16으로 줄임
      itemCount: _friendMessages.length,
      itemBuilder: (context, index) {
        final message = _friendMessages[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff211772),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.userGroup,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          title: Text(
            message['title'],
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message['content'],
                style: TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Gaps.v4,
              Text(
                "${message['from']} • ${message['celeb']} • ${message['date']}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          trailing: FaIcon(
            FontAwesomeIcons.chevronRight,
            size: 16,
            color: Colors.grey.shade400,
          ),
          onTap: () {
            print("👥 친구 메시지 클릭: ${message['title']}");
          },
        );
      },
    );
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

// 탭바 델리게이트
class _MessageTabBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        // border 부분 제거
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2.0,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xff9e9ef4), width: 2.0),
          insets: EdgeInsets.symmetric(horizontal: 0.0),
        ),
        labelColor: Color(0xff463f99),
        unselectedLabelColor: Colors.black,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: [
          Tab(text: "받은 메시지"),
          Tab(text: "보낸 메시지"),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 40.0;

  @override
  double get minExtent => 40.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
