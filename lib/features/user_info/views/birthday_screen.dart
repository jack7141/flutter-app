import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/views/job_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BirthdayScreen extends StatefulWidget {
  static const String routeName = "birthday";

  final CelebModel? celeb; // 셀럽 정보 추가
  const BirthdayScreen({super.key, this.celeb});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  DateTime? _selectedDate;
  bool _isLunar = false; // 양력(false) / 음력(true) 상태
  TimeOfDay? _selectedTime;
  String _selectedAmPm = "AM";
  bool _timeUnknown = false;

  void _onNextTap(BuildContext context) {
    if (_selectedDate != null) {
      // 셀럽 정보를 다음 화면에 전달
      if (widget.celeb != null) {
        context.push('/attitude', extra: widget.celeb);
      } else {
        context.pushNamed(JobScreen.routeName);
      }
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

  // 날짜 선택기 표시
  Future<void> _selectDate() async {
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

  // 시간 선택기 표시
  Future<void> _selectTime() async {
    if (_timeUnknown) return; // 시간모름이 체크되어 있으면 선택 불가

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
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
        _selectedTime = picked;
      });
    }
  }

  // 양력/음력 선택 버튼 위젯
  Widget _buildCalendarTypeButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLunar = text == "음력";
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.size20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(Sizes.size32),
          border: Border.all(
            color: isSelected
                ? const Color(0xff9e9ef4)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Color(0xff9e9ef4) : Colors.black87,
              fontSize: Sizes.size14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  // 시간모름 버튼 위젯 (양력/음력과 같은 디자인)
  Widget _buildTimeUnknownButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _timeUnknown = !_timeUnknown;
          if (_timeUnknown) {
            _selectedTime = null;
          }
        });
      },
      child: Container(
        width: 70,
        height: 32,
        decoration: BoxDecoration(
          color: _timeUnknown ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(Sizes.size32),
          border: Border.all(
            color: _timeUnknown
                ? const Color(0xff9e9ef4)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            "시간모름",
            style: TextStyle(
              color: _timeUnknown ? Color(0xff9e9ef4) : Colors.black87,
              fontSize: Sizes.size12,
              fontWeight: _timeUnknown ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
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
              CelebAvatar(currentCeleb: widget.celeb),
              Gaps.v20,
              Text(
                "생일은 언제에요?",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,

              // 날짜 선택 및 양력/음력 선택을 같은 Row에 배치
              Row(
                children: [
                  // 날짜 선택 부분
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.size16,
                          vertical: Sizes.size12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedDate != null
                                ? const Color(0xff463e8d)
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(Sizes.size8),
                          color: _selectedDate != null
                              ? const Color(0xff463e8d).withOpacity(0.05)
                              : Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.year}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.day.toString().padLeft(2, '0')}'
                                  : 'YYYY.MM.DD',
                              style: TextStyle(
                                fontSize: Sizes.size16,
                                color: _selectedDate != null
                                    ? const Color(0xff463e8d)
                                    : const Color(0xff868e96),
                                fontWeight: _selectedDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ), // 양력/음력 선택 버튼들
                            Row(
                              children: [
                                _buildCalendarTypeButton("양력", !_isLunar),
                                Gaps.h10,
                                _buildCalendarTypeButton("음력", _isLunar),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Gaps.v24,

              // 태어난 시간 입력 영역 - LayoutBuilder 사용
              LayoutBuilder(
                builder: (context, constraints) {
                  final parentWidth = constraints.maxWidth;
                  final amPmWidth = parentWidth * 0.25; // 25%
                  final gapWidth = parentWidth * 0.03; // 3%
                  final timeWidth = parentWidth * 0.72; // 72%

                  return Row(
                    children: [
                      // AM/PM 드롭다운
                      Container(
                        width: amPmWidth,
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: _timeUnknown
                              ? Colors.grey.shade100
                              : Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAmPm,
                            isExpanded: true,
                            items: ["AM", "PM"].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: _timeUnknown
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: Sizes.size14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: _timeUnknown
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _selectedAmPm = newValue!;
                                    });
                                  },
                          ),
                        ),
                      ),

                      // 간격
                      SizedBox(width: gapWidth),

                      // 시간 선택 + 시간모름 버튼
                      SizedBox(
                        width: timeWidth,
                        child: GestureDetector(
                          onTap: _timeUnknown ? null : _selectTime,
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _timeUnknown
                                    ? Colors.grey.shade300
                                    : (_selectedTime != null
                                          ? const Color(0xff463e8d)
                                          : Colors.grey.shade300),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: _timeUnknown
                                  ? Colors.grey.shade100
                                  : (_selectedTime != null
                                        ? const Color(
                                            0xff463e8d,
                                          ).withOpacity(0.05)
                                        : Colors.white),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _timeUnknown
                                      ? "시간모름"
                                      : (_selectedTime != null
                                            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                            : 'HH:MM'),
                                  style: TextStyle(
                                    fontSize: Sizes.size16,
                                    color: _timeUnknown
                                        ? Colors.grey
                                        : (_selectedTime != null
                                              ? const Color(0xff463e8d)
                                              : const Color(0xff868e96)),
                                    fontWeight: _selectedTime != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                // 시간모름 버튼 (양력/음력과 같은 디자인)
                                _buildTimeUnknownButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              Gaps.v24,
              // 다음 버튼
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FormButton(text: '제 생일이에요'),
              ),
              Gaps.v20,
            ],
          ),
        ),
      ),
    );
  }
}
