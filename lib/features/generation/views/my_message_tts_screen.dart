import 'package:audioplayers/audioplayers.dart';
import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyMessageTtsScreen extends StatefulWidget {
  final CelebModel? celeb;
  static const String routeName = "myMessageTts";
  static const String routePath = "/myMessageTts";

  const MyMessageTtsScreen({super.key, this.celeb});

  @override
  State<MyMessageTtsScreen> createState() => _MyMessageTtsScreenState();
}

class _MyMessageTtsScreenState extends State<MyMessageTtsScreen> {
  final TextEditingController _titleController = TextEditingController();
  late AudioPlayer _audioPlayer;

  // 오디오 재생 상태 관리
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    print("나만의 메세지 미리듣기 화면: ${widget.celeb}");
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();

    // 재생 상태 변화 리스너
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading =
              state == PlayerState.playing && _currentPosition == Duration.zero;
        });
      }
    });

    // 재생 위치 변화 리스너
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // 전체 길이 변화 리스너
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // 재생 완료 리스너
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // TTS 재생/일시정지 토글
  void _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() {
          _isLoading = true;
        });

        // 임시 TTS URL (실제로는 API에서 받아온 URL 사용)
        const String ttsUrl =
            'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav';

        await _audioPlayer.play(UrlSource(ttsUrl));

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ 오디오 재생 에러: $e");
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오디오 재생에 실패했습니다.')));
      }
    }
  }

  void _onSaveTap() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final celeb = widget.celeb;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Detail 이미지 영역 (화면의 대부분 차지)
            Expanded(
              flex: 8,
              child: Container(
                width: screenWidth,
                margin: EdgeInsets.all(Sizes.size16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Sizes.size16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Sizes.size16),
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Stack(
                      children: [
                        // 이미지
                        _buildCelebImage(celeb),

                        // 재생 버튼 오버레이
                        Positioned.fill(
                          child: Container(
                            child: Center(
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Icon(
                                        _isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),

                        // Progress Bar - 사진 하단에 오버레이
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                                stops: [0.0, 1.0],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 진행률 바
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1.5),
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(1.5),
                                    child: LinearProgressIndicator(
                                      value: _totalDuration.inMilliseconds > 0
                                          ? _currentPosition.inMilliseconds /
                                                _totalDuration.inMilliseconds
                                          : 0.0,
                                      backgroundColor: Color(0xff868e96),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xff463e8d),
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
                  ),
                ),
              ),
            ),

            // 저장 버튼
            Container(
              width: screenWidth,
              padding: EdgeInsets.all(Sizes.size20),
              child: GestureDetector(
                onTap: _isLoading ? null : _onSaveTap,
                child: FormButton(text: _isLoading ? '저장 중...' : '저장하기'),
              ),
            ),

            Gaps.v16,
          ],
        ),
      ),
    );
  }

  // 이미지 빌드 메서드
  Widget _buildCelebImage(CelebModel? celeb) {
    return celeb?.detailImagePath.isNotEmpty == true
        ? Image.network(
            celeb!.detailImagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print("🖼️ DETAIL 이미지 로딩 에러: $error");
              return celeb.imagePath.isNotEmpty == true
                  ? Image.network(
                      celeb.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackImage();
                      },
                    )
                  : _buildFallbackImage();
            },
          )
        : celeb?.imagePath.isNotEmpty == true
        ? Image.network(
            celeb!.imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackImage();
            },
          )
        : _buildFallbackImage();
  }

  // 폴백 이미지 위젯
  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 60, color: Colors.grey[600]),
          SizedBox(height: 8),
          Text(
            '이미지를 불러올 수 없습니다',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          if (widget.celeb?.name != null) ...[
            SizedBox(height: 4),
            Text(
              widget.celeb!.name,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
