import 'package:celeb_voice/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화 (실제 네이티브 앱 키로 교체 필요)
  KakaoSdk.init(
    nativeAppKey: 'e1b50342b8edb35b7eb4e09d6b1fa33f', // TODO: 실제 네이티브 앱 키로 교체
  );

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
