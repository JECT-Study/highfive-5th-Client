import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';

/// Figma `Container_PostLink` (메시지). 채팅방 위 공고 바로가기 띠: 공고 제목, 날짜·지역·장소, `공고 보기 >`.
///
/// Figma `Property 1`(공고보기·내공고보기)은 [actionLabel] 글자만 다르다. 띠 전체가 눌린다.
class PostLinkBar extends StatelessWidget {
  const PostLinkBar({
    super.key,
    required this.title,
    required this.details,
    required this.actionLabel,
    required this.onTap,
  });

  static const _dotSize = 2.0; // Figma: 정보 사이 점
  static const _chevronSize = 16.0; // Figma: 오른쪽 화살표 (16 목록 아이콘)

  final String title;

  /// 제목 아래 정보 (예: 11.07(토), 서울 마포구, 장소 미정). 사이에 점을 찍는다.
  final List<String> details;

  /// 오른쪽 글자 (예: 공고 보기, 내 공고 보기).
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final detailStyle = textStyles.caption1Regular.copyWith(
      color: colors.labelAlternative,
    );
    final dot = Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        color: colors.labelAlternative,
        shape: BoxShape.circle,
      ),
    );

    return Semantics(
      button: true,
      child: Material(
        color: colors.backgroundAlternative,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x5,
              vertical: AppSpacing.x2_5,
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.lineNeutral)),
            ),
            child: Row(
              spacing: AppSpacing.x4,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.x1,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.body1Medium.copyWith(
                            color: colors.labelStrong,
                          ),
                        ),
                        Row(
                          spacing: AppSpacing.x1,
                          children: [
                            for (final (i, detail) in details.indexed) ...[
                              if (i > 0) dot,
                              Flexible(
                                child: Text(
                                  detail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: detailStyle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel,
                      style: textStyles.caption1Medium.copyWith(
                        color: colors.labelStrong,
                      ),
                    ),
                    // 오른쪽 화살표는 왼쪽 화살표를 뒤집어 쓴다.
                    Transform.flip(
                      flipX: true,
                      child: AppIcon(
                        AppIcons.chevronLeft,
                        size: _chevronSize,
                        color: colors.labelStrong,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
