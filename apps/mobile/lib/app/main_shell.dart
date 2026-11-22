import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/app_bottom_nav_bar.dart';
import '../shared/widgets/app_icon.dart';

/// 하단 탭 4개(홈·팀 모집·메시지·마이페이지)를 감싸는 화면.
/// `StatefulShellRoute`가 탭마다 내비게이션 스택을 따로 유지한다. 탭 순서는 router.dart의 branches 순서와 같다.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// 순서 = router.dart의 branches 순서.
  static const tabs = <AppBottomNavItem>[
    (icon: AppIcons.home, label: '홈'),
    (icon: AppIcons.search, label: '팀 모집'),
    (icon: AppIcons.message, label: '메시지'),
    (icon: AppIcons.my, label: '마이페이지'),
  ];

  void _onTap(int index) {
    // 지금 탭을 다시 누르면 그 탭의 첫 화면으로 돌아간다.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        items: tabs,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
