import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_component_tokens.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_tag.dart';

/// Figma `MessageTag` (메시지). 문의 방향 태그(보낸 문의·받은 문의)와 그 앞의 진행 상태 태그(거절됨).
///
/// Figma `Property 1`(보낸문의·받은 문의)은 [label] 글자만 다르고, `showTag`는 [statusLabel]이 있을 때다.
class MessageTag extends StatelessWidget {
  const MessageTag({super.key, required this.label, this.statusLabel});

  /// 문의 방향 (예: 보낸 문의).
  final String label;

  /// 앞에 붙는 진행 상태 (예: 거절됨). null이면 그리지 않는다.
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.x1,
      children: [
        if (statusLabel case final status?) _StatusTag(label: status),
        AppRoundTag(label: label, size: AppRoundTagSize.medium),
      ],
    );
  }
}

/// TagRound L과 같은 모양에 글자만 보조색이다. [AppRoundTag]는 글자색을 바꿀 수 없어 같은 토큰으로 그린다.
class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.fillStrong,
        borderRadius: BorderRadius.circular(AppTagTokens.roundRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTagTokens.roundMediumPaddingX,
          vertical: AppTagTokens.roundMediumPaddingY,
        ),
        child: Text(
          label,
          style: context.textStyles.caption1SemiBold.copyWith(
            color: colors.labelAlternative,
          ),
        ),
      ),
    );
  }
}
