import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

        // 로컬 assets 파일 사용
        await _audioPlayer.play(AssetSource('tts/cris.mp3'));

        // 재생 시작 후 로딩 상태 해제
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

  // Instagram Story 공유 함수 (간단한 방법)
  Future<void> _shareToInstagramStory() async {
    try {
      print('🚀 Instagram Story 공유 시작');

      setState(() {
        _isLoading = true;
      });

      // 1. 셀럽 이미지를 로컬에 다운로드
      String? localImagePath = await _downloadImageToLocal();

      if (localImagePath == null) {
        throw Exception('이미지 다운로드에 실패했습니다.');
      }

      print('📱 플랫폼: ${Platform.operatingSystem}');

      // 2. Instagram 앱 확인 및 공유
      bool success = false;

      if (Platform.isAndroid) {
        success = await _shareToInstagramAndroid(localImagePath);
      } else if (Platform.isIOS) {
        success = await _shareToInstagramIOS(localImagePath);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Instagram으로 공유되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Instagram이 없으면 일반 공유
        await _shareWithGeneralShare(localImagePath);
      }
    } catch (e) {
      print('❌ Instagram 공유 실패: $e');
      if (mounted) {
        // 실패 시 일반 공유로 대체
        String? localImagePath = await _downloadImageToLocal();
        if (localImagePath != null) {
          await _shareWithGeneralShare(localImagePath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('공유에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Android Instagram 공유
  Future<bool> _shareToInstagramAndroid(String imagePath) async {
    try {
      // Instagram 앱 직접 실행 시도
      final instagramUrl = Uri.parse('instagram://camera');

      if (await canLaunchUrl(instagramUrl)) {
        print('✅ Instagram 앱 발견, 실행 중...');
        await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);

        // 잠시 대기 후 이미지 공유
        await Future.delayed(Duration(seconds: 1));

        // 이미지 공유
        await Share.shareXFiles([
          XFile(imagePath),
        ], text: '${widget.celeb?.name ?? "셀럽"}의 목소리로 만든 메시지! #CelebVoice');

        return true;
      }
      return false;
    } catch (e) {
      print('❌ Android Instagram 공유 에러: $e');
      return false;
    }
  }

  // iOS Instagram 공유
  Future<bool> _shareToInstagramIOS(String imagePath) async {
    try {
      // Instagram 앱 확인
      final instagramUrl = Uri.parse('instagram://camera');

      if (await canLaunchUrl(instagramUrl)) {
        print('✅ Instagram 앱 발견, 실행 중...');
        await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);

        // 잠시 대기 후 이미지 공유
        await Future.delayed(Duration(seconds: 1));

        // 이미지 공유
        await Share.shareXFiles([
          XFile(imagePath),
        ], text: '${widget.celeb?.name ?? "셀럽"}의 목소리로 만든 메시지! #CelebVoice');

        return true;
      }
      return false;
    } catch (e) {
      print('❌ iOS Instagram 공유 에러: $e');
      return false;
    }
  }

  // 일반 공유 (Instagram이 없을 때)
  Future<void> _shareWithGeneralShare(String imagePath) async {
    try {
      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            '${widget.celeb?.name ?? "셀럽"}의 목소리로 만든 메시지! #CelebVoice\n\n📸 Instagram에서 Story로 공유해보세요!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지가 공유되었습니다! Instagram Story에 추가해보세요.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ 일반 공유 에러: $e');
    }
  }

  // 이미지를 로컬에 다운로드
  Future<String?> _downloadImageToLocal() async {
    try {
      final celeb = widget.celeb;
      if (celeb == null) {
        print('❌ celeb이 null입니다.');
        return null;
      }

      // 사용할 이미지 URL 결정
      String imageUrl = celeb.detailImagePath.isNotEmpty
          ? celeb.detailImagePath
          : celeb.imagePath;

      print('🔍 사용할 이미지 URL: $imageUrl');

      if (imageUrl.isEmpty) {
        print('❌ 이미지 URL이 비어있습니다.');
        return null;
      }

      print('📥 이미지 다운로드 시작: $imageUrl');

      // HTTP 요청으로 이미지 다운로드
      final response = await http.get(Uri.parse(imageUrl));

      print('📥 HTTP 응답 상태: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ HTTP 요청 실패: ${response.statusCode}');
        return null;
      }

      // 임시 디렉토리에 저장
      final directory = await getTemporaryDirectory();
      final fileName =
          'celeb_voice_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);

      print('✅ 이미지 저장 완료: ${file.path}');
      print('📊 파일 크기: ${response.bodyBytes.length} bytes');

      return file.path;
    } catch (e) {
      print('❌ 이미지 다운로드 에러: $e');
      return null;
    }
  }

  void _onSaveTap() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 저장 로직 수행 (기존 코드)
      // ... 저장 관련 코드 ...

      // 저장 완료 다이얼로그 표시
      _showSaveSuccessDialog();
    } catch (e) {
      print('💥 저장 실패: $e');

      // 저장 실패 다이얼로그 표시
      _showSaveErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 저장 성공 다이얼로그 (Instagram 공유 옵션 추가)
  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '생성한 음성 메시지가\n셀럽의 명예를 훼손하거나 허위사실에\n해당하지 않음을 확인합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(text: '음성 무단 사용, 허위 사실 생성 유포 등의 행위는 '),
                  TextSpan(
                    text: '관련 법령에 따라 민형사상 책임을 질 수 있습니다.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Column(
              children: [
                // Instagram 공유 버튼
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                      _shareToInstagramStory(); // Instagram 공유
                    },
                    icon: Icon(Icons.camera_alt, color: Colors.purple),
                    label: Text(
                      'Instagram Story에 공유하기',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // 기존 버튼들
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그만 닫기
                        },
                        child: Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          context.go('/home'); // 홈으로 이동
                        },
                        child: Text(
                          '확인',
                          style: TextStyle(
                            color: Color(0xff9e9ef4),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 저장 실패 다이얼로그
  void _showSaveErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '저장 실패',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              '메시지 저장 중 오류가 발생했습니다.\n다시 시도해주세요.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그만 닫기
                    },
                    child: Text(
                      '취소',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                      // 재시도 로직이 필요하면 여기에 추가
                    },
                    child: Text(
                      '확인',
                      style: TextStyle(
                        color: Color(0xff9e9ef4),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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
