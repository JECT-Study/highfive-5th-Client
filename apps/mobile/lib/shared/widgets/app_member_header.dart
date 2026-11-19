import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_tag.dart';

/// Figma `MemberHeader` (공통). 팀원 프로필 사진 옆에 이름과 파트 태그를 보여 주는 머리 영역.
class AppMemberHeader extends StatelessWidget {
  const AppMemberHeader({super.key, required this.name, this.tag, this.image});

  final String name;

  /// 이름 아래 태그 (예: 파트 `키보드`). 없으면 이름만 보인다.
  final String? tag;

  /// 프로필 사진. null이면 회색 원을 그린다.
  final ImageProvider? image;

  static const _avatarSize = 70.0; // Figma: 프로필 사진 지름

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      spacing: AppSpacing.x4,
      children: [
        Container(
          width: _avatarSize,
          height: _avatarSize,
          decoration: BoxDecoration(
            color: colors.fillStrong,
            shape: BoxShape.circle,
            image: image == null
                ? null
                : DecorationImage(image: image!, fit: BoxFit.cover),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.x2,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.title1Bold.copyWith(
                  color: colors.labelNormal,
                ),
              ),
              if (tag != null) AppTag(label: tag!, size: AppTagSize.medium),
            ],
          ),
        ),
      ],
    );
  }
}
