import 'package:celeb_voice/router.dart';
import 'package:celeb_voice/services/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:naver_login_sdk/naver_login_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DioService 초기화 확인
  DioService().init();
  print('🔧 DioService 초기화 완료');

  // 네이버 로그인 SDK 초기화
  NaverLoginSDK.initialize(
    urlScheme: 'com.example.celebVoice', // iOS용
    clientId: 'oohNqpOV6pom7AsYsYne',
    clientSecret: 'VYTsuML5sV',
    clientName: 'flutter-social', // 네이버 개발자센터의 애플리케이션 이름과 일치
  );

  KakaoSdk.init(nativeAppKey: 'e1b50342b8edb35b7eb4e09d6b1fa33f');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Celeb Voice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(
            // 뒤로가기 버튼 스타일 설정
          ),
        ),
      ),
    );
  }
}
