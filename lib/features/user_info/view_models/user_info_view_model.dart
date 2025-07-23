// lib/features/user_info/view_models/user_info_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_info_model.dart';
import 'user_info_service.dart';

class UserInfoViewModel extends StateNotifier<UserInfoModel> {
  final UserInfoService _service;

  UserInfoViewModel({UserInfoService? service})
    : _service = service ?? UserInfoService(),
      super(UserInfoModel()) {
    print("🏗️ UserInfoViewModel 생성됨");
  }

  // === 상태 업데이트 메서드들 ===

  void updateInterests(String interest, int interestId) {
    final newInterests = List<String>.from(state.selectedInterests);
    final newInterestIds = List<int>.from(state.selectedInterestIds);

    if (newInterestIds.contains(interestId)) {
      // 제거
      final index = newInterestIds.indexOf(interestId);
      newInterests.removeAt(index);
      newInterestIds.removeAt(index);
      print("📝 관심사 제거: $interest");
    } else {
      // 추가 (최대 2개)
      if (newInterests.length >= 2) {
        print("⚠️ 최대 2개까지만 선택 가능");
        return;
      }
      newInterests.add(interest);
      newInterestIds.add(interestId);
      print("📝 관심사 추가: $interest");
    }

    state = state.copyWith(
      selectedInterests: newInterests,
      selectedInterestIds: newInterestIds,
    );
  }

  void updateMbti(String mbti) {
    print("📝 MBTI 업데이트: $mbti");
    state = state.copyWith(selectedMbti: mbti);
  }

  void updateBirthday(DateTime birthday, bool isLunar) {
    print("📝 생일 업데이트: $birthday (음력: $isLunar)");
    state = state.copyWith(birthday: birthday, isLunar: isLunar);
  }

  void updateBirthTime(String birthTime) {
    print("📝 출생시간 업데이트: $birthTime");
    state = state.copyWith(birthTime: birthTime);
  }

  void updateJob(String job, int jobId) {
    print("📝 직업 업데이트: $job (ID: $jobId)");
    state = state.copyWith(selectedJob: job, selectedJobId: jobId);
  }

  void updateAttitude(String attitude) {
    print("📝 말투 업데이트: $attitude");
    state = state.copyWith(selectedAttitude: attitude);
  }

  // === 비즈니스 로직 ===

  Future<void> saveUserInfo({bool isOnboarded = false}) async {
    // 파라미터 추가
    try {
      print("💾 사용자 정보 저장 시작 (온보딩 완료: $isOnboarded)");

      _validateUserInfo();
      await _service.saveUserInfo(state, isOnboarded: isOnboarded); // 파라미터 전달

      print("✅ 저장 완료");
      reset();
    } catch (e) {
      print("❌ 저장 실패: $e");
      rethrow;
    }
  }

  void _validateUserInfo() {
    final issues = <String>[];

    if (state.selectedInterestIds.isEmpty) issues.add("관심사 미선택");
    if (state.selectedMbti?.isEmpty ?? true) issues.add("MBTI 미선택");
    if (state.birthday == null) issues.add("생일 미선택");
    if (state.selectedJobId == null) issues.add("직업 미선택");
    if (state.selectedAttitude?.isEmpty ?? true) issues.add("말투 미선택");

    if (issues.isNotEmpty) {
      throw Exception('필수 정보 누락: ${issues.join(', ')}');
    }
  }

  // === 유틸리티 ===

  double get completionPercentage {
    int completed = 0;
    if (state.selectedInterests.isNotEmpty) completed++;
    if (state.selectedMbti != null) completed++;
    if (state.birthday != null) completed++;
    if (state.selectedJob != null) completed++;
    if (state.selectedAttitude != null) completed++;
    return completed / 5;
  }

  void reset() {
    print("🔄 상태 초기화");
    state = UserInfoModel();
  }

  void printCurrentState() {
    print("📋 현재 상태:");
    print("   관심사: ${state.selectedInterests}");
    print("   MBTI: ${state.selectedMbti}");
    print("   생일: ${state.birthday}");
    print("   직업: ${state.selectedJob}");
    print("   말투: ${state.selectedAttitude}");
    print("   완성도: ${(completionPercentage * 100).toStringAsFixed(1)}%");
  }
}

// Provider
final userInfoProvider =
    StateNotifierProvider<UserInfoViewModel, UserInfoModel>(
      (ref) => UserInfoViewModel(),
    );
