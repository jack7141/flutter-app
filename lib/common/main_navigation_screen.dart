// lib/features/main/main_navigation_screen.dart

import 'package:celeb_voice/common/widgets/nav_tab.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        context.go("/sendMessageChoiceCeleb");
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
      bottomNavigationBar: Container(
        height: 100, // 높이 제한 추가
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 5), // 상하 패딩 줄임
          child: Row(
            children: [
              NavTab(
                text: "",
                isSelected: _selectedIndex == 0,
                icon: FontAwesomeIcons.house,
                selectedIcon: FontAwesomeIcons.house,
                onTap: () => _onTap(0),
                selectedIndex: _selectedIndex,
              ),
              NavTab(
                text: "",
                isSelected: _selectedIndex == 1,
                icon: Icons.add_circle_outline,
                selectedIcon: Icons.add_circle_outline,
                onTap: () => _onTap(1),
                selectedIndex: _selectedIndex,
              ),
              NavTab(
                text: "",
                isSelected: _selectedIndex == 2,
                icon: FontAwesomeIcons.paperPlane,
                selectedIcon: FontAwesomeIcons.paperPlane,
                onTap: () => _onTap(2),
                selectedIndex: _selectedIndex,
              ),
              NavTab(
                text: "",
                isSelected: _selectedIndex == 3,
                icon: FontAwesomeIcons.user,
                selectedIcon: FontAwesomeIcons.user,
                onTap: () => _onTap(3),
                selectedIndex: _selectedIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
