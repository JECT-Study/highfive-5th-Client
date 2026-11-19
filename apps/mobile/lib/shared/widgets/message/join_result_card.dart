import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';

/// Figma `ResultCard` (메시지). 합동공연 합류 결과(합류·합류 실패) 안내와 다음 행동 버튼.
///
/// Figma `Property 1`(합류·합류실패)은 글자만 다르다.
class JoinResultCard extends StatelessWidget {
  const JoinResultCard({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x5),
      decoration: BoxDecoration(
        color: colors.backgroundAlternative,
        border: Border.all(color: colors.lineNeutral),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x2_5,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x2,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: textStyles.title1Bold.copyWith(
                  color: colors.labelNormal,
                ),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textStyles.body1Regular.copyWith(
                  color: colors.labelNeutral,
                ),
              ),
            ],
          ),
          // Figma: XL 버튼을 높이 42로 줄여 두었다. 높이가 같은 medium을 쓴다.
          AppButton(
            label: actionLabel,
            onPressed: onAction,
            size: AppButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
