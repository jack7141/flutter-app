import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';

class SendMessageScreen extends StatefulWidget {
  static const String routeName = "sendMessage";
  static const String routePath = "/sendMessage";

  final CelebModel? celeb;

  const SendMessageScreen({super.key, this.celeb});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  @override
  Widget build(BuildContext context) {
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
                "친구에게 선물할 메시지를\n적어보세요.",
                style: TextStyle(
                  fontSize: Sizes.size28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              Container(
                padding: const EdgeInsets.all(16.0),
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
                    // 셀럽 아바타와 이름 추가
                    if (widget.celeb != null) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: Image.network(
                                AppConfig.getImageUrl(widget.celeb!.imagePath),
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // 이미지 로딩 실패 시 기본 아이콘 표시
                                  return Icon(
                                    Icons.person,
                                    size: 24,
                                    color: Colors.grey.shade500,
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      // 로딩 중일 때 표시
                                      return Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.grey.shade400,
                                              ),
                                        ),
                                      );
                                    },
                              ),
                            ),
                          ),
                          Gaps.h12,
                          Text(
                            widget.celeb!.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Gaps.v16,
                    ],
                    Container(
                      margin: const EdgeInsets.only(left: 2.0, right: 2.0),
                      child: TextField(
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: "메시지를 입력해주세요",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                    Gaps.v12,
                  ],
                ),
              ),
              Gaps.v28,
              FractionallySizedBox(
                widthFactor: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: Sizes.size16),
                  decoration: BoxDecoration(
                    color: const Color(0xff9e9ef4).withOpacity(0.16),
                    borderRadius: BorderRadius.circular(Sizes.size64),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: Sizes.size18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    child: Text(
                      '템플릿 사용하기',
                      style: TextStyle(
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4638d9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Gaps.v14,
              FormButton(text: '들어보기'),
            ],
          ),
        ),
      ),
    );
  }
}
