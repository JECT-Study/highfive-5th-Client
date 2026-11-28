import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';

/// 처음 불러오는 중. 로딩 시안이 없어 기존 화면(약관)과 같은 회색 원형 표시를 쓴다.
class LineupLoading extends StatelessWidget {
  const LineupLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.colors.labelAssistive),
    );
  }
}

/// 불러오지 못했다. 안내 문구와 "다시 시도" (약관 시트의 실패 모양과 같다).
class LineupLoadFailure extends StatelessWidget {
  const LineupLoadFailure({
    super.key,
    required this.title,
    required this.message,
    required this.retryKey,
    required this.onRetry,
  });

  /// 예: 셋리스트를 불러오지 못했어요.
  final String title;

  /// 서버 안내나 공통 안내 (`failureMessage`).
  final String message;
  final Key retryKey;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.x3,
          children: [
            Text(
              '$title\n$message',
              textAlign: TextAlign.center,
              style: context.textStyles.body1Regular.copyWith(
                color: context.colors.labelNeutral,
              ),
            ),
            AppButton(
              key: retryKey,
              label: '다시 시도',
              variant: AppButtonVariant.weak,
              size: AppButtonSize.medium,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// 저장 실패처럼 화면을 바꾸지 않는 짧은 안내.
/// 토스트 시안이 없어 토스트용 의미 색(inverse)으로 아래에 잠깐 띄운다.
void showLineupToast(BuildContext context, String message) {
  final colors = context.colors;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: context.textStyles.body1Regular.copyWith(
            color: colors.inverseLabel,
          ),
        ),
        backgroundColor: colors.inverseBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
}
