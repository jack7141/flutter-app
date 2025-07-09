class UserInfoModel {
  final List<String> selectedInterests;
  final List<int> selectedInterestIds;
  final String? selectedMbti;
  final DateTime? birthday;
  final bool? isLunar;
  final String? birthTime;
  final String? selectedJob;
  final int? selectedJobId;
  final String? selectedAttitude;

  UserInfoModel({
    List<String>? selectedInterests,
    List<int>? selectedInterestIds,
    this.selectedMbti,
    this.birthday,
    this.isLunar,
    this.birthTime,
    this.selectedJob,
    this.selectedJobId,
    this.selectedAttitude,
  }) : selectedInterests = selectedInterests ?? [],
       selectedInterestIds = selectedInterestIds ?? [];

  UserInfoModel copyWith({
    List<String>? selectedInterests,
    List<int>? selectedInterestIds,
    String? selectedMbti,
    DateTime? birthday,
    bool? isLunar,
    String? birthTime,
    String? selectedJob,
    int? selectedJobId,
    String? selectedAttitude,
  }) {
    return UserInfoModel(
      selectedInterests: selectedInterests ?? this.selectedInterests,
      selectedInterestIds: selectedInterestIds ?? this.selectedInterestIds,
      selectedMbti: selectedMbti ?? this.selectedMbti,
      birthday: birthday ?? this.birthday,
      isLunar: isLunar ?? this.isLunar,
      birthTime: birthTime ?? this.birthTime,
      selectedJob: selectedJob ?? this.selectedJob,
      selectedJobId: selectedJobId ?? this.selectedJobId,
      selectedAttitude: selectedAttitude ?? this.selectedAttitude,
    );
  }

  // API 스펙에 맞게 수정 - hobbies 배열로 변경
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    print("🔍 toJson() 호출됨");
    print("   selectedJobId: $selectedJobId");
    print("   selectedInterestIds: $selectedInterestIds");
    print("   birthday: $birthday");
    print("   birthTime: $birthTime");

    // birthday가 있으면 시간까지 포함해서 추가
    if (birthday != null) {
      DateTime finalBirthday = birthday!;

      // birthTime이 있고 "시간모름"이나 "미입력"이 아니면 시간 정보 파싱
      if (birthTime != null &&
          birthTime != "시간모름" &&
          birthTime != "미입력" &&
          birthTime!.isNotEmpty) {
        try {
          // "AM 09:30" 또는 "PM 14:30" 형태 파싱
          final parts = birthTime!.split(' ');
          if (parts.length == 2) {
            final amPm = parts[0];
            final timeParts = parts[1].split(':');
            if (timeParts.length == 2) {
              int hour = int.parse(timeParts[0]);
              int minute = int.parse(timeParts[1]);

              // PM이고 12시가 아니면 12시간 추가
              if (amPm == "PM" && hour != 12) {
                hour += 12;
              }
              // AM이고 12시면 0시로 변경
              else if (amPm == "AM" && hour == 12) {
                hour = 0;
              }

              // 날짜에 시간 정보 추가
              finalBirthday = DateTime(
                birthday!.year,
                birthday!.month,
                birthday!.day,
                hour,
                minute,
              );

              print("   ✅ 시간 정보 포함된 생일: $finalBirthday");
            }
          }
        } catch (e) {
          print("   ⚠️ 시간 파싱 실패: $e, 원본 날짜 사용");
        }
      } else {
        print("   ℹ️ 시간 정보 없음, 날짜만 사용");
      }

      data['birthday'] = finalBirthday.toIso8601String();
      print("   birthday 추가: ${data['birthday']}");
    }

    // mbti가 있으면 추가
    if (selectedMbti != null) {
      data['mbti'] = selectedMbti;
      print("   mbti 추가: ${data['mbti']}");
    }

    // job (소문자 j)
    if (selectedJobId != null && selectedJobId! > 0) {
      data['job'] = selectedJobId;
      print("   ✅ job 필드 추가: ${data['job']}");
    } else {
      print("   ❌ job 필드 누락 - selectedJobId: $selectedJobId");
    }

    // hobbies 배열 (최대 2개)
    if (selectedInterestIds.isNotEmpty) {
      data['hobbies'] = selectedInterestIds;
      print("   ✅ hobbies 필드 추가: ${data['hobbies']}");
    } else {
      print("   ❌ hobbies 필드 누락 - selectedInterestIds: $selectedInterestIds");
    }

    // is_lunar 추가 (음력 여부)
    if (isLunar != null) {
      data['is_lunar'] = isLunar;
      print("   is_lunar 추가: ${data['is_lunar']}");
    }

    // introduce는 말투 정보만 포함 (시간 정보는 birthday에 포함되므로 제외)
    List<String> introduceParts = [];
    if (selectedAttitude != null) {
      introduceParts.add('말투: $selectedAttitude');
    }

    if (introduceParts.isNotEmpty) {
      data['introduce'] = introduceParts.join(', ');
      print("   introduce 추가: ${data['introduce']}");
    }

    print("🔍 최종 JSON 데이터: $data");
    return data;
  }

  @override
  String toString() {
    return 'UserInfoModel(interests: $selectedInterests, mbti: $selectedMbti, birthday: $birthday, isLunar: $isLunar, birthTime: $birthTime, job: $selectedJob, attitude: $selectedAttitude)';
  }
}
