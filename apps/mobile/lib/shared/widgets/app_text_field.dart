import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// 테두리 두께. Figma Input과 웹(border-box)처럼 여백 토큰은 이 테두리 안쪽에서 잰다.
const _borderWidth = 1.0;

/// 바깥 테두리에서 글자·아이콘까지 (Figma 654:5752 앞 아이콘 x=15).
const _inset = AppInputTokens.paddingX + _borderWidth;

/// Flutter M3 InputDecorator가 prefixIcon·suffixIcon과 입력 사이에 넣는 고정 간격
/// (`prefixToInputGap`·`inputToSuffixGap`, 설정 불가). Figma 간격(gap)에서 빼서 맞춘다.
const _materialIconGap = 4.0;

/// search는 V3 `2Fill`. 아이콘과 삭제 동작은 기존 [AppTextField.prefix]·suffix로 넣는다.
enum AppTextFieldVariant { standard, search }

/// Figma `Input` 공통 입력창.
///
/// Figma Variant의 Weak(입력 전 안내 문구)와 Fill(입력한 값)은 입력 여부로 자동으로 바뀐다.
/// Disabled는 [enabled] = false, Error는 [invalid] = true.
/// 아이콘·단위가 필요하면 [prefix]·[suffix]에 넣는다 (Figma 검색 아이콘, `>`, 지우기 버튼, `원`·`장`).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.subtext,
    this.variant = AppTextFieldVariant.standard,
    this.enabled = true,
    this.invalid = false,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
  }) : assert(subtext == null || variant == AppTextFieldVariant.standard);

  final TextEditingController? controller;
  final String? hintText;

  /// V3 Fill/서브텍스트: 테두리 안에서 입력값 아래에 놓는 보조행.
  final String? subtext;
  final AppTextFieldVariant variant;
  final bool enabled;

  /// 테두리를 오류 색으로 바꾼다. 오류 문구는 화면이 입력창 아래에 따로 둔다.
  final bool invalid;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// 눌러서 다른 화면을 여는 입력창(Figma `next`)은 [readOnly] = true와 함께 쓴다.
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final subtext = this.subtext;
    final textStyle = switch (variant) {
      AppTextFieldVariant.standard => textStyles.body1Regular,
      AppTextFieldVariant.search => textStyles.body1Medium,
    };
    final valueStyle = subtext == null
        ? textStyle
        : textStyle.copyWith(
            height: AppInputTokens.subtextLineHeight / textStyle.fontSize!,
          );
    final gap = switch (variant) {
      AppTextFieldVariant.standard => AppInputTokens.gap,
      AppTextFieldVariant.search => AppInputTokens.searchGap,
    };
    final foreground = !enabled
        ? colors.labelAlternative
        : variant == AppTextFieldVariant.search
        ? colors.labelStrong
        : colors.labelNormal;

    // M3는 OutlineInputBorder.gapPadding(기본 4)을 입력 앞뒤 여백에도 더한다.
    // 떠 있는 라벨이 없으므로 0으로 두어 글자를 Figma처럼 테두리 안쪽 여백에 둔다.
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppInputTokens.radius),
      borderSide: BorderSide(color: color, width: _borderWidth),
      gapPadding: 0,
    );

    // Figma에는 포커스 상태가 없어 기본 테두리와 같게 둔다.
    final normal = border(
      invalid ? colors.statusDestructive : colors.controlBorder,
    );

    final field = TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textAlignVertical: TextAlignVertical.center,
      style: valueStyle.copyWith(color: foreground),
      cursorColor: colors.labelNormal,
      decoration: subtext != null
          ? InputDecoration(
              hintText: hintText,
              hintStyle: valueStyle.copyWith(color: colors.labelAlternative),
              helperText: subtext,
              helperMaxLines: 1,
              helperStyle: valueStyle.copyWith(color: colors.labelNeutral),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            )
          : InputDecoration(
              hintText: hintText,
              hintStyle: textStyle.copyWith(color: colors.labelAlternative),
              filled: true,
              fillColor: enabled
                  ? colors.controlBackground
                  : colors.interactionDisable,
              constraints: const BoxConstraints.tightFor(
                height: AppInputTokens.height,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: _inset),
              prefixIcon: prefix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(
                        left: _inset,
                        right: gap - _materialIconGap,
                      ),
                      child: prefix,
                    ),
              prefixIconConstraints: const BoxConstraints(),
              suffixIcon: suffix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(
                        left: gap - _materialIconGap,
                        right: _inset,
                      ),
                      child: suffix,
                    ),
              suffixIconConstraints: const BoxConstraints(),
              border: normal,
              enabledBorder: normal,
              focusedBorder: normal,
              disabledBorder: border(colors.controlBorder),
            ),
    );

    if (subtext == null) return field;

    // helperText는 안쪽 입력칸의 보조행으로 배치하고 테두리는 두 행·아이콘 전체를 감싼다.
    return SizedBox(
      height: AppInputTokens.subtextHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled ? colors.controlBackground : colors.interactionDisable,
          border: Border.all(color: normal.borderSide.color),
          borderRadius: BorderRadius.circular(AppInputTokens.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _inset),
          child: Row(
            spacing: gap,
            children: [
              ?prefix,
              Expanded(child: field),
              ?suffix,
            ],
          ),
        ),
      ),
    );
  }
}
