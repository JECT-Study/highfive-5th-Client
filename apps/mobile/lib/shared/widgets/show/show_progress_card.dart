import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_progress_bar.dart';
import 'show_meta_text.dart';

/// Figma `ProgressCard` `Property 1`.
/// beforeRecruit = 모집전(진행 막대 없음), recruiting = 모집중(1/3단계),
/// ticketSales = 티켓판매(2/3단계), showDay = 공연당일(3/3단계).
enum ShowProgressStage { beforeRecruit, recruiting, ticketSales, showDay }

/// 진행 카드의 버튼 하나. [icon]은 글자 앞 아이콘(24). onPressed가 null이면 비활성.
typedef ShowProgressAction = ({
  String label,
  VoidCallback? onPressed,
  Widget? icon,
});

/// Figma `ProgressCard` (공연페이지). 합동공연 준비 단계 카드: 진행 막대, 제목·설명, 그 단계의 정보 줄과 버튼.
///
/// 버튼 모양은 단계가 정한다. 모집전·공연당일은 진한 버튼을 가로로 꽉 채우고,
/// 모집중·티켓판매는 연한 버튼을 나란히 둔다. 공연당일 카드 아래 줄(관객 신청 링크)은 [footer]에 넣는다.
class ShowProgressCard extends StatelessWidget {
  const ShowProgressCard({
    super.key,
    required this.stage,
    required this.title,
    this.stepLabel,
    this.stepTrailingLabel,
    this.description,
    this.details = const [],
    this.info,
    this.actions = const [],
    this.footer,
  });

  final ShowProgressStage stage;

  /// 카드 제목 (예: 3팀 확정, 1팀 더 모집 중).
  final String title;

  /// 진행 막대 위 왼쪽 글자 (예: 팀 모집). 모집전에는 진행 막대가 없어 쓰지 않는다.
  final String? stepLabel;

  /// 진행 막대 위 오른쪽 글자 (예: 1/3단계).
  final String? stepTrailingLabel;

  /// 제목 아래 설명 (예: 공고 마감까지 7일 남았어요).
  final String? description;

  /// 제목 아래 점으로 나눈 숫자 정보 (예: 신청 34명, 입금 확인 28명, 남은 자리 30석).
  final List<String> details;

  /// 버튼 위 내용: `ShowActionRow`, `ShowStatSummary` 등.
  final Widget? info;

  final List<ShowProgressAction> actions;

  /// 카드 아래 따로 두는 줄 (공연당일의 관객 신청 링크 `ShowActionRow`).
  final Widget? footer;

  static const _totalSteps = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final currentStep = switch (stage) {
      ShowProgressStage.beforeRecruit => null,
      ShowProgressStage.recruiting => 1,
      ShowProgressStage.ticketSales => 2,
      ShowProgressStage.showDay => 3,
    };
    // Figma: 칸 사이는 모집전만 16, 나머지 14. 정보 줄과 버튼 사이는 공연당일만 14, 나머지 8.
    final (gap, actionGap) = switch (stage) {
      ShowProgressStage.beforeRecruit => (AppSpacing.x4, AppSpacing.x2),
      ShowProgressStage.recruiting ||
      ShowProgressStage.ticketSales => (AppSpacing.x3_5, AppSpacing.x2),
      ShowProgressStage.showDay => (AppSpacing.x3_5, AppSpacing.x3_5),
    };
    final emphasized =
        stage == ShowProgressStage.beforeRecruit ||
        stage == ShowProgressStage.showDay;

    final Widget? buttons = actions.isEmpty
        ? null
        : emphasized
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x2,
            children: [
              for (final action in actions)
                AppButton(
                  label: action.label,
                  onPressed: action.onPressed,
                  icon: action.icon,
                  size: AppButtonSize.medium,
                ),
            ],
          )
        : Row(
            spacing: AppSpacing.x2_5,
            children: [
              for (final action in actions)
                Expanded(
                  child: AppButton(
                    label: action.label,
                    onPressed: action.onPressed,
                    icon: action.icon,
                    size: AppButtonSize.medium,
                    variant: AppButtonVariant.weak,
                  ),
                ),
            ],
          );

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundNormal,
        border: Border.all(color: colors.labelNormal),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3_5,
          vertical: AppSpacing.x5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: [
            if (currentStep != null)
              AppStepProgress(
                current: currentStep,
                total: _totalSteps,
                title: stepLabel,
                trailingLabel: stepTrailingLabel,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.x2,
                children: [
                  Text(
                    title,
                    style: textStyles.title2Bold.copyWith(
                      color: colors.labelNormal,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: textStyles.body1Regular.copyWith(
                        color: colors.labelAlternative,
                      ),
                    ),
                  if (details.isNotEmpty)
                    ShowMetaText(details, size: ShowMetaTextSize.body),
                ],
              ),
            ),
            if (info != null || buttons != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: actionGap,
                children: [?info, ?buttons],
              ),
          ],
        ),
      ),
    );

    if (footer == null) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x3,
      children: [card, footer!],
    );
  }
}
