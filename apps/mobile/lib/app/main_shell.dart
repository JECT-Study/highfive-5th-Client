import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/theme/app_colors.dart';
import '../shared/theme/app_spacing.dart';
import '../shared/theme/app_typography.dart';
import '../shared/widgets/app_icon.dart';

/// 하단 탭 4개(홈·팀 모집·메시지·마이페이지)를 감싸는 화면.
/// `StatefulShellRoute`가 탭마다 내비게이션 스택을 따로 유지한다. 탭 순서는 router.dart의 branches 순서와 같다.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

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
      bottomNavigationBar: MainTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

/// Figma NavEX. 흰 바탕 + 위쪽 구분선, 탭 4개를 같은 폭으로 나눈다.
///
/// 크기·간격은 Figma NavEX 그대로(디자인 시스템에 없는 값이라 `_TabItem` 안에만 둔다), 색은 토큰.
class MainTabBar extends StatelessWidget {
  const MainTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    (icon: AppIcons.home, label: '홈'),
    (icon: AppIcons.search, label: '팀 모집'),
    (icon: AppIcons.message, label: '메시지'),
    (icon: AppIcons.my, label: '마이페이지'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.backgroundNormal,
        border: Border(top: BorderSide(color: context.colors.lineNeutral)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final (i, tab) in _tabs.indexed)
              Expanded(
                child: _TabItem(
                  icon: tab.icon,
                  label: tab.label,
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppIcons icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  // Figma NavEX: 위아래 12, 아이콘 22, 아이콘-라벨 간격 2, 라벨 11px (선택 Bold, 아니면 Regular).
  static const _iconSize = 22.0;
  static const _iconLabelGap = 2.0;
  static const _labelSize = 11.0;

  @override
  Widget build(BuildContext context) {
    // 선택: Neutral/Gray-800 (Figma 아이콘 기본색), 선택 안 됨: Interaction/Inactive.
    final color = selected
        ? context.colors.gray800
        : context.colors.interactionInactive;
    final style = context.textStyles.caption1Regular.copyWith(
      fontSize: _labelSize,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
      color: color,
    );

    // Figma에 눌림 효과가 없어 잉크(ripple) 없이 탭만 받는다.
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(icon, size: _iconSize, color: color),
              const SizedBox(height: _iconLabelGap),
              Text(label, style: style),
            ],
          ),
        ),
      ),
    );
  }
}
