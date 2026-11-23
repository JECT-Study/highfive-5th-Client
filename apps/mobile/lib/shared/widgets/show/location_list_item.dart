import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';

/// Figma `LocationList` (show). 장소 목록 한 줄: 위치 아이콘, 장소 이름, 주소.
class LocationListItem extends StatelessWidget {
  const LocationListItem({
    super.key,
    required this.name,
    required this.address,
    this.onTap,
  });

  static const _iconSize = 30.0; // Figma: 위치 아이콘 틀 30

  final String name;
  final String address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x4,
          ),
          child: Row(
            spacing: AppSpacing.x2,
            children: [
              AppIcon(
                AppIcons.location,
                size: _iconSize,
                color: colors.labelNeutral,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.x0_5,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.body1Medium.copyWith(
                        color: colors.labelNormal,
                      ),
                    ),
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.caption1Medium.copyWith(
                        color: colors.labelNeutral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
