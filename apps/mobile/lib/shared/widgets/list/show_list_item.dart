import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';
import '../app_tag.dart';

/// Figma `List` (목록). 팀 모집 공고·찜 목록에서 합동공연 공고 하나를 포스터·태그·정보로 보여 주는 줄.
class ShowListItem extends StatelessWidget {
  const ShowListItem({
    super.key,
    required this.title,
    this.statusTags = const [],
    this.details = const [],
    this.tags = const [],
    this.poster,
    this.bookmarked = false,
    this.onBookmarkChanged,
    this.bookmarkSemanticLabel,
    this.onTap,
  });

  final String title;

  /// 제목 위 둥근 태그 (Figma TagRound L: `마감`, `D-10`).
  final List<String> statusTags;

  /// 제목 아래 정보. 구분 점으로 나눠 한 줄에 보인다 (예: `서울 마포구`, `장소 미정`, `연주 1~3년`).
  final List<String> details;

  /// 맨 아래 작은 둥근 태그 (Figma TagRound M: 장르 `록`, `팝`).
  final List<String> tags;

  /// 포스터. null이면 회색 자리를 그린다.
  final ImageProvider? poster;

  /// 찜했는지 (Figma IconBookmark `bookmark`).
  final bool bookmarked;

  /// 찜 아이콘을 누르면 바뀔 값(`!bookmarked`)을 넘긴다. null이면 아이콘만 보이고 눌리지 않는다.
  final ValueChanged<bool>? onBookmarkChanged;

  /// 찜 버튼의 읽히는 이름 (예: `찜하기`).
  final String? bookmarkSemanticLabel;

  /// 줄을 누를 때. 찜 아이콘을 누르는 영역은 제외된다.
  final VoidCallback? onTap;

  static const _posterWidth = 109.0; // Figma: 포스터 이미지 폭 (높이는 글 영역에 맞춘다)
  static const _posterRadius = 4.0; // Figma: 포스터 모서리 (AppRadius에 없는 값)
  static const _bookmarkSize = 20.0; // Figma: IconBookmark
  static const _bookmarkTouchSize = 44.0; // 찜 아이콘을 누르는 영역
  static const _dotSize = 2.0; // Figma: 정보 사이 구분 점

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final onBookmarkChanged = this.onBookmarkChanged;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x2,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x1,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.x1,
                      runSpacing: AppSpacing.x1,
                      children: [
                        for (final tag in statusTags)
                          AppRoundTag(label: tag, size: AppRoundTagSize.medium),
                      ],
                    ),
                  ),
                  AppIcon(
                    AppIcons.bookmark,
                    size: _bookmarkSize,
                    color: bookmarked
                        ? colors.labelNormal
                        : colors.labelAssistive,
                  ),
                ],
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyles.title2SemiBold.copyWith(
                  color: colors.labelNormal,
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) _DotSeparatedText(details),
          if (tags.isNotEmpty)
            Wrap(
              spacing: AppSpacing.x1_5,
              runSpacing: AppSpacing.x1_5,
              children: [
                for (final tag in tags)
                  AppRoundTag(label: tag, size: AppRoundTagSize.small),
              ],
            ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.lineNeutral)),
      ),
      child: Semantics(
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x2_5),
            // Figma: 포스터가 글 영역 높이만큼 늘어난다 (self-stretch).
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.x4,
                children: [
                  SizedBox(
                    width: _posterWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.fillStrong,
                        borderRadius: BorderRadius.circular(_posterRadius),
                        image: poster == null
                            ? null
                            : DecorationImage(
                                image: poster!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    // 찜 아이콘(20)은 줄 배치를 바꾸지 않고, 누르는 영역(44)만 위에 겹친다.
                    child: Stack(
                      children: [
                        content,
                        if (onBookmarkChanged != null)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Semantics(
                              button: true,
                              toggled: bookmarked,
                              label: bookmarkSemanticLabel,
                              child: GestureDetector(
                                key: const ValueKey('showListItem_bookmark'),
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onBookmarkChanged(!bookmarked),
                                child: const SizedBox.square(
                                  dimension: _bookmarkTouchSize,
                                ),
                              ),
                            ),
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

/// 글자 사이에 Figma 구분 점을 넣은 한 줄. 넘치면 끝을 줄인다.
class _DotSeparatedText extends StatelessWidget {
  const _DotSeparatedText(this.parts);

  final List<String> parts;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text.rich(
      TextSpan(
        children: [
          for (final (i, part) in parts.indexed) ...[
            if (i > 0)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x1,
                  ),
                  child: Container(
                    width: ShowListItem._dotSize,
                    height: ShowListItem._dotSize,
                    decoration: BoxDecoration(
                      color: colors.labelAlternative,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            TextSpan(text: part),
          ],
        ],
      ),
      semanticsLabel: parts.join(', '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.caption1Regular.copyWith(
        color: colors.labelAlternative,
      ),
    );
  }
}
