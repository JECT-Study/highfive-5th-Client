import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_icon.dart';

/// Figma `Component` `Property 1`.
/// inquiry = Inquiry(줄 전체를 눌러 확인), link = Link(링크 + 진한 복사 버튼), copy = copy(제목·마감 + 테두리 복사 버튼).
enum ShowActionRowType { inquiry, link, copy }

/// Figma `Component` (공연페이지). 회색 줄 하나에 제목과 행동(확인하기·복사)을 둔다. 진행 카드 안팎에서 쓴다.
class ShowActionRow extends StatelessWidget {
  const ShowActionRow({
    super.key,
    required this.type,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.caption,
  });

  final ShowActionRowType type;

  /// 왼쪽 글자 (예: 새 문의 2건, highfive.link/asdfa, 관객 신청 링크).
  final String title;

  /// 제목 뒤 작은 회색 글자 (예: 19:00 마감).
  final String? caption;

  /// inquiry는 오른쪽 글자(확인하기), link·copy는 버튼 글자(복사).
  final String actionLabel;

  /// inquiry는 줄 전체, link·copy는 버튼을 누르면 부른다. null이면 누를 수 없다.
  final VoidCallback? onAction;

  static const _height = 47.0; // Figma: 줄 높이
  static const _chevronSize = 14.0; // Figma: 오른쪽 화살표

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final isInquiry = type == ShowActionRowType.inquiry;
    final tappable = isInquiry && onAction != null;

    final Widget trailing = switch (type) {
      ShowActionRowType.inquiry => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.x2,
        children: [
          Text(
            actionLabel,
            style: textStyles.caption1Regular.copyWith(
              color: colors.labelAlternative,
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
      // Figma Btn Mini. 앞 아이콘은 Figma에서 자리표시(test1)라 복사 아이콘으로 둔다.
      ShowActionRowType.link || ShowActionRowType.copy => AppButton(
        label: actionLabel,
        onPressed: onAction,
        size: AppButtonSize.small,
        variant: type == ShowActionRowType.link
            ? AppButtonVariant.fill
            : AppButtonVariant.weak,
        icon: const Icon(Icons.content_copy),
      ),
    };

    final Widget row = SizedBox(
      height: _height,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.x3_5,
          right: isInquiry ? AppSpacing.x3_5 : AppSpacing.x2,
        ),
        child: Row(
          spacing: AppSpacing.x2,
          children: [
            Expanded(
              child: Row(
                spacing: AppSpacing.x2,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (isInquiry
                                  ? textStyles.body1SemiBold
                                  : textStyles.body1Medium)
                              .copyWith(color: colors.labelNormal),
                    ),
                  ),
                  if (caption != null)
                    Flexible(
                      child: Text(
                        caption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.caption1Regular.copyWith(
                          color: colors.labelAlternative,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );

    return Semantics(
      button: tappable,
      child: Material(
        color: colors.backgroundAlternative,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: tappable ? InkWell(onTap: onAction, child: row) : row,
      ),
    );
  }
}
