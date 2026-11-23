import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_tag.dart';

/// Figma `Notice` (홈). 홈에 쌓이는 새 소식 한 줄 (종류 태그 + 내용 + 시간).
class HomeNotice extends StatelessWidget {
  const HomeNotice({
    super.key,
    required this.tagLabel,
    required this.message,
    required this.timeLabel,
    this.onTap,
  });

  /// 소식 종류 (예: 문의).
  final String tagLabel;
  final String message;

  /// 지난 시간 (예: 방금).
  final String timeLabel;
  final VoidCallback? onTap;

  static const _tagMaxWidth = 60.0; // Figma: 태그 최대 폭

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Semantics(
      button: onTap != null,
      child: Material(
        color: colors.backgroundNormal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: colors.lineNeutral),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x3),
            child: Row(
              spacing: AppSpacing.x3,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _tagMaxWidth),
                  child: AppTag(label: tagLabel, size: AppTagSize.medium),
                ),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.caption1Regular.copyWith(
                      color: colors.labelNormal,
                    ),
                  ),
                ),
                Text(
                  timeLabel,
                  style: textStyles.caption1Regular.copyWith(
                    color: colors.labelAlternative,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
