import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/features/user_profile/widgets/mypage_formbutton.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  static const String routeName = "userProfile";

  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
                    backgroundImage: NetworkImage(
                      "https://avatars.githubusercontent.com/u/3612017",
                    ),
                  ),
                  Gaps.h12,
                  Text(
                    "민지",
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
}
