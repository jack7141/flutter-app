import 'package:celeb_voice/features/generation/models/daily_message_model.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PreviewTtsScreen extends StatefulWidget {
  final CelebModel? celeb;
  static const String routeName = "previewTts";
  static const String routePath = "/previewTts";

  const PreviewTtsScreen({super.key, required this.celeb});

  @override
  State<PreviewTtsScreen> createState() => _PreviewTtsScreenState();
}

class _PreviewTtsScreenState extends State<PreviewTtsScreen> {
  // 날짜별 메세지 리스트
  final List<DailyMessageModel> _dailyMessages = [
    DailyMessageModel(
      date: "2025년 07월 16일 수요일",
      title: "민지야, 누구나 누군가의 위로가 되어줄 수 있어.",
      content: "내 목소리로 조금이나마 행복했으면 좋겠다. 네가 웃으면 나도 좋아",
    ),
    DailyMessageModel(
      date: "2025년 07월 15일 화요일",
      title: "오늘도 힘내자!",
      content: "어제보다 나은 오늘을 위해 함께 노력해보자. 너는 할 수 있어!",
    ),
    DailyMessageModel(
      date: "2025년 07월 14일 월요일",
      title: "새로운 한 주의 시작",
      content: "월요일이지만 기분 좋게 시작해보자. 응원할게!",
    ),
    DailyMessageModel(
      date: "2025년 07월 13일 일요일",
      title: "새로운 한 주의 시작",
      content: "월요일이지만 기분 좋게 시작해보자. 응원할게!",
    ),
    DailyMessageModel(
      date: "2025년 07월 12일 토요일",
      title: "새로운 한 주의 시작",
      content: "월요일이지만 기분 좋게 시작해보자. 응원할게!",
    ),
    DailyMessageModel(
      date: "2025년 07월 11일 금요일",
      title: "새로운 한 주의 시작",
      content: "월요일이지만 기분 좋게 시작해보자. 응원할게!",
    ),
    DailyMessageModel(
      date: "2025년 07월 10일 목요일",
      title: "새로운 한 주의 시작",
      content: "월요일이지만 기분 좋게 시작해보자. 응원할게!",
    ),
    DailyMessageModel(
      date: "2025년 07월 09일 수요일",
      title: "새로운 한 주의 시작",
      content: "월요일이지만 기분 좋게 시작해보자. 응원할게!",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final celeb = widget.celeb;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(celeb?.imagePath ?? ""),
              backgroundColor: Colors.grey[300],
              onBackgroundImageError: (exception, stackTrace) {
                print('이미지 로드 실패: $exception');
              },
              child: celeb?.imagePath == null || celeb!.imagePath.isEmpty
                  ? Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            SizedBox(width: 12),
            Text(
              celeb?.name ?? "",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 동적으로 날짜별 메세지 렌더링
            ..._dailyMessages.map((message) => _buildDailyMessageCard(message)),
          ],
        ),
      ),
    );
  }

  // 날짜별 메세지 카드 빌드 메서드
  Widget _buildDailyMessageCard(DailyMessageModel message) {
    return Column(
      children: [
        // 날짜 박스
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            top: 20,
            bottom: 10,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xff9e9ef4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.date,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // 메세지 박스
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 5,
            bottom: 10,
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 50, // 재생 버튼 공간 확보
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff463e8d),
                      ),
                    ),
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // 재생 버튼을 우측 하단에 오버레이
              Positioned(
                bottom: 13,
                right: 13,
                child: InkWell(
                  onTap: () {
                    // 재생 버튼 클릭 시 동작
                    print('재생 버튼 클릭: ${message.title}');
                    // 여기에 TTS 재생 로직 추가
                  },
                  borderRadius: BorderRadius.circular(15), // 클릭 효과 영역
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.play_arrow,
                      color: Color(0xff9e9ef4),
                      size: 30,
                      shadows: [
                        Shadow(
                          color: Color(0xff211772).withOpacity(0.16),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
