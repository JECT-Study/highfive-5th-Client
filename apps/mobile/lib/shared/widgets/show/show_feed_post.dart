import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';
import '../app_top_bar.dart';
import 'show_meta_text.dart';

/// Figma `FeedTab` `Property 1`: text = Text(글만), image = Image(첨부 이미지 + 글).
enum ShowFeedPostType { text, image }

/// Figma `FeedTab` (공연페이지). 공연 피드의 글 하나: 글쓴이·시간·공개 범위, 본문(과 이미지), 반응·댓글 수.
class ShowFeedPost extends StatelessWidget {
  const ShowFeedPost({
    super.key,
    required this.authorName,
    required this.body,
    required this.reactionCount,
    required this.commentLabel,
    required this.commentCount,
    required this.moreTooltip,
    this.type = ShowFeedPostType.text,
    this.details = const [],
    this.profileImage,
    this.image,
    this.reactionImage,
    this.onTap,
    this.onMoreTap,
  });

  /// 글쓴이 (예: 박기타).
  final String authorName;

  /// 이름 아래 점으로 나눈 정보 (예: 1일 전, 전체).
  final List<String> details;

  final String body;
  final ShowFeedPostType type;
  final ImageProvider? profileImage;

  /// image 변형의 첨부 이미지. null이면 회색 자리만 그린다.
  final ImageProvider? image;

  /// 아래 줄 첫 묶음의 작은 사진(16)과 숫자. Figma에서는 `Profile` 자리표시라 무엇을 셀지는 화면이 정한다.
  final ImageProvider? reactionImage;
  final String reactionCount;

  /// 예: 댓글.
  final String commentLabel;
  final String commentCount;

  /// 더보기 버튼을 읽어 주는 이름 (예: 더보기).
  final String moreTooltip;

  final VoidCallback? onTap;

  /// 더보기(점 3개)를 누르면 부른다. null이면 눌리지 않는다.
  final VoidCallback? onMoreTap;

  static const _profileSize = 32.0; // Figma: 글쓴이 사진
  static const _imageHeight = 100.0; // Figma: 첨부 이미지 높이
  static const _reactionImageSize = 16.0; // Figma: 아래 줄 작은 사진
  static const _reactionImageRadius = 2.0; // Figma: 아래 줄 작은 사진 모서리

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final countStyle = textStyles.tag2.copyWith(color: colors.labelAlternative);

    final header = Row(
      spacing: AppSpacing.x2_5,
      children: [
        Container(
          width: _profileSize,
          height: _profileSize,
          decoration: BoxDecoration(
            color: colors.fillStrong,
            shape: BoxShape.circle,
            image: profileImage == null
                ? null
                : DecorationImage(image: profileImage!, fit: BoxFit.cover),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.x1,
            children: [
              Text(
                authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyles.body1Medium.copyWith(
                  color: colors.labelNormal,
                ),
              ),
              if (details.isNotEmpty) ShowMetaText(details),
            ],
          ),
        ),
        AppIconButton(
          // Figma 아이콘은 가로 점 3개다. 세로 점 3개인 AppIcons.more를 눕혀 쓴다.
          icon: RotatedBox(
            quarterTurns: 1,
            child: AppIcon(AppIcons.more, color: colors.labelAlternative),
          ),
          tooltip: moreTooltip,
          onPressed: onMoreTap,
        ),
      ],
    );

    final footer = Row(
      spacing: AppSpacing.x3,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.x1,
          children: [
            Container(
              width: _reactionImageSize,
              height: _reactionImageSize,
              decoration: BoxDecoration(
                color: colors.fillStrong,
                borderRadius: BorderRadius.circular(_reactionImageRadius),
                image: reactionImage == null
                    ? null
                    : DecorationImage(image: reactionImage!, fit: BoxFit.cover),
              ),
            ),
            Text(reactionCount, style: countStyle),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.x1,
          children: [
            Text(
              commentLabel,
              style: textStyles.caption1Medium.copyWith(
                color: colors.labelAlternative,
              ),
            ),
            Text(commentCount, style: countStyle),
          ],
        ),
      ],
    );

    return Semantics(
      button: onTap != null,
      child: Material(
        type: MaterialType.transparency,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.lineNeutral),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          // 더보기 버튼은 누르는 영역이 44라 아이콘(24) 둘레에 10씩 빈 곳이 생긴다.
          // AppTopBar처럼 그만큼 카드 위·오른쪽 여백을 줄여 아이콘과 사진을 Figma 위치(위 14, 오른쪽 16)에 둔다.
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4,
              AppSpacing.x2_5,
              AppSpacing.x1_5,
              AppSpacing.x3_5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x1_5,
              children: [
                header,
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.x2_5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.x2_5,
                    children: [
                      if (type == ShowFeedPostType.image)
                        Container(
                          key: const ValueKey('showFeedPost_image'),
                          height: _imageHeight,
                          decoration: BoxDecoration(
                            color: colors.fillStrong,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            image: image == null
                                ? null
                                : DecorationImage(
                                    image: image!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      Text(
                        body,
                        style: textStyles.caption1Medium.copyWith(
                          color: colors.labelNormal,
                        ),
                      ),
                      footer,
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
