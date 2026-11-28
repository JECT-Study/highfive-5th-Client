import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// 정보 탭의 구역 하나 (Figma `Wrap`·`Section`, 2217:122828·2217:123297): 제목과 내용.
/// Figma: 사방 여백 20, 제목과 내용 사이 16.
class ConcertSection extends StatelessWidget {
  const ConcertSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x4,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.title1Bold.copyWith(
              color: context.colors.labelNormal,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
