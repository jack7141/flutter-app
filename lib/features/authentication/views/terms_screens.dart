import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/authentication/widgets/circular_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 이용약관 동의 화면
class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _agreeAll = false; // 전체 동의
  bool _agreeService = false; // 서비스 이용약관 동의
  bool _agreePrivacy = false; // 개인정보 수집 및 이용 동의
  bool _agreeMarketing = false; // 광고 및 마케팅 활용 동의

  // 전체 동의 체크박스 처리
  void _onAgreeAllChanged(bool value) {
    setState(() {
      _agreeAll = value;
      _agreeService = _agreeAll;
      _agreePrivacy = _agreeAll;
      _agreeMarketing = _agreeAll;
    });
  }

  // 개별 체크박스 처리
  void _onIndividualChanged() {
    setState(() {
      _agreeAll = _agreeService && _agreePrivacy && _agreeMarketing;
    });
  }

  void _onPressIconButton() {
    Navigator.of(context).pop();
  }

  // 다음 버튼 활성화 조건 (필수 항목만 체크되면 됨)
  bool get _canProceed => _agreeService && _agreePrivacy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "이용약관",
          style: TextStyle(fontSize: Sizes.size20, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => _onPressIconButton(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.size20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전체 동의
            Row(
              children: [
                CircularCheckbox(
                  value: _agreeAll,
                  onChanged: _onAgreeAllChanged,
                ),
                Gaps.h12,
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onAgreeAllChanged(!_agreeAll),
                    child: const Text(
                      "전체 동의",
                      style: TextStyle(
                        fontSize: Sizes.size18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Gaps.v10,

            // 구분선
            const Divider(),
            Gaps.v10,

            // 서비스 이용약관 동의 (필수)
            Row(
              children: [
                CircularCheckbox(
                  value: _agreeService,
                  onChanged: (value) {
                    setState(() {
                      _agreeService = value;
                    });
                    _onIndividualChanged();
                  },
                ),
                Gaps.h12,
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeService = !_agreeService;
                      });
                      _onIndividualChanged();
                    },
                    child: const Text(
                      "(필수) 서비스 이용약관 동의",
                      style: TextStyle(
                        color: Color(0xff463e8d),
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff868e96),
                  ),
                  onPressed: () {
                    // 약관 상세보기 기능
                  },
                  child: const Text(
                    "보기",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            Gaps.v10,

            // 개인정보 수집 동의 (필수)
            Row(
              children: [
                CircularCheckbox(
                  value: _agreePrivacy,
                  onChanged: (value) {
                    setState(() {
                      _agreePrivacy = value;
                    });
                    _onIndividualChanged();
                  },
                ),
                Gaps.h12,
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreePrivacy = !_agreePrivacy;
                      });
                      _onIndividualChanged();
                    },
                    child: const Text(
                      "(필수) 개인정보 수집 및 이용 동의",
                      style: TextStyle(
                        color: Color(0xff463e8d),
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff868e96),
                  ),
                  onPressed: () {
                    // 약관 상세보기 기능
                  },
                  child: const Text(
                    "보기",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            Gaps.v10,

            // 마케팅 동의 (선택)
            Row(
              children: [
                CircularCheckbox(
                  value: _agreeMarketing,
                  onChanged: (value) {
                    setState(() {
                      _agreeMarketing = value;
                    });
                    _onIndividualChanged();
                  },
                ),
                Gaps.h12,
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeMarketing = !_agreeMarketing;
                      });
                      _onIndividualChanged();
                    },
                    child: const Text(
                      "(선택) 광고 및 마케팅 활용 동의",
                      style: TextStyle(
                        color: Color(0xff463e8d),
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff868e96),
                  ),
                  onPressed: () {
                    // 약관 상세보기 기능
                  },
                  child: const Text(
                    "보기",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: _canProceed ? const Color(0xff9e9ef4) : Colors.grey,
        child: GestureDetector(
          onTap: _canProceed
              ? () {
                  // 뒤로가기 불가능하게 이동
                  context.pushReplacement('/welcome');
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "다음",
                style: TextStyle(
                  color: _canProceed ? Colors.white : Colors.white70,
                  fontSize: Sizes.size24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
