import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import 'app_icon.dart';

/// Figma `Checkbox`. 상자는 14지만 누르는 영역은 44다. 글자는 화면이 옆에 둔다.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool checked;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onChanged != null;
    // 비활성: Figma check=Disabled (바탕 Interaction/Disabled, 테두리 Label/Disabled).
    // 체크된 비활성은 Figma에 없어 같은 테두리색을 바탕으로 채운다.
    final borderColor = enabled ? colors.labelNeutral : colors.labelDisable;
    final fillColor = checked
        ? borderColor
        : (enabled ? null : colors.interactionDisable);
    return _SelectionTarget(
      label: semanticLabel,
      checked: checked,
      onTap: enabled ? () => onChanged!(!checked) : null,
      child: Container(
        width: AppSelectionTokens.checkboxSize,
        height: AppSelectionTokens.checkboxSize,
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(
            AppSelectionTokens.checkboxRadius,
          ),
        ),
        child: checked
            ? AppIcon(
                AppIcons.check,
                size: AppSelectionTokens.checkboxSize,
                color: colors.staticWhite,
              )
            : null,
      ),
    );
  }
}

/// Figma `Radio Button`. 여러 개 중 하나만 고를 때 쓴다. 고르는 규칙은 화면이 정한다.
class AppRadio extends StatelessWidget {
  const AppRadio({
    super.key,
    required this.selected,
    required this.onTap,
    this.semanticLabel,
  });

  final bool selected;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _SelectionTarget(
      label: semanticLabel,
      checked: selected,
      inMutuallyExclusiveGroup: true,
      onTap: onTap,
      child: Container(
        width: AppSelectionTokens.radioSize,
        height: AppSelectionTokens.radioSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? colors.labelNormal : null,
          border: selected
              ? null
              : Border.all(color: colors.interactionInactive),
        ),
        child: selected
            ? Container(
                width: AppSelectionTokens.radioDotSize,
                height: AppSelectionTokens.radioDotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.staticWhite,
                ),
              )
            : null,
      ),
    );
  }
}

/// Figma `Toggle`. 켜면 진한 바탕, 끄면 옅은 바탕에 흰 원이 오른쪽·왼쪽으로 간다.
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.checked,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool checked;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      toggled: checked,
      enabled: onChanged != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!checked),
        child: SizedBox(
          height: AppSelectionTokens.touchSize,
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: kThemeAnimationDuration,
              width: AppSelectionTokens.toggleWidth,
              height: AppSelectionTokens.toggleHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSelectionTokens.toggleThumbInset,
              ),
              alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: checked ? colors.labelStrong : colors.labelAssistive,
                borderRadius: BorderRadius.circular(
                  AppSelectionTokens.toggleHeight,
                ),
              ),
              child: Container(
                width: AppSelectionTokens.toggleThumbSize,
                height: AppSelectionTokens.toggleThumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.staticWhite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 체크박스·라디오 공통: 44 × 44 누르는 영역과 접근성 정보.
class _SelectionTarget extends StatelessWidget {
  const _SelectionTarget({
    required this.checked,
    required this.onTap,
    required this.child,
    this.label,
    this.inMutuallyExclusiveGroup = false,
  });

  final bool checked;
  final VoidCallback? onTap;
  final Widget child;
  final String? label;
  final bool inMutuallyExclusiveGroup;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      enabled: onTap != null,
      inMutuallyExclusiveGroup: inMutuallyExclusiveGroup,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: AppSelectionTokens.touchSize,
          child: Center(child: child),
        ),
      ),
    );
  }
}
