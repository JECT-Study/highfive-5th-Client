import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

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
  });

  final TextEditingController? controller;
  final String? hintText;
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
    final textStyle = context.textStyles.body1Regular;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppInputTokens.radius),
      borderSide: BorderSide(color: color),
    );

    // Figma에는 포커스 상태가 없어 기본 테두리와 같게 둔다.
    final normal = border(
      invalid ? colors.statusDestructive : colors.lineStrong,
    );

    return TextField(
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
      style: textStyle.copyWith(
        color: enabled ? colors.labelNormal : colors.labelAlternative,
      ),
      cursorColor: colors.labelNormal,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textStyle.copyWith(color: colors.labelAlternative),
        filled: true,
        fillColor: enabled
            ? colors.backgroundNormal
            : colors.interactionDisable,
        constraints: const BoxConstraints.tightFor(
          height: AppInputTokens.height,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppInputTokens.paddingX,
        ),
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(
                  left: AppInputTokens.paddingX,
                  right: AppInputTokens.gap,
                ),
                child: prefix,
              ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(
                  left: AppInputTokens.gap,
                  right: AppInputTokens.paddingX,
                ),
                child: suffix,
              ),
        suffixIconConstraints: const BoxConstraints(),
        border: normal,
        enabledBorder: normal,
        focusedBorder: normal,
        disabledBorder: border(colors.lineStrong),
      ),
    );
  }
}
