import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/providers/user_info_provider.dart';
import 'package:celeb_voice/features/user_info/repos/hobby_repo.dart';
import 'package:celeb_voice/features/user_info/views/mbti_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:celeb_voice/features/user_info/widgets/interest_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class InterestScreen extends ConsumerStatefulWidget {
  static const String routeName = "interest";
  final CelebModel? celeb; // 셀럽 정보 추가

  const InterestScreen({super.key, this.celeb});

  @override
  ConsumerState<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends ConsumerState<InterestScreen> {
  final HobbyRepo _hobbyRepo = HobbyRepo();
  List<Map<String, dynamic>> hobbies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHobbies();
  }

  Future<void> _loadHobbies() async {
    print("🔄 취미 목록 로딩 시작");

    final hobbyList = await _hobbyRepo.getHobbies();

    setState(() {
      if (hobbyList != null) {
        hobbies = hobbyList;
        print("✅ 취미 목록 로딩 완료: ${hobbies.length}개");
      } else {
        print("❌ 취미 목록 로딩 실패");
      }
      isLoading = false;
    });
  }

  void _onInterestSelected(String interest, int id) {
    print("🎯 InterestScreen - 관심사 선택됨: $interest (ID: $id)");
    ref.read(userInfoProvider.notifier).updateInterests(interest, id);
  }

  void _onNextTap(BuildContext context) {
    final userInfo = ref.read(userInfoProvider);

    print("🔍 InterestScreen - _onNextTap 호출됨");
    print("🔍 InterestScreen - widget.celeb: ${widget.celeb?.name}");
    print("🔍 현재 선택된 관심사: ${userInfo.selectedInterests}");

    if (userInfo.selectedInterests.isNotEmpty) {
      if (widget.celeb != null) {
        print(
          "🔍 InterestScreen - MbtiScreen으로 실제 셀럽 전달: ${widget.celeb!.name}",
        );
        context.push('/mbti', extra: widget.celeb);
      } else {
        print("🔍 InterestScreen - 셀럽 데이터 없음");
        context.pushNamed(MbtiScreen.routeName);
      }
    } else {
      print("❌ 관심사 미선택 - 스낵바 표시");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('관심사를 최소 1개 이상 선택해주세요')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userInfoProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CelebAvatar(currentCeleb: widget.celeb), // 셀럽 정보 전달
              Gaps.v20,
              Text(
                "요즘 관심사가 뭐예요? (${userInfo.selectedInterests.length}/2)",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                Container(
                  child: SingleChildScrollView(
                    child: Wrap(
                      runSpacing: Sizes.size8,
                      spacing: Sizes.size8,
                      children: [
                        for (var hobby in hobbies)
                          InterestButton(
                            interest: hobby['name'],
                            id: hobby['id'],
                            isSelected: userInfo.selectedInterestIds.contains(
                              hobby['id'],
                            ),
                            onTap: () =>
                                _onInterestSelected(hobby['name'], hobby['id']),
                          ),
                      ],
                    ),
                  ),
                ),
              Gaps.v24,
              GestureDetector(
                onTap: isLoading ? null : () => _onNextTap(context),
                child: FormButton(text: '저는 이런 취미가 있어요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
