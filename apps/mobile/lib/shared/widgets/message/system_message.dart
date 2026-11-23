import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma `SystemMessage` (메시지). 채팅방 가운데 알림 문구 (예: 문의를 시작했어요).
class SystemMessage extends StatelessWidget {
  const SystemMessage({super.key, required this.message});

  static const _paddingX = 30.0; // Figma: 좌우 여백

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.fillNormal,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _paddingX,
            vertical: AppSpacing.x2_5,
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: context.textStyles.caption1Medium.copyWith(
              color: colors.labelNeutral,
            ),
          ),
        ),
      ),
    );
  }
}
