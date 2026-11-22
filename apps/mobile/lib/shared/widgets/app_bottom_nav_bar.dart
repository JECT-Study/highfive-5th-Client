import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// 하단 탭 하나 (아이콘 + 라벨).
typedef AppBottomNavItem = ({AppIcons icon, String label});

/// Figma NavEX 하단 탭 바. 흰 바탕 + 위쪽 구분선, 탭을 같은 폭으로 나눈다.
/// 어떤 탭이 있는지와 누르면 어디로 갈지는 쓰는 쪽(`app/main_shell.dart`)이 정한다.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

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
            for (final (i, item) in items.indexed)
              Expanded(
                child: _NavItem(
                  item: item,
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 선택: 아이콘 Neutral/Gray-800(Figma 아이콘 기본색) + 라벨 Caption-1(SB) Label/Strong.
    // 선택 안 됨: 아이콘·라벨 Interaction/Inactive + Caption-1(R).
    final colors = context.colors;
    final iconColor = selected ? colors.gray800 : colors.interactionInactive;
    final style = selected
        ? context.textStyles.caption1SemiBold.copyWith(
            color: colors.labelStrong,
          )
        : context.textStyles.caption1Regular.copyWith(
            color: colors.interactionInactive,
          );

    // Figma에 눌림 효과가 없어 잉크(ripple) 없이 탭만 받는다.
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppBottomNavTokens.paddingY,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                item.icon,
                size: AppBottomNavTokens.iconSize,
                color: iconColor,
              ),
              const SizedBox(height: AppBottomNavTokens.iconLabelGap),
              Text(item.label, style: style),
            ],
          ),
        ),
      ),
    );
  }
}
