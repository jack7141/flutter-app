// lib/features/main/main_navigation_screen.dart

import 'package:celeb_voice/common/widgets/nav_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScreen extends StatefulWidget {
  static const String routeName = "main";

  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // 실제 라우팅 추가
    switch (index) {
      case 0:
        context.go("/home");
        break;
      case 1:
        context.go("/gernerateMessage");
        break;
      case 2:
        context.go("/voiceStorage");
        break;
      case 3:
        context.go("/profile");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            NavTab(
              text: "",
              isSelected: _selectedIndex == 0,
              icon: Icons.home,
              selectedIcon: Icons.home,
              onTap: () => _onTap(0),
              selectedIndex: _selectedIndex,
            ),
            NavTab(
              text: "",
              isSelected: _selectedIndex == 1,
              icon: Icons.add_circle,
              selectedIcon: Icons.add_circle,
              onTap: () => _onTap(1),
              selectedIndex: _selectedIndex,
            ),
            NavTab(
              text: "",
              isSelected: _selectedIndex == 2,
              icon: Icons.view_comfy_alt,
              selectedIcon: Icons.view_comfy_alt,
              onTap: () => _onTap(2),
              selectedIndex: _selectedIndex,
            ),
            NavTab(
              text: "",
              isSelected: _selectedIndex == 3,
              icon: Icons.person,
              selectedIcon: Icons.person,
              onTap: () => _onTap(3),
              selectedIndex: _selectedIndex,
            ),
          ],
        ),
      ),
    );
  }
}
