import 'dart:ui'; // blur 효과를 위해 추가

import 'package:celeb_voice/config/app_config.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/main/repos/celeb_repo.dart';
import 'package:celeb_voice/features/subscription/services/subscription_service.dart'; // 추가
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
  List<String> _subscribedCelebIds = []; // 구독한 셀럽 ID 목록
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 셀럽 데이터와 구독 상태를 동시에 로딩
      final celebRepo = CelebRepo();
      final subscriptionService = SubscriptionService();

      final celebs = await celebRepo.getCelebs();
      final subscriptionStatus = await subscriptionService
          .getSubscriptionStatus();

      if (celebs == null) {
        throw Exception("셀럽 데이터가 null입니다.");
      }

      if (mounted) {
        setState(() {
          _celebs = celebs;
          _subscribedCelebIds = subscriptionStatus.subscribedCelebIds;
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

  // 구독 여부 확인
  bool _isSubscribed(String celebId) {
    return _subscribedCelebIds.contains(celebId);
  }

  @override
  Widget build(BuildContext context) {
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
                                final isSubscribed = _isSubscribed(celeb.id);

                                return GestureDetector(
                                  onTap: () {
                                    if (isSubscribed) {
                                      // 구독한 셀럽만 선택 가능
                                      context.push(
                                        '/sendMessage',
                                        extra: celeb,
                                      );
                                    } else {
                                      // 구독하지 않은 셀럽 클릭 시 구독 안내
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${celeb.name}을 구독해야 이용할 수 있습니다.',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
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
                                              child: isSubscribed
                                                  ? _buildCelebImage(
                                                      celeb,
                                                    ) // 구독한 경우 일반 이미지
                                                  : ImageFiltered(
                                                      // 구독하지 않은 경우 blur 처리
                                                      imageFilter:
                                                          ImageFilter.blur(
                                                            sigmaX: 3,
                                                            sigmaY: 3,
                                                          ),
                                                      child: _buildCelebImage(
                                                        celeb,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          // 구독하지 않은 경우 잠금 아이콘 표시
                                          if (!isSubscribed)
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Gaps.v8,
                                      Text(
                                        isSubscribed
                                            ? celeb.name
                                            : "셀럽", // 구독하지 않은 경우 "셀럽"으로 표시
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isSubscribed
                                              ? Colors.black
                                              : Colors.grey.shade600,
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
