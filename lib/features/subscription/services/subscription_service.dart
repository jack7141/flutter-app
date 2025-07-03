import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_config.dart';

class SubscriptionStatus {
  final bool hasAnySubscription;
  final List<String> subscribedCelebIds;

  SubscriptionStatus({
    required this.hasAnySubscription,
    required this.subscribedCelebIds,
  });
}

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      if (AppConfig.enableDebugLogs) {
        print("🔍 구독 상태 조회 시작");
      }

      String? accessToken = await _storage.read(key: AppConfig.accessTokenKey);
      String? tokenType = await _storage.read(key: AppConfig.tokenTypeKey);

      if (accessToken == null) {
        if (AppConfig.enableDebugLogs) {
          print("❌ 액세스 토큰이 없습니다");
        }
        return SubscriptionStatus(
          hasAnySubscription: false,
          subscribedCelebIds: [],
        );
      }

      final response = await _dio.get(
        "${AppConfig.baseUrl}/api/v1/users/me/subscriptions/",
        options: Options(
          headers: {
            ...AppConfig.defaultHeaders,
            'Authorization': '${tokenType ?? 'Bearer'} $accessToken',
          },
        ),
      );

      if (AppConfig.enableDebugLogs) {
        print("📥 구독 상태 응답: ${response.data}");
      }

      if (response.statusCode == 200) {
        final subscribedCelebIds = List<String>.from(response.data ?? []);

        final subscriptionStatus = SubscriptionStatus(
          hasAnySubscription: subscribedCelebIds.isNotEmpty,
          subscribedCelebIds: subscribedCelebIds,
        );

        // 로컬 캐시에 저장
        await _saveSubscriptionStatusToLocal(subscriptionStatus);

        if (AppConfig.enableDebugLogs) {
          print("✅ 구독 상태 조회 완료: ${subscriptionStatus.hasAnySubscription}");
          print("📋 구독한 셀럽 수: ${subscriptionStatus.subscribedCelebIds.length}");
          print("📋 구독한 셀럽 ID들: ${subscriptionStatus.subscribedCelebIds}");
        }

        return subscriptionStatus;
      }

      return SubscriptionStatus(
        hasAnySubscription: false,
        subscribedCelebIds: [],
      );
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 구독 상태 조회 에러: $e");
        print("🔄 로컬 캐시에서 조회 시도");
      }

      // 에러 시 로컬 캐시 사용
      return await _getSubscriptionStatusFromLocal();
    }
  }

  // 로컬 캐시에 구독 상태 저장
  Future<void> _saveSubscriptionStatusToLocal(SubscriptionStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_any_subscription', status.hasAnySubscription);
      await prefs.setStringList(
        'subscribed_celeb_ids',
        status.subscribedCelebIds,
      );
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 로컬 저장 에러: $e");
      }
    }
  }

  // 로컬 캐시에서 구독 상태 조회
  Future<SubscriptionStatus> _getSubscriptionStatusFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAnySubscription = prefs.getBool('has_any_subscription') ?? false;
      final subscribedCelebIds =
          prefs.getStringList('subscribed_celeb_ids') ?? [];

      return SubscriptionStatus(
        hasAnySubscription: hasAnySubscription,
        subscribedCelebIds: subscribedCelebIds,
      );
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 로컬 조회 에러: $e");
      }

      return SubscriptionStatus(
        hasAnySubscription: false,
        subscribedCelebIds: [],
      );
    }
  }

  // 구독 완료 시 로컬 상태 업데이트
  Future<void> markCelebAsSubscribed(String celebId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscribedCelebIds =
          prefs.getStringList('subscribed_celeb_ids') ?? [];

      if (!subscribedCelebIds.contains(celebId)) {
        subscribedCelebIds.add(celebId);
        await prefs.setStringList('subscribed_celeb_ids', subscribedCelebIds);
        await prefs.setBool('has_any_subscription', true);

        if (AppConfig.enableDebugLogs) {
          print("✅ 셀럽 구독 상태 로컬 업데이트: $celebId");
        }
      }
    } catch (e) {
      if (AppConfig.enableDebugLogs) {
        print("💥 구독 상태 업데이트 에러: $e");
      }
    }
  }
}
