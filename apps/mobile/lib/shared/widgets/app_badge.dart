import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `Badge`의 숫자 동그라미 (안 읽은 메시지 수 등). 지름 20 원 모양 그대로이고,
/// 99를 넘으면 `99+`로 보이며 글자가 원보다 크면 원 안에 맞게 줄인다.
/// 프로필 사진 위에 얹을 때는 화면이 `Stack`으로 위치를 정한다.
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: AppBadgeTokens.size,
      height: AppBadgeTokens.size,
      padding: const EdgeInsets.all(AppBadgeTokens.innerPadding),
      decoration: BoxDecoration(
        color: colors.labelStrong,
        shape: BoxShape.circle,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          count > 99 ? '99+' : '$count',
          style: context.textStyles.tag1.copyWith(color: colors.staticWhite),
        ),
      ),
    );
  }
}

/// Figma `Divider`. 화면 구역 사이 두꺼운 회색 띠. 얇은 구분선은 `Divider(color: context.colors.lineNeutral)`.
class AppSectionDivider extends StatelessWidget {
  const AppSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDividerTokens.thickness,
      color: context.colors.backgroundAlternative,
    );
  }
}
