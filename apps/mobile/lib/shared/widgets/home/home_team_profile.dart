import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_icon.dart';

/// Figma `TeamProfile` (홈). 밴드 프로필과 초대 코드 공유 상자를 묶은 카드.
class HomeTeamProfile extends StatelessWidget {
  const HomeTeamProfile({
    super.key,
    required this.name,
    required this.codeLabel,
    required this.code,
    required this.shareLabel,
    required this.onSharePressed,
    this.memberLabel,
    this.image,
  });

  final String name;

  /// 이름 옆 작은 글자 (예: 팀원 1).
  final String? memberLabel;

  /// 코드 앞 설명 (예: 초대코드).
  final String codeLabel;
  final String code;

  /// 공유 버튼 글자 (예: 공유).
  final String shareLabel;
  final VoidCallback? onSharePressed;

  /// 밴드 프로필. 없으면 회색 둥근 네모를 그린다.
  final ImageProvider? image;

  static const _avatarSize = 40.0; // Figma: 프로필 크기
  static const _codeBoxHeight = 46.0; // Figma: 초대 코드 상자 높이

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundNormal,
        border: Border.all(color: colors.lineStrong),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3_5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.x2_5,
          children: [
            Row(
              // Figma: 13 → 14
              spacing: AppSpacing.x3_5,
              children: [
                Container(
                  width: _avatarSize,
                  height: _avatarSize,
                  decoration: BoxDecoration(
                    color: colors.fillStrong,
                    // Figma: 모서리 15 → 16
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    image: switch (image) {
                      final image? => DecorationImage(
                        image: image,
                        fit: BoxFit.cover,
                      ),
                      null => null,
                    },
                  ),
                ),
                Expanded(
                  child: Row(
                    // Figma: 5 → 6
                    spacing: AppSpacing.x1_5,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.body1SemiBold.copyWith(
                            color: colors.labelNormal,
                          ),
                        ),
                      ),
                      if (memberLabel case final member?)
                        Text(
                          member,
                          style: textStyles.caption1Medium.copyWith(
                            color: colors.labelAlternative,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: _codeBoxHeight,
              padding: const EdgeInsets.only(
                left: AppSpacing.x3_5,
                right: AppSpacing.x2,
              ),
              decoration: BoxDecoration(
                color: colors.backgroundAlternative,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                spacing: AppSpacing.x2,
                children: [
                  Text(
                    codeLabel,
                    style: textStyles.body1Medium.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                  // 코드는 잘리면 안 되므로 길면 글자를 줄여서 다 보인다.
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        code,
                        style: textStyles.body1SemiBold.copyWith(
                          color: colors.labelNormal,
                        ),
                      ),
                    ),
                  ),
                  AppButton(
                    label: shareLabel,
                    size: AppButtonSize.small,
                    icon: const AppIcon(AppIcons.share),
                    onPressed: onSharePressed,
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
