import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `BottomSheet`를 띄운다. [builder]가 만든 내용이 손잡이 아래에 들어간다.
/// 보통 `AppModalHeader` → 내용 → `AppButton` 순서로 넣는다.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.backgroundNormal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppBottomSheetTokens.radius),
      ),
    ),
    barrierColor: context.colors.materialDimmer,
    builder: (context) => AppBottomSheet(child: builder(context)),
  );
}

/// Figma `BottomSheet` 겉모양: 위쪽 둥근 흰 판 + 손잡이.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundNormal,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppBottomSheetTokens.radius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppBottomSheetTokens.paddingX,
          AppBottomSheetTokens.paddingTop,
          AppBottomSheetTokens.paddingX,
          AppBottomSheetTokens.paddingBottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppBottomSheetTokens.gap,
          children: [
            Center(
              child: Container(
                width: AppBottomSheetTokens.handleWidth,
                height: AppBottomSheetTokens.handleHeight,
                decoration: BoxDecoration(
                  color: colors.lineStrong,
                  borderRadius: BorderRadius.circular(
                    AppBottomSheetTokens.handleRadius,
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Figma `ModalHeader`. 시트·다이얼로그의 제목과 보조 문구.
class AppModalHeader extends StatelessWidget {
  const AppModalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.centered = false,
  });

  final String title;
  final String? subtitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppBottomSheetTokens.headerGap,
      children: [
        Text(
          title,
          textAlign: align,
          style: textStyles.title1Bold.copyWith(color: colors.labelNormal),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            textAlign: align,
            style: textStyles.body1Regular.copyWith(color: colors.labelNeutral),
          ),
      ],
    );
  }
}
