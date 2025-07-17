import 'package:audioplayers/audioplayers.dart';
import 'package:celeb_voice/constants/gaps.dart';
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
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  String? _currentPlayingTitle;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    print('오디오 플레이어 초기화 완료');

    // 재생 완료 시 상태 초기화
    _audioPlayer.onPlayerComplete.listen((event) {
      print('오디오 재생 완료');
      setState(() {
        _isPlaying = false;
        _currentPlayingTitle = null;
      });
    });

    // 오디오 상태 변화 감지
    _audioPlayer.onPlayerStateChanged.listen((state) {
      print('오디오 상태 변화: $state');
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // TTS 재생/일시정지 함수
  Future<void> _togglePlayPause(String messageTitle, String ttsFileName) async {
    try {
      if (_isPlaying && _currentPlayingTitle == messageTitle) {
        print('일시정지 시도');
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
        print('오디오 일시정지 완료');
      } else {
        if (_isPlaying) {
          print('다른 오디오 정지 시도');
          await _audioPlayer.stop();
          print('다른 오디오 정지 완료');
        }

        print('로컬 asset 파일 재생 시도');

        // 로컬 asset 파일 재생
        await _audioPlayer.play(AssetSource('tts/$ttsFileName'));

        print('로컬 asset 파일 재생 시작');

        setState(() {
          _isPlaying = true;
          _currentPlayingTitle = messageTitle;
        });
        print('상태 업데이트 완료');
      }
    } catch (e) {
      print('오디오 재생 실패: $e');
      print('에러 타입: ${e.runtimeType}');
      setState(() {
        _isPlaying = false;
        _currentPlayingTitle = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오디오 재생에 실패했습니다: $e')));
    }
  }

  // 날짜별 메세지 리스트
  final List<DailyMessageModel> _dailyMessages = [
    DailyMessageModel(
      date: "2025년 07월 16일 수요일",
      title: "민지야, 누구나 누군가의 위로가 되어줄 수 있어.",
      content:
          "안녕하세요, 아이유 이지은입니다. 이렇게 또 여러분과 소통할 수 있는 기회를 얻게 되어 정말로 감사한 마음이에요.",
      ttsFileName: "test0.mp3",
    ),
    DailyMessageModel(
      date: "2025년 07월 15일 화요일",
      title: "오늘도 힘내자!",
      content: "오늘도 제가 전하는 노래와 이야기가 여러분의 마음에 작은 기쁨과 위로가 되었으면 좋겠습니다.",
      ttsFileName: "test1.mp3",
    ),
    DailyMessageModel(
      date: "2025년 07월 14일 월요일",
      title: "오늘도 힘내자!",
      content: "자! 다들 정신 안차립니까? 해가 중천인데, 아직도 누워서 뭐하고 있는거죠? 좋게말할떄 당장,,",
      ttsFileName: "test2.mp3",
    ),
    DailyMessageModel(
      date: "2025년 07월 13일 일요일",
      title: "새로운 한 주의 시작",
      content: "데뷔 초부터 지금까지 변함없이 저를 응원해 주시는 팬분들 덕분에 여기까지 올 수 있었다고 생각합니다.",
      ttsFileName: "test3.mp3",
    ),
    DailyMessageModel(
      date: "2025년 07월 12일 토요일",
      title: "새로운 한 주의 시작",
      content: "앞으로도 더 좋은 음악과 다양한 모습을 보여드리기 위해 노력할 테니, 계속해서 따뜻한 관심과 사랑 부탁드릴게요.",
      ttsFileName: "test4.mp3",
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
            Gaps.h12,
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
    final isCurrentlyPlaying =
        _isPlaying && _currentPlayingTitle == message.title;

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
              // 재생/일시정지 버튼
              Positioned(
                bottom: 13,
                right: 13,
                child: InkWell(
                  onTap: () =>
                      _togglePlayPause(message.title, message.ttsFileName),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
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
