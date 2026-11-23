import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// 정보 줄 글자 크기: caption = Caption/1(R) 12, body = Body/1(R) 14.
enum ShowMetaTextSize { caption, body }

/// Figma `Ellipse` 점 구분 줄 (공연페이지). 시간·장소처럼 짧은 정보를 2px 점으로 나눠 한 줄에 보인다.
///
/// 공연페이지 컴포넌트 여러 곳(Date, FeedTab, Container, Top, ProgressCard, LineUp)이 같이 쓴다.
/// 넘치면 끝을 말줄임표로 줄인다. [onDark]면 어두운 바탕(현장 입장)에 맞는 색을 쓴다.
class ShowMetaText extends StatelessWidget {
  const ShowMetaText(
    this.items, {
    super.key,
    this.size = ShowMetaTextSize.caption,
    this.onDark = false,
  });

  final List<String> items;
  final ShowMetaTextSize size;
  final bool onDark;

  static const _dotSize = 2.0; // Figma: Ellipse 지름

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Figma: 글자와 점은 같은 색(#606060·#6e6e73). 어두운 바탕의 #959595는 대비를 위해 interactionInactive.
    final color = onDark ? colors.interactionInactive : colors.labelAlternative;
    final style = switch (size) {
      ShowMetaTextSize.caption => context.textStyles.caption1Regular,
      ShowMetaTextSize.body => context.textStyles.body1Regular,
    };

    return Text.rich(
      TextSpan(
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x1,
                  ),
                  child: Container(
                    width: _dotSize,
                    height: _dotSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            TextSpan(text: item),
          ],
        ],
      ),
      style: style.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
