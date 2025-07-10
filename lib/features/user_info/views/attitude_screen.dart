import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/view_models/user_info_view_model.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AttitudeScreen extends ConsumerWidget {
  static const String routeName = "attitude";
  final CelebModel? celeb;

  const AttitudeScreen({super.key, this.celeb});

  void _onAttitudeSelected(
    String attitude,
    WidgetRef ref,
    BuildContext context,
  ) async {
    print("🎯 AttitudeScreen - 말투 선택됨: $attitude");

    // 말투 상태 업데이트
    ref.read(userInfoProvider.notifier).updateAttitude(attitude);

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('사용자 정보를 저장하고 있습니다...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    try {
      // 🆕 ViewModel을 통한 저장 (비즈니스 로직 포함)
      await ref.read(userInfoProvider.notifier).saveUserInfo();
      print("✅ 사용자 정보 저장 완료");

      if (context.mounted) {
        context.pop(); // 로딩 다이얼로그 닫기

        if (celeb != null) {
          print("🎭 셀럽 정보와 함께 구독 페이지로 이동: ${celeb!.name}");
          context.push('/home', extra: celeb);
        } else {
          print("🏠 홈으로 이동");
          context.go('/home');
        }
      }
    } catch (e) {
      print('❌ 사용자 정보 저장 실패: $e');
      if (context.mounted) {
        context.pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('정보 저장 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    print("🏗️ AttitudeScreen build 호출됨");
    print("🔍 현재 상태 - 선택된 말투: ${userInfo.selectedAttitude}");

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            children: [
              CelebAvatar(currentCeleb: celeb),
              Gaps.v20,
              Text(
                "질문이 많았네요,\n 어떤 사람인지 궁금했거든요 ㅎㅎ\n 마지막으로, 혹시 제가 어떻게 말하는게 편할까요?",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              GestureDetector(
                onTap: () {
                  print("👆 반말 버튼 탭됨");
                  _onAttitudeSelected('반말', ref, context);
                },
                child: _buildAttitudeButton('반말로 편하게 해주세요!'),
              ),
              Gaps.v20,
              GestureDetector(
                onTap: () {
                  print("👆 존댓말 버튼 탭됨");
                  _onAttitudeSelected('존댓말', ref, context);
                },
                child: _buildAttitudeButton('지금처럼 존댓말이 좋아요!'),
              ),
              Gaps.v20,
              GestureDetector(
                onTap: () {
                  print("👆 상관없음 버튼 탭됨");
                  _onAttitudeSelected('상관없음', ref, context);
                },
                child: _buildAttitudeButton('상관없어요, 편하신대로 해주세요'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttitudeButton(String text) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Sizes.size16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Sizes.size64),
          border: Border.all(color: const Color(0xff211772), width: 2.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: Sizes.size16,
            fontWeight: FontWeight.bold,
            color: Color(0xff211772),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
