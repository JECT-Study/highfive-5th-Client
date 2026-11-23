import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_icon.dart';
import '../app_tag.dart';

/// 숫자 칸 하나 (예: 신청 30, 입장 예정 70명).
typedef HomeShowStat = ({String label, String value});

/// 함께 공연하는 밴드 하나. image가 없으면 회색 자리를 그린다.
typedef HomeShowBand = ({String name, ImageProvider? image});

/// Figma `CardLarge`의 `Property 1`: default → summary, ticket → ticket, d-day → dDay.
/// add는 생김새가 전혀 달라 [HomeShowAddCard]로 나눴다.
enum HomeShowCardType { summary, ticket, dDay }

/// Figma `CardLarge` (홈). 홈에서 내가 연 공연 하나의 진행 상황을 보여 주는 큰 카드.
///
/// 가운데는 변형마다 다르다: summary = 숫자 칸, ticket = 함께 공연하는 밴드, dDay = 입장 현황.
/// 아래 버튼은 라벨을 준 것만 보인다 ([secondaryLabel] = 흐린 버튼, [primaryLabel] = 진한 버튼).
class HomeShowCard extends StatelessWidget {
  const HomeShowCard({
    super.key,
    required this.statusLabel,
    required this.title,
    this.type = HomeShowCardType.summary,
    this.roleLabel,
    this.details = const [],
    this.poster,
    this.stats = const [],
    this.bandsTitle,
    this.bands = const [],
    this.openSlotLabel,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.primaryLabel,
    this.onPrimaryPressed,
    this.onTap,
  });

  /// 진한 태그 (예: 티켓 판매 중, 공연 당일).
  final String statusLabel;
  final String title;
  final HomeShowCardType type;

  /// 진한 태그 옆 회색 태그 (예: 주최).
  final String? roleLabel;

  /// 제목 아래 정보. 가운뎃점으로 이어 한 줄로 보인다 (예: 날짜, 지역, 팀 수).
  final List<String> details;

  /// summary·ticket의 포스터. 없으면 회색 자리를 그린다.
  final ImageProvider? poster;

  /// summary·dDay의 숫자 칸.
  final List<HomeShowStat> stats;

  /// ticket의 밴드 목록 제목 (예: 함께 공연하는 밴드).
  final String? bandsTitle;
  final List<HomeShowBand> bands;

  /// ticket에서 밴드 뒤에 점선 빈 자리를 하나 더 두고 이 글자를 단다 (예: 모집 중).
  final String? openSlotLabel;

  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final String? primaryLabel;
  final VoidCallback? onPrimaryPressed;

  /// 카드를 눌렀을 때 (예: 공연 페이지 열기). null이면 카드 자체는 누를 수 없다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final hasPoster = type != HomeShowCardType.dDay;
    final Widget? body = switch (type) {
      HomeShowCardType.summary when stats.isNotEmpty => _StatBoxes(
        stats: stats,
      ),
      HomeShowCardType.ticket
          when bandsTitle != null ||
              bands.isNotEmpty ||
              openSlotLabel != null =>
        _Bands(title: bandsTitle, bands: bands, openSlotLabel: openSlotLabel),
      HomeShowCardType.dDay when stats.isNotEmpty => _StatPanel(stats: stats),
      _ => null,
    };

    return Semantics(
      button: onTap != null,
      child: Material(
        color: colors.backgroundNormal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.lineStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            // Figma: 좌우 15 → 16
            padding: const EdgeInsets.all(AppSpacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x4,
              children: [
                Row(
                  spacing: AppSpacing.x3_5,
                  children: [
                    if (hasPoster) _Poster(image: poster),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        // Figma: 포스터 옆은 16, d-day는 11 → 12
                        spacing: hasPoster ? AppSpacing.x4 : AppSpacing.x3,
                        children: [
                          Wrap(
                            spacing: AppSpacing.x1_5,
                            runSpacing: AppSpacing.x1,
                            children: [
                              AppTag(
                                label: statusLabel,
                                style: AppTagStyle.filled,
                                size: AppTagSize.medium,
                              ),
                              if (roleLabel case final role?)
                                AppTag(label: role, size: AppTagSize.medium),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: hasPoster ? AppSpacing.x2 : AppSpacing.x1,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyles.title1Bold.copyWith(
                                  color: colors.labelNormal,
                                ),
                              ),
                              if (details.isNotEmpty)
                                Text(
                                  // Figma: 2px 점(Ellipse) → 가운뎃점 글자
                                  details.join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyles.caption1Regular.copyWith(
                                    color: colors.labelAlternative,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ?body,
                if (secondaryLabel != null || primaryLabel != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.x1_5,
                    children: [
                      if (secondaryLabel case final label?)
                        AppButton(
                          label: label,
                          variant: AppButtonVariant.weak,
                          onPressed: onSecondaryPressed,
                        ),
                      if (primaryLabel case final label?)
                        AppButton(label: label, onPressed: onPrimaryPressed),
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

/// Figma `CardLarge` (홈). Property 1 = add, 공연을 새로 열고 팀을 모으러 가는 진한 카드.
class HomeShowAddCard extends StatelessWidget {
  const HomeShowAddCard({super.key, required this.label, required this.onTap});

  /// 줄을 나누려면 `\n`을 넣는다 (예: 공연 열고\n팀 모집하기).
  final String label;
  final VoidCallback? onTap;

  static const _minHeight = 217.0; // Figma: 다른 CardLarge와 같은 높이
  static const _paddingY = 18.0; // Figma: 위아래 여백

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: Material(
        color: colors.labelNormal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3_5,
                vertical: _paddingY,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.x2,
                children: [
                  AppIcon(AppIcons.add, color: colors.staticWhite),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: context.textStyles.title2SemiBold.copyWith(
                      color: colors.staticWhite,
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

/// 포스터 자리 (Figma `Image`). 이미지가 없으면 회색 둥근 네모.
class _Poster extends StatelessWidget {
  const _Poster({required this.image});

  final ImageProvider? image;

  static const _width = 80.0; // Figma: 포스터 폭
  static const _height = 100.0; // Figma: 포스터 높이

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('homeShowCard_poster'),
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: context.colors.fillStrong,
        borderRadius: BorderRadius.circular(AppRadius.md),
        image: switch (image) {
          final image? => DecorationImage(image: image, fit: BoxFit.cover),
          null => null,
        },
      ),
    );
  }
}

/// summary 숫자 칸: 칸마다 회색 상자 (Figma `Wrap` 안 `Container` 3개).
class _StatBoxes extends StatelessWidget {
  const _StatBoxes({required this.stats});

  final List<HomeShowStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.x2_5,
      children: [
        for (final stat in stats)
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.fillStrong,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x3),
                child: _Stat(stat: stat, gap: AppSpacing.x2_5),
              ),
            ),
          ),
      ],
    );
  }
}

/// d-day 입장 현황: 회색 띠 하나에 칸을 나란히 (Figma `Notice`).
class _StatPanel extends StatelessWidget {
  const _StatPanel({required this.stats});

  final List<HomeShowStat> stats;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.backgroundAlternative,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          spacing: AppSpacing.x2,
          children: [
            for (final stat in stats)
              Expanded(
                child: _Stat(stat: stat, gap: AppSpacing.x1_5),
              ),
          ],
        ),
      ),
    );
  }
}

/// 숫자 칸 하나: 위는 설명, 아래는 값.
class _Stat extends StatelessWidget {
  const _Stat({required this.stat, required this.gap});

  final HomeShowStat stat;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [
        Text(
          stat.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyles.caption1Medium.copyWith(
            color: colors.labelAlternative,
          ),
        ),
        Text(
          stat.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyles.title2SemiBold.copyWith(color: colors.labelNormal),
        ),
      ],
    );
  }
}

/// ticket의 함께 공연하는 밴드 (Figma `ProfileWrap`). 칸이 많으면 다음 줄로 넘긴다.
class _Bands extends StatelessWidget {
  const _Bands({
    required this.title,
    required this.bands,
    required this.openSlotLabel,
  });

  final String? title;
  final List<HomeShowBand> bands;
  final String? openSlotLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x2,
      children: [
        if (title case final title?)
          Text(
            title,
            style: context.textStyles.body1Medium.copyWith(
              color: context.colors.labelNormal,
            ),
          ),
        Wrap(
          spacing: AppSpacing.x2_5,
          runSpacing: AppSpacing.x2_5,
          children: [
            for (final band in bands)
              _BandSlot(label: band.name, image: band.image),
            if (openSlotLabel case final label?)
              _BandSlot(label: label, open: true),
          ],
        ),
      ],
    );
  }
}

/// 밴드 한 칸 (Figma `Profile`): 프로필 + 이름. [open]이면 점선 빈 자리와 흐린 글자.
class _BandSlot extends StatelessWidget {
  const _BandSlot({required this.label, this.image, this.open = false});

  final String label;
  final ImageProvider? image;
  final bool open;

  static const _width = 42.0; // Figma: 한 칸 폭
  static const _avatarSize = 40.0; // Figma: 프로필 크기
  static const _addIconSize = 18.0; // Figma: 빈 자리 add 아이콘

  // Figma: 프로필 모서리 15 → 16
  static const _radius = AppRadius.xl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: _width,
      child: Column(
        spacing: AppSpacing.x1_5,
        children: [
          SizedBox.square(
            dimension: _avatarSize,
            child: open
                ? CustomPaint(
                    painter: _DashedBorderPainter(
                      color: colors.lineStrong,
                      radius: _radius,
                    ),
                    child: Center(
                      child: AppIcon(
                        AppIcons.add,
                        size: _addIconSize,
                        color: colors.gray800,
                      ),
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.fillStrong,
                      borderRadius: BorderRadius.circular(_radius),
                      image: switch (image) {
                        final image? => DecorationImage(
                          image: image,
                          fit: BoxFit.cover,
                        ),
                        null => null,
                      },
                    ),
                  ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.tag2.copyWith(
              color: open ? colors.labelDisable : colors.labelAlternative,
            ),
          ),
        ],
      ),
    );
  }
}

/// 점선 둥근 테두리 (Figma `border-dashed`). Flutter 기본 테두리에는 점선이 없어 직접 그린다.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _strokeWidth = 1.0; // Figma: 테두리 두께
  static const _dash = 3.0; // 점선 한 칸 길이
  static const _gap = 3.0; // 점선 사이

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
          Radius.circular(radius),
        ),
      );
    for (final metric in border.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        canvas.drawPath(metric.extractPath(start, start + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
