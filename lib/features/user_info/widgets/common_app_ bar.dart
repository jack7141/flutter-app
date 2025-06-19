// lib/common/widgets/common_app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // AppBar 제목 (선택 사항)
  final bool showBackButton; // 뒤로가기 버튼 표시 여부

  const CommonAppBar({super.key, this.title, this.showBackButton = true});
  void _onPressIconButton(BuildContext context) {
    // 뒤로 갈 페이지가 있는지 확인
    if (context.canPop()) {
      // 있다면 뒤로가기 실행
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            )
          : null,
      centerTitle: false,
      titleSpacing: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              // 기본 동작으로 '뒤로가기'를 실행합니다.
              onPressed: () => _onPressIconButton(context),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // AppBar의 표준 높이
}
