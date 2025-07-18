import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NicknameScreen extends StatefulWidget {
  static const String routeName = "nickname";
  static const String routePath = "/nickname";

  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  void _onSaveTap() {
    context.pushReplacement('/home');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '셀럽에게 불릴\n이름을 설정해주세요.',
              style: TextStyle(
                fontSize: Sizes.size28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gaps.v20,
            TextField(
              decoration: InputDecoration(
                hintText: '이름을 입력해주세요.',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            Gaps.v20,
            GestureDetector(
              onTap: _onSaveTap,
              child: FormButton(text: '저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
