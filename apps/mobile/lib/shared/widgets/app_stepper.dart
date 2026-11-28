import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `InputCount`의 `− 값 +` 상자. 값의 범위는 화면이 정하고,
/// 더 줄이거나 늘릴 수 없으면 해당 콜백을 null로 넘겨 버튼을 끈다.
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.valueLabel,
    required this.onDecrement,
    required this.onIncrement,
  });

  /// 가운데 보일 값 (예: `2팀`).
  final String valueLabel;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget button(IconData icon, String tooltip, VoidCallback? onPressed) =>
        IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: Icon(icon),
          color: colors.labelNormal,
          disabledColor: colors.labelAssistive,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: AppStepperTokens.buttonSize,
            height: AppStepperTokens.buttonSize,
          ),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.controlBackground,
        border: Border.all(color: colors.controlBorder),
        borderRadius: BorderRadius.circular(AppStepperTokens.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.remove, '줄이기', onDecrement),
          Text(
            valueLabel,
            style: context.textStyles.title2Bold.copyWith(
              color: colors.labelNormal,
            ),
          ),
          button(Icons.add, '늘리기', onIncrement),
        ],
      ),
    );
  }
}
