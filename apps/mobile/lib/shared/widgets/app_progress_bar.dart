import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `ProgressBar`. 단계 막대: [total]칸 중 앞의 [current]칸을 진하게 칠한다.
/// [trailingLabel]에는 `1/3단계`처럼 화면이 정한 문구를 넣는다.
class AppStepProgress extends StatelessWidget {
  const AppStepProgress({
    super.key,
    required this.current,
    required this.total,
    this.title,
    this.trailingLabel,
  }) : assert(total > 0 && current >= 0 && current <= total);

  final int current;
  final int total;
  final String? title;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppProgressTokens.paddingX,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || trailingLabel != null)
            Row(
              spacing: AppProgressTokens.labelGap,
              children: [
                Expanded(
                  child: Text(
                    title ?? '',
                    style: textStyles.body1SemiBold.copyWith(
                      color: colors.labelNormal,
                    ),
                  ),
                ),
                if (trailingLabel != null)
                  Text(
                    trailingLabel!,
                    style: textStyles.caption1SemiBold.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(
              top: AppProgressTokens.barPaddingTop,
              bottom: AppProgressTokens.barPaddingBottom,
            ),
            child: Semantics(
              value: '$current/$total',
              child: Row(
                spacing: AppProgressTokens.segmentGap,
                children: [
                  for (var i = 0; i < total; i++)
                    Expanded(
                      child: Container(
                        height: AppProgressTokens.segmentHeight,
                        decoration: BoxDecoration(
                          color: i < current
                              ? colors.labelNormal
                              : colors.fillStrong,
                          borderRadius: BorderRadius.circular(
                            AppProgressTokens.segmentRadius,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
