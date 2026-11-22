import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `ListRow`. 설정·메뉴 목록 한 줄. 앞 아이콘([leading])과 뒤 요소([trailing]: 화살표, 토글 등)는 선택.
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: AppListRowTokens.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppListRowTokens.paddingX,
          ),
          child: Row(
            spacing: AppListRowTokens.gap,
            children: [
              if (leading != null)
                IconTheme.merge(
                  data: IconThemeData(
                    color: colors.labelNormal,
                    size: AppListRowTokens.iconSize,
                  ),
                  child: SizedBox.square(
                    dimension: AppListRowTokens.iconSize,
                    child: leading,
                  ),
                ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.title2SemiBold.copyWith(
                    color: colors.labelNormal,
                  ),
                ),
              ),
              if (trailing != null)
                SizedBox(
                  width: AppListRowTokens.trailingWidth,
                  child: Center(child: trailing),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
