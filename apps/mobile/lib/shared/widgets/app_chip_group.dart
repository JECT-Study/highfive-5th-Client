import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_chip.dart';

/// Figma `Chipwarp` (공통). 제목 아래에 [AppChip]을 줄바꿈해 늘어놓는 선택지 묶음 (예: 연주 장르).
class AppChipGroup extends StatelessWidget {
  const AppChipGroup({
    super.key,
    required this.labels,
    required this.selectedIndexes,
    required this.onTap,
    this.title,
  });

  /// 묶음 위 제목 (Figma 화면의 `연주 장르`). 없으면 칩만 보인다.
  final String? title;
  final List<String> labels;

  /// 고른 칩의 위치(0부터). 하나만·여러 개 고르기 규칙은 화면(ViewModel)이 정한다.
  final Set<int> selectedIndexes;

  /// 누른 칩의 위치를 넘긴다. null이면 칩을 누를 수 없다.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x2,
      children: [
        if (title != null)
          Text(
            title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.body1SemiBold.copyWith(
              color: context.colors.labelNormal,
            ),
          ),
        Wrap(
          spacing: AppSpacing.x2,
          runSpacing: AppSpacing.x2,
          children: [
            for (final (i, label) in labels.indexed)
              AppChip(
                label: label,
                selected: selectedIndexes.contains(i),
                onTap: onTap == null ? null : () => onTap(i),
              ),
          ],
        ),
      ],
    );
  }
}
