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
  // 템플릿 선택 상태 변수들
  String? _selectedCategory;
  String? _selectedSituation;
  String? _selectedNickname;

  @override
  void initState() {
    super.initState();
    print("🎭 SendMessageScreen - 받은 celeb 정보: ${widget.celeb?.name}");
  }

  // 템플릿 선택 바텀 시트
  void _showTemplateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // 이 옵션 추가 - 하단 네비게이션바까지 덮음
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 핸들러
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    "템플릿으로 메시지 만들기",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. 카테고리 선택
                          _buildTemplateQuestion(
                            "1. 선물하고 싶은 메시지 카테고리를 선택해주세요.",
                            _getCategoryOptions(),
                            _selectedCategory,
                            (value) =>
                                setState(() => _selectedCategory = value),
                          ),

                          SizedBox(height: 30),

                          // 2. 상황/문구 선택
                          _buildTemplateQuestion(
                            "2. 어울리는 상황/문구를 선택해주세요.",
                            _getSituationOptions(),
                            _selectedSituation,
                            (value) =>
                                setState(() => _selectedSituation = value),
                          ),

                          SizedBox(height: 30),

                          // 3. 호칭 선택
                          _buildTemplateQuestion(
                            "3. 메시지 받을 사람을 뭐라고 부르면 좋을까요?",
                            _getNicknameOptions(),
                            _selectedNickname,
                            (value) =>
                                setState(() => _selectedNickname = value),
                          ),

                          SizedBox(height: 40),

                          // 완료 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _selectedCategory != null &&
                                      _selectedSituation != null &&
                                      _selectedNickname != null
                                  ? () {
                                      Navigator.pop(context);
                                      _applyTemplate();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff9e9ef4),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "템플릿 적용하기",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 템플릿 질문 위젯 빌더
  Widget _buildTemplateQuestion(
    String question,
    List<String> options,
    String? selectedValue,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selectedValue == option;

              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color.fromARGB(255, 218, 218, 248)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff4d458e)
                            : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Color(0xff4d458e) : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 카테고리 옵션들
  List<String> _getCategoryOptions() {
    return ["생일축하", "응원메시지", "고마운 마음", "사랑고백", "위로", "축하", "안부"];
  }

  // 상황/문구 옵션들
  List<String> _getSituationOptions() {
    return ["따뜻한 말", "유머러스한 말", "진심어린 말", "격려의 말", "재미있는 말", "감동적인 말"];
  }

  // 호칭 옵션들
  List<String> _getNicknameOptions() {
    return ["친구", "동생", "언니", "누나", "형", "오빠", "이름", "별명"];
  }

  // 템플릿 적용
  void _applyTemplate() {
    print("✅ 선택된 템플릿:");
    print("카테고리: $_selectedCategory");
    print("상황: $_selectedSituation");
    print("호칭: $_selectedNickname");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("템플릿이 적용되었습니다!"),
        backgroundColor: Color(0xff9e9ef4),
      ),
    );
  }

  // 메시지 검토 안내 다이얼로그
  void _showMessageReviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 40),
          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
          content: Text(
            '직접 작성하는 메시지는\n검토 후 발송 가능하며,\n1~2일 소요될 수 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 120,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xff9e9ef4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CommonAppBar(
        title: widget.celeb != null ? "${widget.celeb!.name}에게 메시지" : "메시지 작성",
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
                    // 셀럽 아바타와 이름
                    if (widget.celeb != null) ...[
                      Container(
                        padding: EdgeInsets.all(8),
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
                              ],
                            ),
                          ],
                        ),
                      ),
                      Gaps.v16,
                    ] else ...[
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
                              ? "${widget.celeb!.name}의 목소리로 어떤 메시지를 전달할까요?"
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
              GestureDetector(
                onTap: _showTemplateBottomSheet, // 바텀 시트 표시
                child: FractionallySizedBox(
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
              ),
              Gaps.v14,
              GestureDetector(
                onTap: _showMessageReviewDialog,
                child: FormButton(
                  text: widget.celeb != null
                      ? '${widget.celeb!.name} 목소리로 들어보기'
                      : '들어보기',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
