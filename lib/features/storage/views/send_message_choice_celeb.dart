import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/main/repos/celeb_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SendMessageChoiceCeleb extends ConsumerStatefulWidget {
  static const String routeName = "sendMessageChoiceCeleb";
  static const String routePath = "/sendMessageChoiceCeleb";

  const SendMessageChoiceCeleb({super.key});

  @override
  ConsumerState<SendMessageChoiceCeleb> createState() =>
      _SendMessageChoiceCelebState();
}

class _SendMessageChoiceCelebState
    extends ConsumerState<SendMessageChoiceCeleb> {
  List<CelebModel> _celebs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 셀럽 데이터 로딩
      final celebRepo = CelebRepo();
      final celebs = await celebRepo.getCelebs();

      if (celebs == null) {
        throw Exception("셀럽 데이터가 null입니다.");
      }

      if (mounted) {
        setState(() {
          _celebs = celebs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ 데이터 로딩 실패: $e");
      if (mounted) {
        setState(() {
          _error = "데이터를 불러올 수 없습니다.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.size20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "어떤 셀럽의\n목소리를 원하나요?",
                      style: TextStyle(
                        fontSize: Sizes.size28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.v20,
                    Expanded(
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _error != null
                          ? Center(child: Text(_error!))
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // 한 줄에 3개
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 20,
                                    childAspectRatio:
                                        0.8, // 높이를 조금 더 주어서 이름까지 들어가게
                                  ),
                              itemCount: _celebs.length,
                              itemBuilder: (context, index) {
                                final celeb = _celebs[index];

                                return GestureDetector(
                                  onTap: () {
                                    // 모든 셀럽 선택 가능
                                    context.push(
                                      '/generateMessage',
                                      extra: celeb,
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade200,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              child: _buildCelebImage(celeb),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Gaps.v8,
                                      Text(
                                        celeb.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  // 셀럽 이미지 빌드 (공통 함수)
  Widget _buildCelebImage(CelebModel celeb) {
    return Image.network(
      AppConfig.getImageUrl(celeb.imagePath),
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: Icon(Icons.person, size: 40, color: Colors.grey.shade500),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
            ),
          ),
        );
      },
    );
  }
}
