import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `TextArea` 여러 줄 입력창. [maxLength]가 있으면 입력칸 안 오른쪽 아래에 `글자 수/최대`를 보인다.
class AppTextArea extends StatefulWidget {
  const AppTextArea({
    super.key,
    this.controller,
    this.hintText,
    this.enabled = true,
    this.maxLength,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool enabled;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea> {
  TextEditingController? _ownController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final enabled = widget.enabled;
    final maxLength = widget.maxLength;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextAreaTokens.radius),
      borderSide: BorderSide(
        color: enabled ? colors.lineStrong : colors.interactionDisable,
      ),
    );
    // 글자 수 줄 높이만큼 아래 여백을 더 둔다.
    final bottomPadding = maxLength == null
        ? AppTextAreaTokens.padding
        : AppTextAreaTokens.padding * 2;

    return SizedBox(
      height: AppTextAreaTokens.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: TextField(
              controller: _controller,
              enabled: enabled,
              maxLength: maxLength,
              onChanged: widget.onChanged,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: textStyles.body1Regular.copyWith(
                color: enabled ? colors.labelNormal : colors.labelAlternative,
              ),
              cursorColor: colors.labelNormal,
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: textStyles.body1Regular.copyWith(
                  color: colors.labelAlternative,
                ),
                filled: true,
                fillColor: enabled
                    ? colors.backgroundNormal
                    : colors.interactionDisable,
                contentPadding: EdgeInsets.fromLTRB(
                  AppTextAreaTokens.padding,
                  AppTextAreaTokens.padding,
                  AppTextAreaTokens.padding,
                  bottomPadding,
                ),
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                disabledBorder: border,
              ),
            ),
          ),
          if (maxLength != null)
            Positioned(
              right: AppTextAreaTokens.padding,
              bottom: AppTextAreaTokens.padding,
              child: ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, _) => Text(
                  '${value.text.characters.length}/$maxLength',
                  style: textStyles.caption1Regular.copyWith(
                    color: colors.labelAlternative,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
