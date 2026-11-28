import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `Notice` 종류: info = Default(회색 안내), warning = Warning(붉은 경고).
enum AppNoticeType { info, warning }

/// Figma `Notice` 안내 띠. 아이콘은 [icon]·[trailing]에 넣는다 (24 × 24).
class AppNotice extends StatelessWidget {
  const AppNotice({
    super.key,
    required this.message,
    this.type = AppNoticeType.info,
    this.icon,
    this.trailing,
    this.textStyle,
    this.padding,
  });

  final String message;
  final AppNoticeType type;
  final Widget? icon;
  final Widget? trailing;

  /// Dialog 등 V3 인스턴스의 글자·여백 재정의. 기본 Notice는 기존 값을 유지한다.
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final (background, text) = switch (type) {
      AppNoticeType.info => (
        colors.backgroundAlternative,
        textStyles.body1Regular.copyWith(color: colors.gray800),
      ),
      AppNoticeType.warning => (
        colors.backgroundWarning,
        textStyles.title2SemiBold.copyWith(color: colors.statusDestructive),
      ),
    };
    final effectiveText = text.merge(textStyle);

    Widget slot(Widget child) => SizedBox.square(
      dimension: AppNoticeTokens.iconSize,
      child: IconTheme.merge(
        data: IconThemeData(
          color: effectiveText.color,
          size: AppNoticeTokens.iconSize,
        ),
        child: child,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppNoticeTokens.radius),
      ),
      child: Padding(
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: AppNoticeTokens.paddingX,
              vertical: AppNoticeTokens.paddingY,
            ),
        child: Row(
          children: [
            if (icon != null) ...[
              slot(icon!),
              const SizedBox(width: AppNoticeTokens.gap),
            ],
            Expanded(child: Text(message, style: effectiveText)),
            if (trailing != null) ...[
              const SizedBox(width: AppNoticeTokens.gap),
              slot(trailing!),
            ],
          ],
        ),
      ),
    );
  }
}
