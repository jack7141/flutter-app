import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:flutter/material.dart';

class UserSettingsScreen extends StatefulWidget {
  static const String routeUrl = '/settings';
  static const String routeName = 'settings';
  final String? userId;
  final String? userName;
  const UserSettingsScreen({super.key, this.userId, this.userName});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(title: '설정'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 내 정보 섹션
          Padding(
            padding: const EdgeInsets.all(20), // 16 → 20으로 증가
            child: Text(
              '내 정보',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // 16 → 20으로 증가
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'user@example.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("계정 정보 버튼 클릭");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ), // 패딩 증가
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xff9e9ef4)),
                      ),
                      child: Text(
                        '계정 정보',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff9e9ef4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gaps.v5,
          Divider(color: Colors.grey.shade300, thickness: 1),
          Gaps.v16, // 간격 증가
          // 구독 중인 이용권 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // 16 → 20으로 증가
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '구독 중인 이용권',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                Gaps.v16, // 간격 증가
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20), // 16, 12 → 20으로 증가
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xff9e9ef4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '월간이용권',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Gaps.v4, // 간격 추가
                              Text(
                                '2025.07.23 ~ 2026.07.23',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12, // 8 → 12로 증가
                              vertical: 6, // 2 → 6으로 증가
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Color(0xff9e9ef4)),
                            ),
                            child: Text(
                              '구독 관리',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff9e9ef4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gaps.v16, // 간격 증가
                      Divider(color: Color(0xff9e9ef4), thickness: 1),
                      Gaps.v16, // 간격 증가
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '보유 크레딧',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '4,500',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
