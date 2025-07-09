// lib/features/user_info/providers/user_info_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_info_model.dart';

class UserInfoNotifier extends StateNotifier<UserInfoModel> {
  UserInfoNotifier() : super(UserInfoModel()) {
    print("🏗️ UserInfoNotifier 생성됨");
  }

  // 관심사 업데이트
  void updateInterest(String interest, int interestId) {
    print("📝 [BEFORE] 관심사 업데이트 - 현재: ${state.selectedInterest}");
    state = state.copyWith(
      selectedInterest: interest,
      selectedInterestId: interestId,
    );
    print("✅ [AFTER] 관심사 업데이트 완료: $interest (ID: $interestId)");
    _printCurrentState();
  }

  // MBTI 업데이트
  void updateMbti(String mbti) {
    print("📝 [BEFORE] MBTI 업데이트 - 현재: ${state.selectedMbti}");
    state = state.copyWith(selectedMbti: mbti);
    print("✅ [AFTER] MBTI 업데이트 완료: $mbti");
    _printCurrentState();
  }

  // 생일 업데이트
  void updateBirthday(DateTime birthday, bool isLunar) {
    print("📝 [BEFORE] 생일 업데이트 - 현재: ${state.birthday}");
    state = state.copyWith(birthday: birthday, isLunar: isLunar);
    print("✅ [AFTER] 생일 업데이트 완료: $birthday (음력: $isLunar)");
    _printCurrentState();
  }

  // 출생시간 업데이트
  void updateBirthTime(String birthTime) {
    print("📝 [BEFORE] 출생시간 업데이트 - 현재: ${state.birthTime}");
    state = state.copyWith(birthTime: birthTime);
    print("✅ [AFTER] 출생시간 업데이트 완료: $birthTime");
    _printCurrentState();
  }

  // 직업 업데이트
  void updateJob(String job, int jobId) {
    print(
      "📝 [BEFORE] 직업 업데이트 - 현재: ${state.selectedJob} (ID: ${state.selectedJobId})",
    );
    print("📝 [INPUT] 새로운 직업: $job (ID: $jobId)");

    state = state.copyWith(selectedJob: job, selectedJobId: jobId);

    print(
      "✅ [AFTER] 직업 업데이트 완료: ${state.selectedJob} (ID: ${state.selectedJobId})",
    );
    _printCurrentState();
  }

  // 말투 업데이트
  void updateAttitude(String attitude) {
    print("📝 [BEFORE] 말투 업데이트 - 현재: ${state.selectedAttitude}");
    state = state.copyWith(selectedAttitude: attitude);
    print("✅ [AFTER] 말투 업데이트 완료: $attitude");
    _printCurrentState();
  }

  // 상태 초기화
  void reset() {
    print("🔄 사용자 정보 초기화 시작");
    state = UserInfoModel();
    print("✅ 사용자 정보 초기화 완료");
    _printCurrentState();
  }

  // 현재 상태 출력 (내부용)
  void _printCurrentState() {
    print("📋 === 현재 사용자 정보 상태 ===");
    print(
      "   관심사: ${state.selectedInterest} (ID: ${state.selectedInterestId})",
    );
    print("   MBTI: ${state.selectedMbti}");
    print("   생일: ${state.birthday}");
    print("   음력여부: ${state.isLunar}");
    print("   출생시간: ${state.birthTime}");
    print("   직업: ${state.selectedJob} (ID: ${state.selectedJobId})");
    print("   말투: ${state.selectedAttitude}");
    print("📋 ===============================");
  }

  // 외부에서 호출할 수 있는 상태 출력
  void printCurrentState() {
    _printCurrentState();
  }
}

// Provider 인스턴스
final userInfoProvider = StateNotifierProvider<UserInfoNotifier, UserInfoModel>(
  (ref) {
    print("🏭 userInfoProvider 생성됨");
    return UserInfoNotifier();
  },
);
