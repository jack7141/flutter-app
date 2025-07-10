import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/view_models/user_info_view_model.dart';
import 'package:celeb_voice/features/user_info/views/birthday_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:celeb_voice/features/user_info/widgets/interest_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// MBTI 선택 화면
const mbti = [
  "ISTJ",
  "ISFJ",
  "INFJ",
  "INTJ",
  "ISTP",
  "ISFP",
  "INFP",
  "INTP",
  "ESTP",
  "ESFP",
  "ENFP",
  "ESTJ",
  "ESFJ",
  "ENTP",
  "ENTJ",
  "ENFJ",
];

class MbtiScreen extends ConsumerWidget {
  static const String routeName = "mbti";
  final CelebModel? celeb; // 셀럽 정보 추가

  const MbtiScreen({super.key, this.celeb});

  void _onMbtiSelected(String mbtiType, WidgetRef ref) {
    print("🎯 MbtiScreen - MBTI 선택됨: $mbtiType");
    ref.read(userInfoProvider.notifier).updateMbti(mbtiType);
  }

  void _onNextTap(BuildContext context, WidgetRef ref) {
    final userInfo = ref.read(userInfoProvider);

    print("🔍 MbtiScreen - 다음 버튼 클릭");
    print("🔍 현재 선택된 MBTI: ${userInfo.selectedMbti}");

    if (userInfo.selectedMbti != null) {
      print("✅ MBTI 선택됨 - Birthday 화면으로 이동");

      if (celeb != null) {
        print("🎭 셀럽 정보와 함께 이동: ${celeb!.name}");
        context.push('/birthday', extra: celeb);
      } else {
        print("🎭 셀럽 정보 없이 이동");
        context.pushNamed(BirthdayScreen.routeName);
      }
    } else {
      print("❌ MBTI 미선택 - 스낵바 표시");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('MBTI를 선택해주세요')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    print("🏗️ MbtiScreen build 호출됨");
    print("🔍 현재 상태 - 선택된 MBTI: ${userInfo.selectedMbti}");

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CelebAvatar(currentCeleb: celeb),
              Gaps.v20,
              Text(
                "MBTI가 뭐예요?",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              Container(
                child: SingleChildScrollView(
                  child: Wrap(
                    runSpacing: Sizes.size8,
                    spacing: Sizes.size8,
                    children: [
                      for (var mbtiType in mbti)
                        GestureDetector(
                          onTap: () {
                            print("👆 MBTI 버튼 탭됨: $mbtiType");
                            _onMbtiSelected(mbtiType, ref);
                          },
                          child: InterestButton(
                            interest: mbtiType,
                            id: 0,
                            isSelected: userInfo.selectedMbti == mbtiType,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Gaps.v24,
              GestureDetector(
                onTap: () => _onNextTap(context, ref),
                child: FormButton(text: '이런 성격이에요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
