import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// Chip 테두리 두께. 웹(border-box)처럼 여백 토큰 바깥에 더해 Figma Chip 높이 38(1497:9998)에 맞춘다.
const _chipBorderWidth = 1.0;

/// Figma `Chip` 선택형 버튼. 선택지를 고르거나 목록을 거를 때 쓴다.
///
/// 선택 전은 흰 바탕 + 테두리, 선택 후는 진한 바탕 + 흰 글자.
/// 하나만 고르기·여러 개 고르기 규칙은 화면(ViewModel)이 정하고, 이 위젯은 [selected]를 그대로 보여준다.
/// 누를 수 없는 상태 표시는 Chip이 아니라 `AppTag`를 쓴다.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = selected
        ? colors.selectionBackground
        : colors.controlBackground;
    final foreground = selected
        ? colors.selectionForeground
        : colors.labelNormal;
    final borderColor = selected
        ? colors.selectionBackground
        : colors.controlBorder;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: background,
        shape: StadiumBorder(
          side: BorderSide(color: borderColor, width: _chipBorderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppChipTokens.paddingX + _chipBorderWidth,
              vertical: AppChipTokens.paddingY + _chipBorderWidth,
            ),
            child: Text(
              label,
              style: context.textStyles.body1Regular.copyWith(
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma `Filter`. 목록 위에서 조건(장르·지역 등)을 고르는 버튼. 누르면 [onTap]으로 선택 목록을 연다.
/// 조건이 걸려 있으면([selected]) 회색 바탕이 된다.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.fillStrong : colors.backgroundNormal,
        shape: StadiumBorder(side: BorderSide(color: colors.lineNeutral)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFilterTokens.paddingX,
              vertical: AppFilterTokens.paddingY,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.body1Medium.copyWith(
                      color: colors.labelNormal,
                    ),
                  ),
                ),
                const SizedBox(width: AppFilterTokens.gap),
                AppIcon(
                  AppIcons.chevronDown,
                  size: AppFilterTokens.iconSize,
                  color: colors.labelNormal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
