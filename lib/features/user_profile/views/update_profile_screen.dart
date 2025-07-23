import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/features/user_profile/widgets/mypage_formbutton.dart';
import 'package:flutter/material.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const String routeName = 'update_profile';
  static const String routeURL = '/update_profile';
  final String? userId;
  final String? userName;
  const UpdateProfileScreen({super.key, this.userId, this.userName});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CommonAppBar(title: '계정 정보'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '연동 로그인',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                Gaps.v10,
                Text(
                  'user@example.com',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Gaps.v32,
                Text(
                  '이름',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                Gaps.v10,
                Text(
                  '홍길동',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Gaps.v32,
                Text(
                  '휴대폰 번호',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                Gaps.v10,
                Text(
                  '+82 10-1234-5678',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Gaps.v32,
                Divider(color: Colors.grey.shade300, thickness: 1),
                Gaps.v32,
                MyPageFormButton(title: "로그아웃", icon: Icons.arrow_forward_ios),
                Gaps.v32,
                MyPageFormButton(title: "회원탈퇴", icon: Icons.arrow_forward_ios),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
