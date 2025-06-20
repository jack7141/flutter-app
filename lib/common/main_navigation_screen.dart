// lib/features/main/main_navigation_screen.dart

import 'package:celeb_voice/features/main/home_screen.dart';
import 'package:celeb_voice/features/user_info/views/welcome_screen.dart';
import 'package:celeb_voice/features/user_profile/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScreen extends StatefulWidget {
  static const String routeName = "main";

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<String> _tabs = ["home", "welcome", "userProfile"];
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    WelcomeScreen(),
    UserProfileScreen(),
  ];

  void _onTap(int index) {
    context.go("/${_tabs[index]}");
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack을 사용하면 _selectedIndex에 해당하는 화면만 보여줍니다.
      body: Stack(
        children: [
          Offstage(offstage: _selectedIndex != 0, child: const HomeScreen()),
          Offstage(offstage: _selectedIndex != 1, child: const WelcomeScreen()),
          Offstage(
            offstage: _selectedIndex != 2,
            child: const UserProfileScreen(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // 현재 선택된 탭을 시각적으로 표시
        onTap: _onTap, // 탭을 눌렀을 때 _onTap 함수 호출
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            activeIcon: Icon(Icons.star),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "",
          ),
        ],
      ),
    );
  }
}
