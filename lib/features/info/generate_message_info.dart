import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';

class GenerateMessageInfo extends StatefulWidget {
  static const String routeName = "generateMessageInfo";
  static const String routeURL = "/generateMessageInfo";

  const GenerateMessageInfo({super.key});

  @override
  State<GenerateMessageInfo> createState() => _GenerateMessageInfoState();
}

class _GenerateMessageInfoState extends State<GenerateMessageInfo> {
  @override
  void initState() {
    super.initState();
    print('📱 GenerateMessageInfo 페이지 초기화');
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ GenerateMessageInfo 페이지 빌드 중...');
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40), // AppBar 기본 높이만큼 여백
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.size20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "보이스를\n생성하시겠습니까?",
                      style: TextStyle(
                        fontSize: Sizes.size28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.v20,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "보이스 생성 1회",
                            style: TextStyle(
                              fontSize: Sizes.size16,
                              color: Color(0xFF463E8D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "550",
                            style: TextStyle(
                              fontSize: Sizes.size16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gaps.v20,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.03,
                        horizontal: Sizes.size16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFF9e9ef4)),
                        borderRadius: BorderRadius.circular(Sizes.size32),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: Sizes.size16),
                              Image.asset(
                                'assets/images/my_message.png',
                                width: MediaQuery.of(context).size.width * 0.08,
                                height:
                                    MediaQuery.of(context).size.width * 0.08,
                              ),
                              SizedBox(width: Sizes.size16),
                              Expanded(
                                child: Text(
                                  "나만의 보이스를 활용하여 특별한 콘텐츠 제작",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF463E8D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                              ),
                              Image.asset(
                                'assets/images/present_icon.png',
                                width: MediaQuery.of(context).size.width * 0.08,
                                height:
                                    MediaQuery.of(context).size.width * 0.08,
                              ),
                              SizedBox(width: Sizes.size16),
                              Expanded(
                                child: Text(
                                  "친구에게 마음을 전달하는 보이스 카드",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF463E8D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Gaps.v20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: FormButton(
                            text: "다음에 하기",
                            color: Colors.white,
                            textColor: Color(0xFF868E96),
                            borderColor: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(width: Sizes.size16),
                        Expanded(flex: 2, child: FormButton(text: "생성하기")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
