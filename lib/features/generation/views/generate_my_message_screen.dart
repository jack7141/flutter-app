import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class GernerateMessageScreen extends StatefulWidget {
  final CelebModel? celeb;
  static const String routeName = "generateMessage";
  static const String routePath = "/generateMessage";

  const GernerateMessageScreen({super.key, required this.celeb});

  @override
  State<GernerateMessageScreen> createState() => _GernerateMessageScreenState();
}

class _GernerateMessageScreenState extends State<GernerateMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _onNextTap(BuildContext context) async {
    final messageText = _messageController.text.trim();

    if (messageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('메시지를 입력해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.celeb == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('셀럽 정보를 찾을 수 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _generateMessage(context, messageText);
  }

  Future<void> _generateMessage(
    BuildContext context,
    String messageText,
  ) async {
    setState(() {
      _isLoading = true;
    });

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      final tokenType = await _secureStorage.read(key: 'token_type');

      if (accessToken == null) {
        throw Exception('액세스 토큰이 없습니다.');
      }

      print('📤 메시지 생성 API 호출: /api/v1/celeb/message/my/');
      print('📋 셀럽 ID: ${widget.celeb!.id}');
      print('📋 메시지: $messageText');

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await dio.post(
        '/api/v1/celeb/message/my/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
          },
        ),
        data: {'celebrity_id': widget.celeb!.id, 'request_text': messageText},
      );

      print('📥 메시지 생성 API 응답: ${response.statusCode}');
      print('📋 응답 데이터: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 메시지 생성 성공');

        // 다이얼로그 닫기
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        // TTS 페이지로 이동 (응답 데이터와 함께)
        if (context.mounted) {
          // API 응답 데이터에 셀럽 정보 추가
          final messageDataWithCeleb = Map<String, dynamic>.from(response.data);
          messageDataWithCeleb['celebrity'] = {
            'id': widget.celeb!.id,
            'name': widget.celeb!.name,
            'imagePath': widget.celeb!.imagePath,
            'tags': widget.celeb!.tags,
          };

          context.push(
            '/myMessageTts',
            extra: {
              'celeb': widget.celeb,
              'messageData': messageDataWithCeleb,
              'requestText': messageText,
            },
          );
        }
      } else {
        throw Exception('메시지 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 메시지 생성 에러: $e');

      // 다이얼로그 닫기
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e2) {
          print('다이얼로그 닫기 실패: $e2');
        }
      }

      // 에러 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지 생성 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 셀럽 정보 표시 위젯
  Widget _buildCelebInfo(CelebModel? celeb) {
    if (celeb == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Text(
              '셀럽을 선택해주세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              AppConfig.getImageUrl(celeb.imagePath),
            ),
            onBackgroundImageError: (exception, stackTrace) {
              print("셀럽 이미지 로딩 에러: $exception");
            },
            child: Container(), // 에러 시 기본 아바타 표시
          ),
          const SizedBox(width: 12),
          Text(
            celeb.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final celeb = widget.celeb;
    print("🔍 celeb: $celeb");

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
                "듣고 싶은 메세지를\n적어보세요.",
                style: TextStyle(
                  fontSize: Sizes.size28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              Container(
                padding: const EdgeInsets.all(4.0),
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
                    Container(
                      margin: const EdgeInsets.all(2.0),
                      child: _buildCelebInfo(celeb), // celeb 정보 표시
                    ),
                    Gaps.v12,
                    Container(
                      margin: const EdgeInsets.only(left: 2.0, right: 2.0),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "메세지를 입력해주세요",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gaps.v28,
              GestureDetector(
                onTap: _isLoading ? null : () => _onNextTap(context),
                child: FormButton(text: _isLoading ? '생성 중...' : '들어보기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
