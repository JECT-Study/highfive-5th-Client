import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';

/// Figma `HomeList` (홈). 홈의 내 밴드 목록 한 줄 (프로필 + 이름 + 안내 + 오른쪽 화살표).
class HomeListRow extends StatelessWidget {
  const HomeListRow({
    super.key,
    required this.title,
    required this.description,
    this.memberLabel,
    this.image,
    this.onTap,
  });

  final String title;

  /// 이름 옆 작은 글자 (예: 팀원 1).
  final String? memberLabel;

  /// 이름 아래 안내 (예: 방 코드를 팀원에게 공유하라는 안내).
  final String description;

  /// 밴드 프로필. 없으면 회색 동그라미를 그린다.
  final ImageProvider? image;
  final VoidCallback? onTap;

  static const _avatarSize = 44.0; // Figma: 프로필 크기
  static const _arrowSize = 16.0; // Figma: Icon:arrow 크기

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x2_5,
          ),
          child: Row(
            spacing: AppSpacing.x2_5,
            children: [
              Container(
                width: _avatarSize,
                height: _avatarSize,
                decoration: BoxDecoration(
                  color: colors.fillStrong,
                  shape: BoxShape.circle,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  // Figma: 5 → 6
                  spacing: AppSpacing.x1_5,
                  children: [
                    Row(
                      spacing: AppSpacing.x1_5,
                      children: [
                        Flexible(
                          child: Text(
                            title,
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
                            style: textStyles.caption1Regular.copyWith(
                              color: colors.labelAlternative,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.caption1Regular.copyWith(
                        color: colors.labelAlternative,
                      ),
                    ),
                  ],
                ),
              ),
              // Figma Icon:arrow는 오른쪽 화살표다. 왼쪽 화살표 아이콘을 뒤집어 쓴다.
              Transform.flip(
                flipX: true,
                child: AppIcon(
                  AppIcons.chevronLeft,
                  size: _arrowSize,
                  color: colors.labelAlternative,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
