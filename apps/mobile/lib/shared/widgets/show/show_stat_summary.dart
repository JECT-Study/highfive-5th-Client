import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma `Notice` (공연페이지). 이름은 Notice지만 숫자 요약이다: 칸마다 이름(입장 예정)과 값(70명)을 가운데 맞춰 나란히 보인다.
///
/// 안내·경고 띠 `AppNotice`와 헷갈리지 않게 이름을 바꿨다.
class ShowStatSummary extends StatelessWidget {
  const ShowStatSummary({super.key, required this.items});

  /// 칸마다 이름과 값. 칸은 같은 폭으로 나눈다.
  final List<({String label, String value})> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundAlternative,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          spacing: AppSpacing.x2,
          children: [
            for (final item in items)
              Expanded(
                // 화면 읽기 프로그램이 "입장 예정 70명"처럼 이름과 값을 한 번에 읽게 묶는다.
                child: MergeSemantics(
                  child: Column(
                    spacing: AppSpacing.x1_5,
                    children: [
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.caption1Regular.copyWith(
                          color: colors.labelAlternative,
                        ),
                      ),
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.body1SemiBold.copyWith(
                          color: colors.labelNormal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
