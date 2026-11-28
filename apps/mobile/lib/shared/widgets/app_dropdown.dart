import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// Figma `Dropdown`. 누르면 [onTap]으로 선택 목록(보통 `showAppBottomSheet`)을 연다.
/// 고른 값이 없으면 [hintText]를 옅은 색으로 보인다. 너비는 부모가 정한다 (Figma XL·M·S는 너비만 다르다).
class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.onTap,
    this.value,
    this.hintText,
  });

  final String? value;
  final String? hintText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = value != null;
    return Semantics(
      button: true,
      child: Material(
        color: colors.controlBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppInputTokens.radius),
          side: BorderSide(color: colors.controlBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: AppInputTokens.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppInputTokens.paddingX,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? hintText ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.body1Regular.copyWith(
                        color: hasValue
                            ? colors.labelNormal
                            : colors.labelAlternative,
                      ),
                    ),
                  ),
                  AppIcon(
                    AppIcons.chevronDown,
                    size: AppDropdownTokens.iconSize,
                    color: hasValue
                        ? colors.labelNormal
                        : colors.labelAssistive,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
