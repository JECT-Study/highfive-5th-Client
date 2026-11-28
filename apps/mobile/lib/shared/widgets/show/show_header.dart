import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_tag.dart';

/// Figma `Header` (show). 공연 화면 위쪽 머리: 포스터, 상태·D-day 태그, 제목, 장르.
///
/// 기본 생성자는 Property 1 = false: 화면 폭 포스터 아래 요약과 공연 정보([infoRows]).
/// [ShowHeader.compact]는 Property 1 = true: 왼쪽 작은 포스터와 정보 수정 버튼.
class ShowHeader extends StatelessWidget {
  const ShowHeader({
    super.key,
    required this.title,
    required this.statusLabel,
    required String this.infoTitle,
    required this.infoRows,
    this.dDayLabel,
    this.genres = const [],
    this.poster,
  }) : _compact = false,
       editLabel = null,
       onEdit = null;

  const ShowHeader.compact({
    super.key,
    required this.title,
    required this.statusLabel,
    required String this.editLabel,
    required this.onEdit,
    this.dDayLabel,
    this.genres = const [],
    this.poster,
  }) : _compact = true,
       infoTitle = null,
       infoRows = const [];

  static const _bannerHeight = 180.0; // Figma: 큰 포스터 높이
  static const _thumbnailWidth = 100.0; // Figma: 작은 포스터 폭 (높이는 오른쪽 내용에 맞춘다)

  final bool _compact;
  final String title;

  /// 진한 태그 (예: 티켓 판매 중, 팀 모집 전). null이면 보이지 않는다 (예: 앱이 모르는 새 상태).
  final String? statusLabel;

  /// 옅은 태그 (예: D - 10).
  final String? dDayLabel;

  /// 제목 아래 회색 줄. 점으로 잇는다 (예: 록, 인디).
  final List<String> genres;
  final ImageProvider? poster;

  /// 공연 정보 제목 (예: 공연 정보). 기본 생성자에만 있다.
  final String? infoTitle;

  /// 공연 정보 줄들. 보통 [ShowHeaderInfoRow]를 넣는다.
  final List<Widget> infoRows;

  /// 정보 수정 버튼 글자. [ShowHeader.compact]에만 있다.
  final String? editLabel;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return _compact ? _buildCompact(context) : _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _bannerHeight,
          child: _Poster(image: poster),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x5,
            AppSpacing.x5,
            0,
          ),
          child: _summary(context),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.x5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x4,
            children: [
              Text(
                infoTitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.title1Bold.copyWith(
                  color: context.colors.labelNormal,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.x2_5,
                children: infoRows,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompact(BuildContext context) {
    // 포스터 높이를 오른쪽 내용 높이에 맞춘다 (Figma self-stretch).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x3_5,
        children: [
          SizedBox(
            width: _thumbnailWidth,
            child: _Poster(image: poster, radius: AppRadius.md),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.x3_5,
              children: [
                _summary(context),
                AppButton(
                  label: editLabel!,
                  onPressed: onEdit,
                  variant: AppButtonVariant.weak,
                  size: AppButtonSize.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 태그, 제목, 장르. 두 변형이 같이 쓴다.
  Widget _summary(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final statusLabel = this.statusLabel;
    final dDayLabel = this.dDayLabel;
    final genreStyle = textStyles.caption1Regular.copyWith(
      color: colors.labelAlternative,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x2_5,
      children: [
        if (statusLabel != null || dDayLabel != null)
          Row(
            spacing: AppSpacing.x1_5,
            children: [
              if (statusLabel != null)
                Flexible(
                  child: AppTag(
                    label: statusLabel,
                    style: AppTagStyle.filled,
                    size: AppTagSize.medium,
                  ),
                ),
              if (dDayLabel != null)
                Flexible(
                  child: AppTag(label: dDayLabel, size: AppTagSize.medium),
                ),
            ],
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.x1_5,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textStyles.title1Bold.copyWith(color: colors.labelNormal),
            ),
            if (genres.isNotEmpty)
              Row(
                spacing: AppSpacing.x1,
                children: [
                  for (final (i, genre) in genres.indexed) ...[
                    if (i > 0) const _Dot(),
                    Flexible(
                      child: Text(
                        genre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: genreStyle,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Figma `Header` 공연 정보의 한 줄 (show). 왼쪽 이름(날짜·시간·장소)과 값.
///
/// 정해지지 않은 값(Figma `미정`)은 [pending]으로 흐리게 하고, [detail]은 점 뒤에 붙인다 (예: 미정 · 서울 마포구).
class ShowHeaderInfoRow extends StatelessWidget {
  const ShowHeaderInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.pending = false,
    this.detail,
  });

  static const _labelWidth = 40.0; // Figma: 날짜·시간·장소 칸 폭

  final String label;
  final String value;
  final bool pending;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textStyles.body1Medium;
    final muted = style.copyWith(color: colors.labelAlternative);
    final normal = style.copyWith(color: colors.labelNormal);
    final detail = this.detail;
    return Row(
      spacing: AppSpacing.x3,
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: muted,
          ),
        ),
        Expanded(
          child: Row(
            spacing: AppSpacing.x1,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pending ? muted : normal,
                ),
              ),
              if (detail != null) ...[
                const _Dot(),
                Flexible(
                  child: Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 포스터 자리. 이미지가 없으면 회색(fillStrong)만 칠한다.
class _Poster extends StatelessWidget {
  const _Poster({required this.image, this.radius});

  final ImageProvider? image;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    final radius = this.radius;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.fillStrong,
        borderRadius: radius == null ? null : BorderRadius.circular(radius),
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
    );
  }
}

/// Figma `Ellipse` 2 × 2 점. 회색 글자 사이를 나눈다.
class _Dot extends StatelessWidget {
  const _Dot();

  static const _size = 2.0; // Figma: Ellipse 2 × 2

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: context.colors.labelAlternative,
        shape: BoxShape.circle,
      ),
    );
  }
}
