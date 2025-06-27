import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart';
import 'package:celeb_voice/features/user_profile/repos/user_profile_repo.dart';
import 'package:celeb_voice/features/user_profile/widgets/mypage_formbutton.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    // AuthenticationRepo 인스턴스를 생성해서 전달
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
      appBar: AppBar(
        title: Text(
          "마이페이지",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: _getProfileImage(),
                    child: _getProfileImage() == null
                        ? Icon(Icons.person, size: 24, color: Colors.grey)
                        : null,
                  ),
                  Gaps.h12,
                  Text(
                    _getDisplayName(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  Icon(
                    Icons.border_color_outlined,
                    size: 24,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
              Gaps.v36,
              MyPageFormButton(title: "계정 설정", icon: Icons.arrow_forward_ios),
              Gaps.v36,
              MyPageFormButton(
                title: "구독 중인 이용권",
                icon: Icons.arrow_forward_ios,
              ),
              Gaps.v36,
              MyPageFormButton(title: "앱설정", icon: Icons.arrow_forward_ios),
              Gaps.v36,
              MyPageFormButton(title: "문의하기", icon: Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  // 프로필 이미지 가져오기
  ImageProvider? _getProfileImage() {
    if (isLoading) return null;

    final profileLink = userProfile?['profile']?['link'];
    if (profileLink != null && profileLink.isNotEmpty) {
      print("🖼️ 프로필 이미지 URL: $profileLink");
      return NetworkImage(profileLink);
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
