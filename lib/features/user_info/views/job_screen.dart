import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/user_info/views/mbti_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BirthdayScreen extends StatefulWidget {
  static const String routeName = "birthday";

  const BirthdayScreen({super.key});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  DateTime? _selectedDate;
  bool _isLunar = false; // false: 양력, true: 음력

  void _onNextTap(BuildContext context) {
    if (_selectedDate != null) {
      // 선택된 날짜와 양력/음력 정보와 함께 다음 화면으로 이동
      print("선택된 날짜: $_selectedDate, ${_isLunar ? '음력' : '양력'}");
      context.pushNamed(MbtiScreen.routeName);
    } else {
      // 날짜를 선택하지 않았을 때 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생일을 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onPressIconButton(BuildContext context) {
    context.pop();
  }

  // 날짜 선택기 표시
  Future<void> _selectDate(BuildContext context) async {
    print("날짜 선택 버튼 클릭됨!");

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xff463e8d),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      print("날짜 선택됨: $picked");
    }
  }

  // 양력/음력 선택 버튼 위젯
  Widget _buildCalendarTypeButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff9e9ef4) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xff9e9ef4) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontSize: Sizes.size14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "생일",
          style: TextStyle(fontSize: Sizes.size20, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.size36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gaps.v80,
            const Text(
              "언제 태어나셨나요?",
              style: TextStyle(
                fontSize: Sizes.size24,
                fontWeight: FontWeight.w700,
              ),
            ),
            Gaps.v16,
            const Text(
              "생일을 입력해주세요",
              style: TextStyle(
                fontSize: Sizes.size16,
                color: Color(0xff868e96),
              ),
            ),
            Gaps.v40,

            // 날짜 선택기와 양력/음력 버튼을 같은 Row에 배치
            Row(
              children: [
                // 날짜 선택 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate != null
                                  ? "${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일"
                                  : "날짜를 선택해주세요",
                              style: TextStyle(
                                fontSize: Sizes.size16,
                                color: _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey.shade500,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Gaps.h12,

                // 양력/음력 선택 버튼들
                Row(
                  children: [
                    _buildCalendarTypeButton("양력", !_isLunar, () {
                      setState(() {
                        _isLunar = false;
                      });
                    }),
                    Gaps.v8,
                    _buildCalendarTypeButton("음력", _isLunar, () {
                      setState(() {
                        _isLunar = true;
                      });
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
