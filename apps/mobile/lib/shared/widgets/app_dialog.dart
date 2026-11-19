import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Figma `Dialog`를 띄우고, 확인을 누르면 true, 취소·바깥을 누르면 false를 돌려준다.
/// 결과가 남는 명령(삭제·취소 등)은 true일 때 화면이 ViewModel 메서드를 부른다.
Future<bool> showAppDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? message,
  String? cancelLabel,
  Widget? icon,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: context.colors.materialDimmer,
    builder: (_) => AppDialog(
      title: title,
      message: message,
      icon: icon,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}

/// Figma `Dialog` 본체. 보통 [showAppDialog]로 띄운다.
/// [cancelLabel]이 없으면 확인 버튼 하나만 보인다.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    this.message,
    this.cancelLabel,
    this.icon,
    this.destructive = false,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String? cancelLabel;
  final Widget? icon;

  /// 확인 버튼을 danger(빨간 바탕)로 보인다.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Dialog(
      backgroundColor: colors.backgroundNormal,
      surfaceTintColor: colors.backgroundNormal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDialogTokens.radius),
      ),
      child: SizedBox(
        width: AppDialogTokens.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDialogTokens.paddingX,
            AppDialogTokens.paddingTop,
            AppDialogTokens.paddingX,
            AppDialogTokens.paddingBottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppDialogTokens.gap,
            children: [
              ?icon,
              Text(
                title,
                textAlign: TextAlign.center,
                style: textStyles.title1Bold.copyWith(
                  color: colors.labelNormal,
                ),
              ),
              if (message != null)
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: textStyles.body1Medium.copyWith(
                    color: colors.labelNeutral,
                  ),
                ),
              Row(
                spacing: AppDialogTokens.buttonGap,
                children: [
                  if (cancelLabel != null)
                    Expanded(
                      child: AppButton(
                        label: cancelLabel!,
                        variant: AppButtonVariant.weak,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      variant: destructive
                          ? AppButtonVariant.danger
                          : AppButtonVariant.fill,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
