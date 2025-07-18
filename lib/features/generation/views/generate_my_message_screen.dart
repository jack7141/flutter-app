import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GernerateMessageScreen extends StatefulWidget {
  final CelebModel? celeb;
  static const String routeName = "generateMessage";
  static const String routePath = "/generateMessage";

  const GernerateMessageScreen({super.key, required this.celeb});

  @override
  State<GernerateMessageScreen> createState() => _GernerateMessageScreenState();
}

class _GernerateMessageScreenState extends State<GernerateMessageScreen> {
  void _onNextTap(BuildContext context) {
    context.push('/myMessageTts', extra: widget.celeb);
  }

  @override
  Widget build(BuildContext context) {
    final celeb = widget.celeb;
    print("🔍 celeb: $celeb");

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "듣고 싶은 메세지를\n적어보세요.",
                style: TextStyle(
                  fontSize: Sizes.size28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(2.0),
                      child: CelebAvatar(currentCeleb: celeb), // celeb 정보 전달
                    ),
                    Gaps.v12,
                    Container(
                      margin: const EdgeInsets.only(left: 2.0, right: 2.0),
                      child: TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "메세지를 입력해주세요",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gaps.v28,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FormButton(text: '들어보기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
