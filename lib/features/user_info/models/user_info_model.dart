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

    // birthday가 있으면 추가
    if (birthday != null) {
      data['birthday'] = birthday!.toIso8601String();
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

    // introduce는 기타 정보들로 구성
    List<String> introduceParts = [];
    if (selectedAttitude != null) {
      introduceParts.add('말투: $selectedAttitude');
    }
    if (birthTime != null) {
      introduceParts.add('출생시간: $birthTime');
    }
    if (isLunar != null) {
      introduceParts.add('음력여부: ${isLunar! ? '음력' : '양력'}');
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
