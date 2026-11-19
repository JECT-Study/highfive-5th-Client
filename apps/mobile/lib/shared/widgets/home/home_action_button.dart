import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';

/// Figma 홈 섹션 `Btn`의 `Property 1`: addBtn → add(진한 바탕 + 더하기), searchBtn → search(테두리 + 검색).
enum HomeActionButtonType { add, search }

/// Figma `Btn` (홈). 홈 위쪽에 둘씩 나란히 놓는 큰 바로가기 버튼 (공연 열기·공연 찾기).
class HomeActionButton extends StatelessWidget {
  const HomeActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = HomeActionButtonType.add,
  });

  /// 줄을 나누려면 `\n`을 넣는다 (예: 공연 열고\n팀 모집하기).
  final String label;
  final VoidCallback? onPressed;
  final HomeActionButtonType type;

  static const _minHeight = 112.0; // Figma: 버튼 높이
  static const _paddingY = 18.0; // Figma: 위아래 여백

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground, border, icon) = switch (type) {
      HomeActionButtonType.add => (
        colors.labelNormal,
        colors.staticWhite,
        BorderSide.none,
        AppIcons.add,
      ),
      HomeActionButtonType.search => (
        colors.backgroundNormal,
        colors.labelNormal,
        BorderSide(color: colors.labelNormal),
        AppIcons.search,
      ),
    };

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3_5,
                vertical: _paddingY,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.x2,
                children: [
                  AppIcon(icon, color: foreground),
                  Text(
                    label,
                    style: context.textStyles.title2SemiBold.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
