import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_tag.dart';

/// [AppBandCard] 위쪽 태그 하나 (Figma TagSquare XS의 글자와 모양).
typedef AppBandCardTag = ({String label, AppTagStyle style});

/// Figma `BandCard` (공통). 밴드 프로필·내 공연 목록에서 공연 하나를 포스터·태그·일정·장소로 보여 주는 카드.
class AppBandCard extends StatelessWidget {
  const AppBandCard({
    super.key,
    required this.title,
    required this.date,
    this.time,
    this.place,
    this.tags = const [],
    this.poster,
    this.onTap,
  });

  final String title;

  /// 공연 날짜 (예: `10.12(월)`).
  final String date;

  /// 시작 시각 (예: `19:00`). 없으면 날짜만 보인다.
  final String? time;

  /// 구분 점 뒤의 장소. 장소가 정해지지 않았으면 안내 문구를 넣는다 (Figma `장소가 확정되면 열 수 있어요`).
  final String? place;

  /// 티켓 상태(filled·outlined)·주최·D-day 같은 태그를 순서대로 놓는다.
  final List<AppBandCardTag> tags;

  /// 포스터. null이면 회색 자리를 그린다.
  final ImageProvider? poster;
  final VoidCallback? onTap;

  static const _posterWidth = 66.0; // Figma: 포스터 이미지 폭
  static const _posterHeight = 86.0; // Figma: 카드 높이 114 - 위아래 여백
  static const _dotSize = 2.0; // Figma: 일정과 장소 사이 구분 점

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final detailStyle = textStyles.caption1Regular.copyWith(
      color: colors.labelAlternative,
    );

    return Semantics(
      button: onTap != null,
      child: Material(
        type: MaterialType.transparency,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.lineStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x3_5),
            child: Row(
              spacing: AppSpacing.x3_5,
              children: [
                Container(
                  width: _posterWidth,
                  height: _posterHeight,
                  decoration: BoxDecoration(
                    color: colors.fillStrong,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    image: poster == null
                        ? null
                        : DecorationImage(image: poster!, fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.x2,
                    children: [
                      if (tags.isNotEmpty)
                        Wrap(
                          spacing: AppSpacing.x1_5,
                          runSpacing: AppSpacing.x1_5,
                          children: [
                            for (final tag in tags)
                              AppTag(label: tag.label, style: tag.style),
                          ],
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.x1,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textStyles.title2SemiBold.copyWith(
                              color: colors.labelNormal,
                            ),
                          ),
                          Row(
                            spacing: AppSpacing.x1,
                            children: [
                              Text(date, style: detailStyle),
                              if (time != null) Text(time!, style: detailStyle),
                              if (place != null) ...[
                                Container(
                                  key: const ValueKey('appBandCard_dot'),
                                  width: _dotSize,
                                  height: _dotSize,
                                  decoration: BoxDecoration(
                                    color: colors.labelAlternative,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    place!,
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
                    ],
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
