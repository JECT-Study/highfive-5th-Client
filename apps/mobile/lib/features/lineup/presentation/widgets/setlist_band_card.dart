import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../models/lineup.dart';
import 'lineup_formats.dart';
import 'song_row.dart';

/// Figma `LineupCell`(Title 끔) 안의 `TeamProfile`: 밴드 사진 · 이름 · "장르 / 인원".
///
/// 시안 오른쪽의 "밴드 프로필 >"은 이동할 밴드 프로필 화면(경로)이 아직 없어 그리지 않는다.
class SetlistBandCard extends StatelessWidget {
  const SetlistBandCard({super.key, required this.band});

  final LineupBand band;

  static const _avatarSize = 40.0; // Figma: Profile

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundAlternative,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3_5),
        child: Row(
          // Figma: 13 → 14 (HomeTeamProfile과 같은 단계)
          spacing: AppSpacing.x3_5,
          children: [
            LineupImage(
              url: band.profileImageUrl,
              size: _avatarSize,
              // Figma: 모서리 15 → 16
              radius: AppRadius.xl,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.x1,
                children: [
                  Text(
                    band.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.body1SemiBold.copyWith(
                      color: colors.labelNormal,
                    ),
                  ),
                  Text(
                    [
                      if (band.genres.isNotEmpty) genreNames(band.genres),
                      '${band.memberCount}명',
                    ].join(' / '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.caption1Regular.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
