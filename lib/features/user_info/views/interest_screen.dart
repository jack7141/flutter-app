import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/repos/hobby_repo.dart';
import 'package:celeb_voice/features/user_info/views/mbti_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:celeb_voice/features/user_info/widgets/interest_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InterestScreen extends StatefulWidget {
  static const String routeName = "interest";
  final CelebModel? celeb; // 셀럽 정보 추가

  const InterestScreen({super.key, this.celeb});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
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

  void _onNextTap(BuildContext context) {
    print("🔍 InterestScreen - _onNextTap 호출됨");
    print("🔍 InterestScreen - widget.celeb: ${widget.celeb?.name}");

    if (widget.celeb != null) {
      print("🔍 InterestScreen - MbtiScreen으로 실제 셀럽 전달: ${widget.celeb!.name}");
      context.push('/mbti', extra: widget.celeb);
    } else {
      print("🔍 InterestScreen - 셀럽 데이터 없음");
      context.pushNamed(MbtiScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                "요즘 관심사가 뭐예요?",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                Wrap(
                  runSpacing: Sizes.size8,
                  spacing: Sizes.size8,
                  children: [
                    for (var hobby in hobbies)
                      InterestButton(interest: hobby['name'], id: hobby['id']),
                  ],
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
