import 'package:audioplayers/audioplayers.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/features/generation/models/daily_message_model.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/services/daily_message_service.dart';
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

  // API 데이터 관리 변수로 변경
  List<DailyMessageModel> _dailyMessages = []; // 빈 리스트로 초기화
  bool _isLoading = true; // 로딩 상태 추가

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

    // API 데이터 로드 추가
    _loadDailyMessages();
  }

  // API 데이터 로드 메서드 수정
  Future<void> _loadDailyMessages() async {
    final celeb = widget.celeb;
    if (celeb == null) return;

    try {
      final responses = await DailyMessageService.getDailyMessages(celeb.id);
      setState(() {
        _dailyMessages = responses
            .map(
              (response) => DailyMessageModel.fromApiResponse({
                'generatedText': response.generatedText,
                'audioFile': response.audioFile,
                'postedAt': response.postedAt,
              }),
            )
            .toList();
        _isLoading = false;
      });
      print('✅ API 데이터 로드 완료: ${_dailyMessages.length}개');
    } catch (e) {
      print('❌ 데이터 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // TTS 재생/일시정지 함수 (네트워크 URL로 변경)
  Future<void> _togglePlayPause(String messageTitle, String audioUrl) async {
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

        print('네트워크 오디오 재생 시도: $audioUrl');

        // 네트워크 오디오 재생
        await _audioPlayer.play(UrlSource(audioUrl));

        print('네트워크 오디오 재생 시작');

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

  // 더미 데이터 제거 (이제 API에서 가져옴)

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
            try {
              // 네비게이션 스택이 있으면 pop, 없으면 홈으로 이동
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/home');
              }
            } catch (e) {
              print('💥 뒤로가기 에러: $e');
              // 에러 발생 시 홈으로 이동
              context.go('/home');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 상태 표시
          : _dailyMessages.isEmpty
          ? Center(child: Text('메시지를 불러올 수 없습니다.')) // 데이터 없을 때
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 동적으로 날짜별 메세지 렌더링
                  ..._dailyMessages.map(
                    (message) => _buildDailyMessageCard(message),
                  ),
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
                  ],
                ),
              ),
              // 재생/일시정지 버튼
              Positioned(
                bottom: 13,
                right: 13,
                child: InkWell(
                  onTap: () =>
                      _togglePlayPause(message.title, message.audioUrl),
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
