import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_tag.dart';
import 'show_meta_text.dart';

/// Figma `Date` `Property 1`.
/// normal = default(연한 테두리), today = today(오늘 일정, 진한 테두리), detail = Detail(테두리 없음, 상세 화면 머리).
enum ShowDateCardType { normal, today, detail }

/// Figma `Date` (공연페이지). 일정 한 칸: 왼쪽 날짜 상자(일·요일)와 오른쪽 일정 이름·정보·태그.
class ShowDateCard extends StatelessWidget {
  const ShowDateCard({
    super.key,
    required this.day,
    required this.weekday,
    required this.title,
    this.type = ShowDateCardType.normal,
    this.details = const [],
    this.bandLabel,
    this.tags = const [],
    this.onTap,
  });

  /// 날짜 상자의 일 (예: 28).
  final String day;

  /// 날짜 상자의 요일 (예: 월).
  final String weekday;

  /// 일정 이름 (예: 합동 리허설).
  final String title;

  final ShowDateCardType type;

  /// 이름 아래 점으로 나눈 정보 (예: 14:00, 장소).
  final List<String> details;

  /// 정보 뒤 작은 회색 태그 (예: 밴드명). null이면 숨긴다 (Figma `showBandTag`).
  final String? bandLabel;

  /// 이름 아래 큰 회색 태그 (Detail의 예: 준비 중).
  final List<String> tags;

  final VoidCallback? onTap;

  static const _minHeight = 72.0; // Figma: 카드 높이
  static const _dayBoxWidth = 46.0; // Figma: 날짜 상자 폭
  static const _bandTagMaxWidth = 60.0; // Figma: 밴드명 태그 최대 폭

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final border = switch (type) {
      ShowDateCardType.normal => BorderSide(color: colors.lineNormal),
      ShowDateCardType.today => BorderSide(color: colors.labelNormal),
      ShowDateCardType.detail => BorderSide.none,
    };
    final (
      dayBackground,
      dayColor,
      weekdayColor,
    ) = type == ShowDateCardType.normal
        ? (colors.fillStrong, colors.labelNormal, colors.labelAlternative)
        : (colors.labelNormal, colors.staticWhite, colors.labelAssistive);
    final hasInfo = details.isNotEmpty || bandLabel != null || tags.isNotEmpty;

    return Semantics(
      button: onTap != null,
      child: Material(
        type: MaterialType.transparency,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minHeight),
            // Figma 위아래 여백은 12지만 날짜 상자(약 54)가 그 안(48)보다 커서,
            // 최소 높이 72 안에서 가운데 맞추고 여백은 8만 둔다.
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3_5,
                vertical: AppSpacing.x2,
              ),
              child: Row(
                spacing: AppSpacing.x2_5,
                children: [
                  Container(
                    width: _dayBoxWidth,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x1,
                    ),
                    decoration: BoxDecoration(
                      color: dayBackground,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day,
                          maxLines: 1,
                          style: textStyles.head.copyWith(color: dayColor),
                        ),
                        Text(
                          weekday,
                          maxLines: 1,
                          style: textStyles.caption1Regular.copyWith(
                            color: weekdayColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.x1_5,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.title2Bold.copyWith(
                            color: colors.labelNormal,
                          ),
                        ),
                        if (hasInfo)
                          Row(
                            spacing: type == ShowDateCardType.detail
                                ? AppSpacing.x2
                                : AppSpacing.x1,
                            children: [
                              if (details.isNotEmpty)
                                Flexible(child: ShowMetaText(details)),
                              if (bandLabel != null)
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _bandTagMaxWidth,
                                  ),
                                  child: AppTag(label: bandLabel!),
                                ),
                              for (final tag in tags)
                                Flexible(
                                  child: AppTag(
                                    label: tag,
                                    size: AppTagSize.large,
                                  ),
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
      ),
    );
  }
}
