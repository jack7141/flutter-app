import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "이용약관",
          style: TextStyle(fontSize: Sizes.size20, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "전체 동의",
            style: TextStyle(
              fontSize: Sizes.size18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gaps.v10,
          Text(
            "(필수) 서비스 이용약관 동의",
            style: TextStyle(
              color: const Color(0xff463e8d),
              fontSize: Sizes.size18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gaps.v10,
          Text(
            "(선택) 개인정보 수집 및 이용 동의",
            style: TextStyle(
              color: const Color(0xff463e8d),
              fontSize: Sizes.size18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gaps.v10,
          Text(
            "(선택) 광고 및 마케팅 활용 동의",
            style: TextStyle(
              color: const Color(0xff463e8d),
              fontSize: Sizes.size18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xff9e9ef4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "다음",
              style: TextStyle(
                color: Colors.white,
                fontSize: Sizes.size24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
