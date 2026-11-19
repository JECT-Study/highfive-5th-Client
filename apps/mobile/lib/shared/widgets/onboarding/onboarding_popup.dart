import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_icon.dart';
import '../app_tag.dart';

/// Figma `popup` (온보딩). 밴드를 만든 뒤 팀원 초대 코드를 알려 주는 팝업 본문.
///
/// 흰 바탕·둥근 모서리까지 이 위젯이 그린다. 띄우기와 닫기는 화면이 정한다 (예: `showDialog`).
class OnboardingPopup extends StatelessWidget {
  const OnboardingPopup({
    super.key,
    required this.title,
    required this.message,
    required this.codeLabel,
    required this.code,
    required this.copyLabel,
    required this.onCopyPressed,
    required this.shareLabel,
    required this.onSharePressed,
    required this.confirmLabel,
    required this.onConfirmPressed,
    this.memberLabel,
    this.hint,
  });

  final String title;
  final String message;

  /// 코드 위 설명 (예: 팀원 초대 방 코드).
  final String codeLabel;
  final String code;

  /// 코드 오른쪽 둥근 태그 (예: 팀원 2명).
  final String? memberLabel;

  final String copyLabel;
  final VoidCallback? onCopyPressed;
  final String shareLabel;
  final VoidCallback? onSharePressed;

  /// 초대 상자 맨 아래 안내 (예: 코드를 다시 볼 수 있는 곳).
  final String? hint;

  /// 맨 아래 진한 버튼 글자 (예: 다음).
  final String confirmLabel;
  final VoidCallback? onConfirmPressed;

  static const _gap = 18.0; // Figma: 구역 사이
  static const _iconSize = 54.0; // Figma: 체크 원 53.84
  static const _codeLetterSpacing = 6.8; // Figma: 코드 글자 사이 (tracking)

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Material(
      color: colors.backgroundNormal,
      shape: RoundedRectangleBorder(
        // Figma: 19.23 → 20
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: _gap,
          children: [
            Center(
              child: AppIcon(
                AppIcons.checkCircleLarge,
                size: _iconSize,
                color: colors.labelNormal,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x1,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textStyles.head.copyWith(color: colors.labelNormal),
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textStyles.body1Medium.copyWith(
                    color: colors.labelAlternative,
                  ),
                ),
              ],
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.backgroundAlternative,
                // Figma: 13.46 → 12
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Padding(
                // Figma: 왼쪽 15.38 → 16, 위 18.75 → 20. 아래는 고정 높이 대신 위와 같게 둔다.
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      spacing: AppSpacing.x2,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: AppSpacing.x1_5,
                            children: [
                              Text(
                                codeLabel,
                                style: textStyles.caption1Medium.copyWith(
                                  color: colors.labelAlternative,
                                ),
                              ),
                              // 코드는 잘리면 안 되므로 길면 글자를 줄여서 다 보인다.
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  code,
                                  style: textStyles.head.copyWith(
                                    color: colors.labelNormal,
                                    letterSpacing: _codeLetterSpacing,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (memberLabel case final member?)
                          AppRoundTag(
                            label: member,
                            size: AppRoundTagSize.medium,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    Row(
                      // Figma: 13.5 → 14
                      spacing: AppSpacing.x3_5,
                      children: [
                        Expanded(
                          child: AppButton(
                            label: copyLabel,
                            variant: AppButtonVariant.weak,
                            size: AppButtonSize.medium,
                            onPressed: onCopyPressed,
                          ),
                        ),
                        Expanded(
                          child: AppButton(
                            label: shareLabel,
                            variant: AppButtonVariant.weak,
                            size: AppButtonSize.medium,
                            icon: const AppIcon(AppIcons.share),
                            onPressed: onSharePressed,
                          ),
                        ),
                      ],
                    ),
                    if (hint case final hint?) ...[
                      const SizedBox(height: AppSpacing.x4),
                      Text(
                        hint,
                        style: textStyles.caption1Medium.copyWith(
                          color: colors.labelAlternative,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AppButton(label: confirmLabel, onPressed: onConfirmPressed),
          ],
        ),
      ),
    );
  }
}
