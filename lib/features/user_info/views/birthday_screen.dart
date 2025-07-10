import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/view_models/user_info_view_model.dart';
import 'package:celeb_voice/features/user_info/views/job_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BirthdayScreen extends ConsumerStatefulWidget {
  static const String routeName = "birthday";
  final CelebModel? celeb;

  const BirthdayScreen({super.key, this.celeb});

  @override
  ConsumerState<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends ConsumerState<BirthdayScreen> {
  DateTime? _selectedDate;
  bool _isLunar = false;
  TimeOfDay? _selectedTime;
  String _selectedAmPm = "AM";
  bool _timeUnknown = false;

  @override
  void initState() {
    super.initState();
    print("🏠 BirthdayScreen initState 호출됨");

    // initState에서는 ref.read 사용하지 않고, 첫 번째 build에서 복원
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Provider에서 기존 데이터 복원 (한 번만 실행)
    if (_selectedDate == null) {
      final userInfo = ref.read(userInfoProvider);
      if (userInfo.birthday != null) {
        setState(() {
          _selectedDate = userInfo.birthday;
          _isLunar = userInfo.isLunar ?? false;
        });
        print("🔄 기존 생일 데이터 복원: $_selectedDate (음력: $_isLunar)");
      }
    }
  }

  void _onNextTap(BuildContext context) {
    print("🔍 BirthdayScreen - 다음 버튼 클릭");
    print("🔍 선택된 날짜: $_selectedDate");
    print("🔍 음력여부: $_isLunar");
    print("🔍 선택된 시간: $_selectedTime");
    print("🔍 시간모름: $_timeUnknown");
    print("🔍 AM/PM: $_selectedAmPm");

    if (_selectedDate != null) {
      // 생일 정보 저장
      ref
          .read(userInfoProvider.notifier)
          .updateBirthday(_selectedDate!, _isLunar);

      // 출생시간 저장 (정확한 형태로)
      String birthTime;
      if (_timeUnknown) {
        birthTime = "시간모름";
      } else if (_selectedTime != null) {
        // 12시간 형식으로 저장 (AM/PM 포함)
        int displayHour = _selectedTime!.hour;
        String amPm = "AM";

        if (displayHour == 0) {
          displayHour = 12;
          amPm = "AM";
        } else if (displayHour == 12) {
          displayHour = 12;
          amPm = "PM";
        } else if (displayHour > 12) {
          displayHour = displayHour - 12;
          amPm = "PM";
        } else {
          amPm = "AM";
        }

        birthTime =
            "$amPm ${displayHour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";
      } else {
        birthTime = "미입력";
      }

      ref.read(userInfoProvider.notifier).updateBirthTime(birthTime);

      print("✅ 생일 정보 저장 완료 - Job 화면으로 이동");
      print("💾 저장된 출생시간: $birthTime");

      if (widget.celeb != null) {
        print("🎭 셀럽 정보와 함께 이동: ${widget.celeb!.name}");
        context.push('/job', extra: widget.celeb);
      } else {
        print("🎭 셀럽 정보 없이 이동");
        context.pushNamed(JobScreen.routeName);
      }
    } else {
      print("❌ 생일 미선택 - 스낵바 표시");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생일을 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    print("📅 날짜 선택 버튼 클릭됨!");

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
      print("✅ 날짜 선택됨: $picked");
    }
  }

  Future<void> _selectTime() async {
    if (_timeUnknown) {
      print("⚠️ 시간모름이 선택되어 있어 시간 선택 불가");
      return;
    }

    print("🕐 시간 선택 버튼 클릭됨!");

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
      print("✅ 시간 선택됨: ${picked.hour}:${picked.minute}");
    } else {
      print("❌ 시간 선택 취소됨");
    }
  }

  Widget _buildCalendarTypeButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        print("📅 달력 타입 변경: $text");
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

  Widget _buildTimeUnknownButton() {
    return GestureDetector(
      onTap: () {
        print("🕐 시간모름 버튼 클릭: ${!_timeUnknown}");
        setState(() {
          _timeUnknown = !_timeUnknown;
          if (_timeUnknown) {
            _selectedTime = null;
            print("🕐 시간모름 선택 - 기존 시간 초기화");
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
    print("🏗️ BirthdayScreen build 호출됨");

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
              Row(
                children: [
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
                            ),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final parentWidth = constraints.maxWidth;
                  final amPmWidth = parentWidth * 0.25;
                  final gapWidth = parentWidth * 0.03;
                  final timeWidth = parentWidth * 0.72;

                  return Row(
                    children: [
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
                                    print("🕐 AM/PM 변경: $newValue");
                                    setState(() {
                                      _selectedAmPm = newValue!;
                                    });
                                  },
                          ),
                        ),
                      ),
                      SizedBox(width: gapWidth),
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
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FormButton(text: '제 생일이에요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
