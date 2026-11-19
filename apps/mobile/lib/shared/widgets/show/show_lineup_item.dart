import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';
import '../app_tag.dart';
import 'show_meta_text.dart';

/// Figma `LineUp` (공연페이지). `Property 1 = card`: 라인업에 합류한 팀 하나를 사진·이름·정보·셋리스트로 보인다.
class ShowLineupItem extends StatelessWidget {
  const ShowLineupItem({
    super.key,
    required this.name,
    this.roleLabel,
    this.details = const [],
    this.setList = const [],
    this.setListMoreLabel,
    this.image,
    this.onTap,
  });

  /// 팀 이름 (예: 소음공장).
  final String name;

  /// 이름 옆 진한 태그 (예: 주최). null이면 숨긴다 (Figma `showTag`).
  final String? roleLabel;

  /// 이름 아래 점으로 나눈 정보 (예: 록, 4명, 40분).
  final List<String> details;

  /// 셋리스트 곡 태그. [setListMoreLabel]과 함께 비어 있으면 줄을 숨긴다.
  final List<String> setList;

  /// 다 보이지 않은 곡 수 (예: +1).
  final String? setListMoreLabel;

  final ImageProvider? image;
  final VoidCallback? onTap;

  static const _imageSize = 35.0; // Figma: 팀 사진
  static const _chevronSize = 14.0; // Figma: chevron-right

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final hasSetList = setList.isNotEmpty || setListMoreLabel != null;

    return Semantics(
      button: onTap != null,
      child: Material(
        color: colors.backgroundAlternative,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3_5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x2,
              children: [
                Row(
                  spacing: AppSpacing.x2,
                  children: [
                    Container(
                      width: _imageSize,
                      height: _imageSize,
                      decoration: BoxDecoration(
                        color: colors.fillStrong,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        image: image == null
                            ? null
                            : DecorationImage(image: image!, fit: BoxFit.cover),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppSpacing.x0_5,
                        children: [
                          Row(
                            spacing: AppSpacing.x1,
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyles.body1Bold.copyWith(
                                    color: colors.labelNormal,
                                  ),
                                ),
                              ),
                              if (roleLabel != null)
                                AppTag(
                                  label: roleLabel!,
                                  style: AppTagStyle.filled,
                                ),
                            ],
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
                if (hasSetList)
                  Row(
                    spacing: AppSpacing.x2,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: AppSpacing.x1,
                          children: [
                            // 곡 이름이 길면 태그마다 말줄임표로 줄여 줄을 넘지 않게 한다.
                            for (final song in setList)
                              Flexible(child: AppTag(label: song)),
                          ],
                        ),
                      ),
                      if (setListMoreLabel != null)
                        Text(
                          setListMoreLabel!,
                          style: textStyles.caption1Medium.copyWith(
                            color: colors.labelAlternative,
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

/// Figma `LineUp` (공연페이지). `Property 1 = 모집중 · 합류 준비`: 라인업의 빈자리를 점선 상자와 안내 글로 보인다.
class ShowLineupPlaceholder extends StatelessWidget {
  const ShowLineupPlaceholder({super.key, required this.message});

  /// 예: 1팀 더 모집 중이에요, 합류한 팀이 순서대로 여기에 쌓여요.
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(color: colors.lineStrong),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundNormal,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x3_5),
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.body1Regular.copyWith(
              color: colors.labelAlternative,
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma `border-dashed` 1px 둥근 테두리. Flutter에는 점선 테두리가 없어 직접 그린다.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  static const _strokeWidth = 1.0; // Figma: border 1px
  static const _dashLength = 3.0; // Figma: 점선 한 칸
  static const _dashGap = 3.0; // Figma: 점선 빈칸

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final border = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(_strokeWidth / 2),
          const Radius.circular(AppRadius.md),
        ),
      );
    for (final metric in border.computeMetrics()) {
      for (
        var start = 0.0;
        start < metric.length;
        start += _dashLength + _dashGap
      ) {
        canvas.drawPath(metric.extractPath(start, start + _dashLength), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
