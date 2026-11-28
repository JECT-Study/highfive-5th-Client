import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// Figma `PlayList`(공연페이지) 한 줄: 앞 칸 · 앨범 썸네일 · 제목/부제 · 뒤 칸.
/// 셋리스트 보기(`리스트`: 번호·재생 시간), 편집(`편집`: 끌기 손잡이·빼기),
/// 곡 검색 결과(`추가`·`추가됨`)가 같이 쓴다.
class SongRow extends StatelessWidget {
  const SongRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.padding,
    this.imageUrl,
    this.leading,
    this.trailing,
  });

  final String title;

  /// 둘째 줄 (예: Oasis, 소음공장 (자작곡), Oasis | 4:48).
  final String subtitle;

  /// Figma variant마다 다르다 (보기·편집은 세로 14·가로 20, 검색 결과는 사방 10).
  final EdgeInsetsGeometry padding;
  final String? imageUrl;
  final Widget? leading;
  final Widget? trailing;

  static const _thumbnailSize = 39.0; // Figma: thumbnail

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Padding(
      padding: padding,
      child: Row(
        spacing: AppSpacing.x2_5,
        children: [
          ?leading,
          LineupImage(
            url: imageUrl,
            size: _thumbnailSize,
            radius: AppRadius.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.x1,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.body1SemiBold.copyWith(
                    color: colors.labelNormal,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.caption1Regular.copyWith(
                    color: colors.labelAlternative,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// 둥근 네모 이미지 칸 (앨범 썸네일, 밴드 사진).
/// 자작곡처럼 주소가 없거나 받지 못하면 시안의 빈 썸네일처럼 회색 칸만 둔다.
class LineupImage extends StatelessWidget {
  const LineupImage({
    super.key,
    required this.url,
    required this.size,
    required this.radius,
  });

  final String? url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: ColoredBox(
          color: context.colors.fillStrong,
          child: url == null
              ? null
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  // 받지 못한 이미지는 회색 칸 그대로 둔다 (곡·밴드 정보는 글자로 보인다).
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
        ),
      ),
    );
  }
}
