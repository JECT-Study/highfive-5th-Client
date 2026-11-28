import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// 내용을 보여줄 수 없을 때 가운데 안내 문구와 다음 행동 버튼 하나 (pr-checklist A5).
/// 문구는 "무엇이 안 됐는지 + 무엇을 하면 되는지"로 쓰고,
/// 행동(다시 시도, 이전 화면으로 등)은 화면이 오류 종류에 맞춰 정한다.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.loading = false,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  /// 행동이 진행 중이다 (예: 다시 시도한 요청을 기다리는 중). 버튼이 눌리지 않아 같은 요청을 겹쳐 보내지 않는다.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.x4,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.body1Regular.copyWith(
                color: context.colors.labelNeutral,
              ),
            ),
            // large: 누르는 높이 52. medium(42)은 체크리스트 A8의 최소 44에 못 미친다.
            AppButton(
              label: actionLabel,
              onPressed: onAction,
              variant: AppButtonVariant.weak,
              loading: loading,
            ),
          ],
        ),
      ),
    );
  }
}
