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
  void initState() {
    super.initState();
    // 디버그용 로그 추가
    print("🎭 SendMessageScreen - 받은 celeb 정보: ${widget.celeb?.name}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CommonAppBar(
        title: widget.celeb != null
            ? "${widget.celeb!.name}에게 메시지"
            : "메시지 작성", // 제목에 셀럽 이름 추가
      ),
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
                    // 셀럽 아바타와 이름 - 개선된 버전
                    if (widget.celeb != null) ...[
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xff9e9ef4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                border: Border.all(
                                  color: Color(0xff9e9ef4).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22.5),
                                child: Image.network(
                                  AppConfig.getImageUrl(
                                    widget.celeb!.imagePath,
                                  ),
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      "❌ 이미지 로딩 실패: ${widget.celeb!.imagePath}",
                                    );
                                    return Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade200,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 26,
                                        color: Colors.grey.shade500,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color(0xff9e9ef4),
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                ),
                              ),
                            ),
                            Gaps.h12,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.celeb!.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "목소리로 메시지 전송",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Gaps.v16,
                    ] else ...[
                      // celeb 정보가 없을 때 표시
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            Gaps.h8,
                            Text(
                              "셀럽을 선택해주세요",
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ],
                        ),
                      ),
                      Gaps.v16,
                    ],
                    Container(
                      margin: const EdgeInsets.only(left: 2.0, right: 2.0),
                      child: TextField(
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: widget.celeb != null
                              ? "${widget.celeb!.name}의 목소리로 전할 메시지를 입력해주세요"
                              : "메시지를 입력해주세요",
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
              Gaps.v14,
              FormButton(
                text: widget.celeb != null
                    ? '${widget.celeb!.name} 목소리로 들어보기'
                    : '들어보기',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
