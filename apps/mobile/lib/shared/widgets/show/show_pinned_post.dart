import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';
import 'show_meta_text.dart';

/// Figma `Container` (공연페이지). 피드 맨 위에 고정한 글 한 줄: 핀 아이콘, 제목, 글쓴이·시간, 오른쪽 화살표.
class ShowPinnedPost extends StatelessWidget {
  const ShowPinnedPost({
    super.key,
    required this.title,
    this.details = const [],
    this.onTap,
  });

  /// 글 제목. 한 줄을 넘으면 말줄임표로 줄인다.
  final String title;

  /// 제목 아래 점으로 나눈 정보 (예: 이름, 5시간 전).
  final List<String> details;

  final VoidCallback? onTap;

  static const _pinSize = 20.0; // Figma: 핀 아이콘 Frame
  static const _chevronSize = 14.0; // Figma: 오른쪽 화살표

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: onTap != null,
      child: Material(
        color: colors.fillStrong,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4,
              AppSpacing.x3,
              AppSpacing.x3_5,
              AppSpacing.x3,
            ),
            child: Row(
              spacing: AppSpacing.x2_5,
              children: [
                AppIcon(
                  AppIcons.pin,
                  size: _pinSize,
                  color: colors.labelNormal,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.x1,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.body1SemiBold.copyWith(
                          color: colors.labelNormal,
                        ),
                      ),
                      if (details.isNotEmpty) ShowMetaText(details),
                    ],
                  ),
                ),
                Transform.flip(
                  flipX: true,
                  child: AppIcon(
                    AppIcons.chevronLeft,
                    size: _chevronSize,
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
