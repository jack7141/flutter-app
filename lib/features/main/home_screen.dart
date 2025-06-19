// lib/features/main/home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "home";
  static const String routePath = "/home";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("홈 화면 (셀럽과 대화)")));
  }
}
