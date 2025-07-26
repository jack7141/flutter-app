import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added for context.push

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
  String _nicknameInput = "";
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _mainMessageController = TextEditingController();
  bool _isTemplateApplied = false;
  bool _isMessageReviewConfirmed = false; // 메시지 검토 확인 상태 추가

  @override
  void initState() {
    super.initState();
    print("🎭 SendMessageScreen - 받은 celeb 정보: ${widget.celeb?.name}");
  }

  // 한국어 조사 처리 함수 (home_screen.dart에서 가져옴)
  String _getNameWithJosa(String name, String josaType) {
    if (name.isEmpty) return name;

    // 마지막 글자의 유니코드
    int lastChar = name.codeUnitAt(name.length - 1);

    // 한글 범위 확인 (가-힣)
    if (lastChar >= 0xAC00 && lastChar <= 0xD7A3) {
      // 받침 있는지 확인 (종성이 있으면 받침 있음)
      bool hasBatchim = (lastChar - 0xAC00) % 28 != 0;

      switch (josaType) {
        case '이/가':
          return hasBatchim ? '$name이' : '$name가';
        case '을/를':
          return hasBatchim ? '$name을' : '$name를';
        case '은/는':
          return hasBatchim ? '$name은' : '$name는';
        case '과/와':
          return hasBatchim ? '$name과' : '$name와';
        case '아/야':
          return hasBatchim ? '$name아' : '$name야';
        case '의':
          return '$name의'; // 의는 받침과 상관없이 동일
        default:
          return name;
      }
    }

    // 한글이 아닌 경우 (영어, 숫자 등)
    // 영어의 경우 대부분 받침이 있다고 가정
    switch (josaType) {
      case '이/가':
        return '$name이';
      case '을/를':
        return '$name을';
      case '은/는':
        return '$name은';
      case '과/와':
        return '$name과';
      case '아/야':
        return '$name아';
      case '의':
        return '$name의';
      default:
        return name;
    }
  }

  // 템플릿 메시지 생성 (한국어 조사 처리 적용)
  String _generateTemplateMessage() {
    String celebName = widget.celeb?.name ?? "셀럽";
    String nickname = _nicknameInput;

    // 조사가 적용된 이름들
    String celebWithI = _getNameWithJosa(celebName, '이/가');
    String celebWithUi = _getNameWithJosa(celebName, '의');
    String nicknameWithA = _getNameWithJosa(nickname, '아/야');

    // 카테고리별 더미 메시지 템플릿들 (조사 처리 적용)
    Map<String, List<String>> templateMessages = {
      "생일축하": [
        "$nicknameWithA, 네가 태어난 그 날도 세상도 조금 더 반짝였을거야. $celebWithUi 오늘도 반짝이는 하루이길 바랄게. 생일 축하해!",
        "$nicknameWithA, 오늘은 네가 이 세상에 온 소중한 날이야! $celebWithI 진심으로 축하해. 앞으로도 행복한 일만 가득하길!",
        "생일 축하해 $nicknameWithA! $celebWithI 너의 새로운 한 살을 응원할게. 올해는 더욱 멋진 일들이 기다리고 있을거야!",
        "$nicknameWithA, 생일 정말 축하해! $celebName도 너처럼 특별한 사람을 알게 되어 기뻐. 행복한 하루 보내!",
      ],
      "응원메시지": [
        "$nicknameWithA, 힘든 일이 있어도 $celebWithI 항상 네 곁에 있다는 걸 잊지마. 넌 정말 잘하고 있어. 화이팅!",
        "$nicknameWithA, 때로는 힘들어도 괜찮아. $celebWithI 너를 믿고 있으니까 포기하지 말고 조금만 더 힘내자!",
        "힘들 때일수록 $celebName을 생각해줘, $nicknameWithA. 넌 생각보다 훨씬 강한 사람이야. 할 수 있어!",
        "$nicknameWithA, 어려운 시간이지만 $celebWithI 응원하고 있어. 이 또한 지나갈거야. 조금만 더 버텨보자!",
      ],
      "고마운 마음": [
        "$nicknameWithA, 네가 있어서 $celebWithUi 하루가 더 특별해져. 고마워, 정말로.",
        "$nicknameWithA, 항상 고마워. $celebName에게 너는 정말 소중한 존재야. 네가 있어서 행복해!",
        "고맙다는 말로는 부족하지만, $nicknameWithA, $celebWithI 진심으로 감사하고 있어. 네가 있어서 다행이야.",
        "$nicknameWithA, 네 덕분에 $celebWithI 웃을 수 있어. 언제나 고마운 마음 잊지 않을게!",
      ],
      "사랑고백": [
        "$nicknameWithA, $celebWithUi 마음을 전하고 싶어. 너를 정말 많이 좋아해.",
        "$nicknameWithA, 솔직히 말할게. $celebName에게 너는 정말 특별한 사람이야. 사랑해!",
        "$nicknameWithA, 이 말을 꼭 해주고 싶었어. $celebWithI 너를 진심으로 사랑한다는 걸...",
        "$nicknameWithA, 네가 없으면 $celebWithUi 하루가 의미가 없어져. 정말 많이 사랑해!",
      ],
      "위로": [
        "$nicknameWithA, 힘들 때는 $celebName을 생각해줘. 모든 게 괜찮아질거야.",
        "$nicknameWithA, 지금은 힘들겠지만 $celebWithI 네 편에 있어. 혼자가 아니야, 괜찮을거야.",
        "괜찮아 $nicknameWithA, $celebWithI 너의 아픔을 함께 나눌게. 시간이 약이 될거야.",
        "$nicknameWithA, 울고 싶을 때는 울어도 돼. $celebWithI 네 곁에서 기다리고 있을게.",
      ],
      "축하": [
        "$nicknameWithA, 정말 축하해! $celebName도 네가 이뤄낸 일들이 너무 자랑스러워.",
        "와! $nicknameWithA, 정말 대단해! $celebWithI 너를 진심으로 축하해. 너라면 할 수 있을 줄 알았어!",
        "$nicknameWithA, 축하한다! $celebName도 네가 성공했다는 소식에 정말 기뻐. 앞으로도 승승장구하자!",
        "축하해 $nicknameWithA! $celebWithI 봐도 네 노력이 빛을 발한 것 같아. 정말 멋져!",
      ],
      "안부": [
        "$nicknameWithA, 잘 지내고 있어? $celebWithI 안부를 전하고 싶었어. 오늘도 좋은 하루 보내!",
        "$nicknameWithA, 요즘 어떻게 지내? $celebWithI 네 소식이 궁금했어. 건강하게 잘 지내고 있길!",
        "안녕 $nicknameWithA! $celebName이야. 갑자기 네 생각이 나서 안부 인사 드리고 싶었어. 잘 지내지?",
        "$nicknameWithA, 오랜만이야! $celebWithI 너를 생각하며 안부를 물어보고 싶었어. 건강하게 지내고 있어?",
      ],
    };

    // 상황별 메시지 톤 조정
    Map<String, String> situationTones = {
      "따뜻한 말": "💝",
      "유머러스한 말": "😄",
      "진심어린 말": "💖",
      "격려의 말": "💪",
      "재미있는 말": "🎉",
      "감동적인 말": "✨",
    };

    // 선택된 카테고리의 메시지 목록 가져오기
    List<String> messages =
        templateMessages[_selectedCategory] ??
        ["$nicknameWithA, $celebWithI 너에게 특별한 메시지를 전하고 싶어!"];

    // 랜덤으로 메시지 선택
    String selectedMessage =
        messages[DateTime.now().millisecond % messages.length];

    // 상황에 따른 이모지 추가
    String emoji = situationTones[_selectedSituation] ?? "💜";

    return "$selectedMessage $emoji";
  }

  // 템플릿 적용
  void _applyTemplate() {
    print("✅ 선택된 템플릿:");
    print("카테고리: $_selectedCategory");
    print("상황: $_selectedSituation");
    print("호칭: $_nicknameInput");

    // 템플릿 메시지 생성
    String templateMessage = _generateTemplateMessage();

    // 메인 TextField에 템플릿 적용
    setState(() {
      _mainMessageController.text = templateMessage;
      _isTemplateApplied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("템플릿이 적용되었습니다!"),
        backgroundColor: Color(0xff9e9ef4),
      ),
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

  // 호칭 옵션들 (참고용)
  List<String> _getNicknameOptions() {
    return ["친구", "동생", "언니", "누나", "형", "오빠", "이름", "별명"];
  }

  // 템플릿 선택 바텀 시트
  void _showTemplateBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
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
                  SizedBox(height: 15),
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

                          SizedBox(height: 25),

                          // 2. 상황/문구 선택
                          _buildTemplateQuestion(
                            "2. 어울리는 상황/문구를 선택해주세요.",
                            _getSituationOptions(),
                            _selectedSituation,
                            (value) =>
                                setState(() => _selectedSituation = value),
                          ),

                          SizedBox(height: 25),

                          // 3. 호칭 입력
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "3. 메시지 받을 사람을 뭐라고 부르면 좋을까요?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff463e8d),
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xffc3c7cb)),
                                ),
                                child: TextField(
                                  controller: _nicknameController,
                                  onChanged: (value) =>
                                      setState(() => _nicknameInput = value),
                                  decoration: InputDecoration(
                                    hintText: "예: 민수야, 친구, 언니 등",
                                    hintStyle: TextStyle(
                                      color: Color(0xffc3c7cb),
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff463e8d),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 30),

                          // 완료 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _selectedCategory != null &&
                                      _selectedSituation != null &&
                                      _nicknameInput.isNotEmpty
                                  ? () {
                                      Navigator.pop(context);
                                      _applyTemplate();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff9e9ef4),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                "메시지 완성",
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
            color: Color(0xff463e8d),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 35,
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
                  child: IntrinsicWidth(
                    child: Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color.fromARGB(255, 218, 218, 248)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xff4d458e)
                              : Color(0xffc3c7cb),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected
                              ? Color(0xff4d458e)
                              : Color(0xffc3c7cb),
                        ),
                        textAlign: TextAlign.center,
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

  // 메시지 검토 안내 다이얼로그 (수정)
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
                    // 확인 상태를 true로 설정
                    setState(() {
                      _isMessageReviewConfirmed = true;
                    });
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

  // 들어보기 버튼 핸들러 (수정)
  void _handleListenButtonTap() {
    if (_isMessageReviewConfirmed) {
      // 이미 확인했으면 myMessageTts 페이지로 이동 (celeb만 전달)
      context.push('/myMessageTts', extra: widget.celeb);
    } else {
      // 아직 확인하지 않았으면 다이얼로그 표시
      _showMessageReviewDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CommonAppBar(),
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
              Stack(
                // Stack 다시 추가
                children: [
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Color(0xff9e9ef4)),
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
                        ],
                        Container(
                          margin: const EdgeInsets.only(left: 2.0, right: 2.0),
                          child: TextField(
                            controller: _mainMessageController,
                            readOnly: _isTemplateApplied, // 템플릿 적용 시 읽기 전용
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
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: _isTemplateApplied
                                  ? Colors.grey.shade700
                                  : Colors.black, // 템플릿 적용 시 회색
                            ),
                          ),
                        ),
                        Gaps.v12,
                      ],
                    ),
                  ),
                  // 템플릿 적용 시 회색 오버레이 다시 추가
                  if (_isTemplateApplied)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1), // 회색 오버레이
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                ],
              ),
              Gaps.v28,
              GestureDetector(
                onTap: _showTemplateBottomSheet, // 항상 클릭 가능 (새 템플릿으로 교체)
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
                onTap: _handleListenButtonTap, // 수정된 핸들러 사용
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
