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

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    // 생일 처리
    if (birthday != null) {
      data['birthday'] = _formatBirthday().toIso8601String();
    }

    // 기본 필드들
    if (selectedMbti != null) data['mbti'] = selectedMbti;
    if (selectedJobId != null) data['job'] = selectedJobId;
    if (selectedInterestIds.isNotEmpty) data['hobbies'] = selectedInterestIds;
    if (isLunar != null) data['is_lunar'] = isLunar;

    return data;
  }

  DateTime _formatBirthday() {
    if (birthday == null) return DateTime.now();

    // 시간 정보가 있고 유효하면 파싱
    if (_isValidBirthTime()) {
      try {
        return _parseBirthTime();
      } catch (e) {
        print("⚠️ 시간 파싱 실패, 날짜만 사용: $e");
      }
    }

    return birthday!;
  }

  bool _isValidBirthTime() {
    return birthTime != null &&
        birthTime != "시간모름" &&
        birthTime != "미입력" &&
        birthTime!.isNotEmpty;
  }

  DateTime _parseBirthTime() {
    final parts = birthTime!.split(' ');
    if (parts.length != 2) throw Exception('Invalid time format');

    final amPm = parts[0];
    final timeParts = parts[1].split(':');
    if (timeParts.length != 2) throw Exception('Invalid time format');

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // 12시간 -> 24시간 변환
    if (amPm == "PM" && hour != 12) hour += 12;
    if (amPm == "AM" && hour == 12) hour = 0;

    return DateTime(
      birthday!.year,
      birthday!.month,
      birthday!.day,
      hour,
      minute,
    );
  }

  @override
  String toString() {
    return 'UserInfoModel(interests: $selectedInterests, mbti: $selectedMbti, birthday: $birthday, job: $selectedJob, attitude: $selectedAttitude)';
  }
}
