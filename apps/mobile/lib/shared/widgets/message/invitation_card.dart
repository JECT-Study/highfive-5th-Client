import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';

/// Figma `Invitation` (메시지). 채팅방 안 합동공연 초대 카드: 질문과 거절·수락 버튼.
///
/// 거절·수락 요청 중에는 두 콜백을 null로 넘겨 버튼을 막는다 (같은 요청을 두 번 보내지 않게).
class InvitationCard extends StatelessWidget {
  const InvitationCard({
    super.key,
    required this.title,
    required this.declineLabel,
    required this.acceptLabel,
    required this.onDecline,
    required this.onAccept,
  });

  /// 초대 질문 (예: 오프비트와 함께 공연할까요?).
  final String title;
  final String declineLabel;
  final String acceptLabel;
  final VoidCallback? onDecline;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x5,
        vertical: AppSpacing.x2_5,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colors.lineNeutral),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x2_5,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x1),
            child: Text(
              title,
              style: context.textStyles.title2Bold.copyWith(
                color: colors.labelNormal,
              ),
            ),
          ),
          Row(
            spacing: AppSpacing.x2_5,
            children: [
              Expanded(
                child: AppButton(
                  label: declineLabel,
                  onPressed: onDecline,
                  variant: AppButtonVariant.weak,
                  size: AppButtonSize.medium,
                ),
              ),
              Expanded(
                child: AppButton(
                  label: acceptLabel,
                  onPressed: onAccept,
                  size: AppButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
