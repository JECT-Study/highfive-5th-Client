import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_selection_controls.dart';

/// Figma `ReportItem` (메시지). 신고 사유 한 줄과 오른쪽 라디오.
///
/// 줄 전체가 눌린다. 하나만 고르는 규칙은 화면이 정한다.
/// [selected]이고 [reasonController]가 있으면 아래에 자세한 사유 입력칸을 연다 (Figma Content = True).
class ReportItem extends StatelessWidget {
  const ReportItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.reasonController,
    this.reasonHintText,
    this.reasonMaxLength,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// 자세한 사유 입력칸의 글자. null이면 골라도 입력칸이 없다.
  final TextEditingController? reasonController;

  /// 사유 입력칸 안내 문구 (예: (선택)구체적인 사유를 입력해 주세요.).
  final String? reasonHintText;

  /// 입력칸 오른쪽 아래에 `글자 수/최대`로 보이는 최대 글자 수.
  final int? reasonMaxLength;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x2_5,
      children: [
        Semantics(
          button: true,
          selected: selected,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.lineNeutral)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.body1Medium.copyWith(
                        // Figma: 고른 줄은 글자가 더 진하다.
                        color: selected
                            ? colors.labelStrong
                            : colors.labelNormal,
                      ),
                    ),
                  ),
                  // 줄 전체가 눌리므로 라디오는 모양만 빌려 쓴다.
                  ExcludeSemantics(
                    child: AppRadio(selected: selected, onTap: null),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (reasonController case final controller? when selected)
          _ReasonField(
            controller: controller,
            hintText: reasonHintText,
            maxLength: reasonMaxLength,
          ),
      ],
    );
  }
}

/// 자세한 사유 입력칸 (Figma ReportItem 안 Container). 회색 바탕에 오른쪽 아래 글자 수.
class _ReasonField extends StatelessWidget {
  const _ReasonField({
    required this.controller,
    required this.hintText,
    required this.maxLength,
  });

  static const _height = 91.0; // Figma: 사유 입력칸 높이
  static const _radius = 4.0; // Figma: 사유 입력칸 모서리 (모서리 토큰 xs 6보다 작다)

  final TextEditingController controller;
  final String? hintText;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final max = maxLength;
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: colors.backgroundAlternative,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: TextField(
              controller: controller,
              maxLength: max,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: textStyles.body1Regular.copyWith(
                color: colors.labelNormal,
              ),
              cursorColor: colors.labelNormal,
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: textStyles.body1Regular.copyWith(
                  color: colors.labelAlternative,
                ),
                isCollapsed: true,
                border: InputBorder.none,
                // 글자 수와 겹치지 않게 아래를 더 띄운다.
                contentPadding: EdgeInsets.fromLTRB(
                  AppSpacing.x2_5,
                  AppSpacing.x2_5,
                  AppSpacing.x2_5,
                  max == null ? AppSpacing.x2_5 : AppSpacing.x6,
                ),
              ),
            ),
          ),
          if (max != null)
            Positioned(
              right: AppSpacing.x2_5,
              bottom: AppSpacing.x2_5,
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, _) => Text(
                  '${value.text.characters.length}/$max',
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
