import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma `CardSmall` (홈). 가로 목록에 나란히 놓는 작은 공연 카드 (이미지 + 제목 + 정보).
class HomeShowCardSmall extends StatelessWidget {
  const HomeShowCardSmall({
    super.key,
    required this.title,
    this.details = const [],
    this.priceLabel,
    this.image,
    this.onTap,
  });

  final String title;

  /// 제목 아래 정보. 가운뎃점으로 잇고 길면 두 줄까지 보인다 (예: 날짜, 남은 팀 수).
  final List<String> details;

  /// 맨 아래 진한 글자 (예: 팀당 약 20만원).
  final String? priceLabel;

  /// 공연 이미지. 없으면 회색 자리를 그린다.
  final ImageProvider? image;
  final VoidCallback? onTap;

  static const _width = 140.0; // Figma: 카드 폭 (가로 목록 한 칸)
  static const _imageHeight = 90.0; // Figma: 이미지 높이

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Semantics(
      button: onTap != null,
      child: SizedBox(
        width: _width,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x2,
              children: [
                // Ink: 누를 때 물결이 이미지 위에도 보이게 한다.
                Ink(
                  height: _imageHeight,
                  decoration: BoxDecoration(
                    color: colors.fillStrong,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    image: switch (image) {
                      final image? => DecorationImage(
                        image: image,
                        fit: BoxFit.cover,
                      ),
                      null => null,
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.x1_5,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.body1Medium.copyWith(
                        color: colors.labelNormal,
                      ),
                    ),
                    if (details.isNotEmpty)
                      Text(
                        // Figma: 2px 점(Ellipse) → 가운뎃점 글자, 줄바꿈(flex-wrap)은 두 줄까지
                        details.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.caption1Regular.copyWith(
                          color: colors.labelAlternative,
                        ),
                      ),
                    if (priceLabel case final price?)
                      Text(
                        price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.caption1Medium.copyWith(
                          color: colors.labelNormal,
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
