import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';

/// Figma `Onboarding`의 `Property 1`: Default → create(진한 상자 + 더하기), Code → code(회색 상자 + 자물쇠).
enum OnboardingOptionType { create, code }

/// Figma `Onboarding` (온보딩). 시작 방법(밴드 만들기·코드로 합류하기)을 고르는 카드.
class OnboardingOptionCard extends StatelessWidget {
  const OnboardingOptionCard({
    super.key,
    required this.title,
    required this.description,
    this.type = OnboardingOptionType.create,
    this.codeField,
    this.onTap,
  });

  final String title;
  final String description;
  final OnboardingOptionType type;

  /// 제목 줄 아래에 놓는 코드 입력칸 (Figma Code 변형의 `Input`). 보통 `AppTextField`를 넣는다.
  final Widget? codeField;

  /// 카드를 눌렀을 때. 입력칸만 쓰는 카드는 null로 둔다.
  final VoidCallback? onTap;

  static const _iconBoxSize = 50.0; // Figma: IconContainer 크기
  static const _plusIconSize = 44.0; // Figma: akar-icons:plus 크기
  static const _lockIconSize =
      32.0; // Figma akar-icons:lock-on 그림 크기(약 25)에 맞춘 Material 아이콘 크기

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final (Color boxColor, Widget icon) = switch (type) {
      OnboardingOptionType.create => (
        colors.labelNormal,
        AppIcon(AppIcons.add, size: _plusIconSize, color: colors.staticWhite),
      ),
      OnboardingOptionType.code => (
        colors.fillStrong,
        // 앱 아이콘에 자물쇠가 없어 Material 아이콘으로 대신한다.
        Icon(Icons.lock_outline, size: _lockIconSize, color: colors.gray800),
      ),
    };

    return Semantics(
      button: onTap != null,
      child: Material(
        color: colors.backgroundNormal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.lineStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x5,
              children: [
                Row(
                  spacing: AppSpacing.x5,
                  children: [
                    Container(
                      width: _iconBoxSize,
                      height: _iconBoxSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: icon,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.x0_5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: AppSpacing.x1_5,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyles.title2SemiBold.copyWith(
                                color: colors.labelStrong,
                              ),
                            ),
                            Text(
                              description,
                              style: textStyles.body1Medium.copyWith(
                                color: colors.labelAlternative,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ?codeField,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
