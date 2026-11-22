import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// 버튼의 중요도 (Figma Btn `Color`).
/// fill = 화면의 주요 행동, weak = 되돌리기·거절 같은 보조 행동, danger = 삭제·취소처럼 되돌릴 수 없는 행동.
enum AppButtonVariant { fill, weak, danger }

/// 버튼 크기 (Figma Btn `Property`).
/// large(XL) = 화면·시트 하단, medium(XS) = 나란히 두는 버튼, small(Mini) = 메시지 안,
/// floating = 화면 위에 떠 있는 대표 행동 (예: + 글쓰기).
enum AppButtonSize { large, medium, small, floating }

/// Figma `Btn` 공통 버튼.
///
/// - [onPressed]가 null이면 비활성(Disabled)이다.
/// - [loading]이면 글자 대신 점 3개를 보이고 눌리지 않는다. 같은 요청을 두 번 보내지 않게 하려면
///   ViewModel의 로딩 상태를 그대로 넘긴다.
/// - 너비는 정하지 않는다. 가로를 채우려면 `SizedBox(width: double.infinity, child: AppButton(...))`.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.fill,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// 글자 앞에 놓는 아이콘 (Figma PrefixIcon). 색은 버튼 글자색을 물려받는다.
  final Widget? icon;
  final bool loading;

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = _ButtonStyle.resolve(
      colors: colors,
      textStyles: context.textStyles,
      variant: variant,
      size: size,
      enabled: _enabled,
    );
    final metrics = _ButtonMetrics.of(size);

    final Widget content = loading
        ? _LoadingDots(color: style.foreground)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                IconTheme.merge(
                  data: IconThemeData(
                    color: style.foreground,
                    size: metrics.iconSize,
                  ),
                  child: SizedBox.square(
                    dimension: metrics.iconSize,
                    child: icon,
                  ),
                ),
                SizedBox(width: metrics.gap),
              ],
              Flexible(
                child: Text(
                  label,
                  style: style.text.copyWith(color: style.foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(metrics.radius),
      side: style.border == null
          ? BorderSide.none
          : BorderSide(color: style.border!),
    );

    return Semantics(
      button: true,
      enabled: _enabled && !loading,
      label: loading ? label : null,
      excludeSemantics: loading,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: metrics.height ?? 0),
        child: Material(
          color: style.background,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: loading ? null : onPressed,
            child: SizedBox(
              height: metrics.height,
              child: Padding(
                padding: metrics.padding,
                child: Center(widthFactor: 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 크기별 치수. 값은 [AppButtonTokens]에서만 가져온다.
class _ButtonMetrics {
  const _ButtonMetrics({
    required this.height,
    required this.padding,
    required this.gap,
    required this.radius,
    required this.iconSize,
  });

  /// floating은 높이를 여백으로 정한다 (null).
  final double? height;
  final EdgeInsets padding;
  final double gap;
  final double radius;
  final double iconSize;

  static _ButtonMetrics of(AppButtonSize size) => switch (size) {
    AppButtonSize.large => const _ButtonMetrics(
      height: AppButtonTokens.largeHeight,
      padding: EdgeInsets.symmetric(horizontal: AppButtonTokens.largePaddingX),
      gap: AppButtonTokens.largeGap,
      radius: AppButtonTokens.largeRadius,
      iconSize: AppButtonTokens.iconSize,
    ),
    AppButtonSize.medium => const _ButtonMetrics(
      height: AppButtonTokens.mediumHeight,
      padding: EdgeInsets.symmetric(horizontal: AppButtonTokens.mediumPaddingX),
      gap: AppButtonTokens.mediumGap,
      radius: AppButtonTokens.mediumRadius,
      iconSize: AppButtonTokens.iconSize,
    ),
    AppButtonSize.small => const _ButtonMetrics(
      height: AppButtonTokens.smallHeight,
      padding: EdgeInsets.symmetric(horizontal: AppButtonTokens.smallPaddingX),
      gap: AppButtonTokens.smallGap,
      radius: AppButtonTokens.smallRadius,
      iconSize: AppButtonTokens.smallIconSize,
    ),
    AppButtonSize.floating => const _ButtonMetrics(
      height: null,
      padding: EdgeInsets.fromLTRB(
        AppButtonTokens.floatingPaddingLeft,
        AppButtonTokens.floatingPaddingY,
        AppButtonTokens.floatingPaddingRight,
        AppButtonTokens.floatingPaddingY,
      ),
      gap: AppButtonTokens.floatingGap,
      radius: AppButtonTokens.floatingRadius,
      iconSize: AppButtonTokens.iconSize,
    ),
  };
}

/// 중요도·크기·활성 여부별 색과 글자 스타일. 색은 의미 토큰만 쓴다.
class _ButtonStyle {
  const _ButtonStyle({
    required this.background,
    required this.foreground,
    required this.text,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
  final TextStyle text;

  static _ButtonStyle resolve({
    required AppColors colors,
    required AppTextStyles textStyles,
    required AppButtonVariant variant,
    required AppButtonSize size,
    required bool enabled,
  }) {
    // Figma: danger는 XL만 빨간 바탕이고, XS·Mini는 빨간 테두리 + 빨간 글자다.
    final outlinedDanger =
        variant == AppButtonVariant.danger && size != AppButtonSize.large;
    final filled =
        variant == AppButtonVariant.fill ||
        (variant == AppButtonVariant.danger && !outlinedDanger);

    final text = _text(textStyles, size, emphasized: filled);

    if (!enabled) {
      return filled
          ? _ButtonStyle(
              background: colors.interactionInactive,
              foreground: colors.staticWhite,
              text: text,
            )
          : _ButtonStyle(
              background: colors.interactionDisable,
              foreground: colors.labelAlternative,
              border: colors.lineNeutral,
              text: text,
            );
    }
    if (outlinedDanger) {
      return _ButtonStyle(
        background: colors.backgroundNormal,
        foreground: colors.statusDestructive,
        border: colors.statusDestructive,
        text: text,
      );
    }
    return switch (variant) {
      AppButtonVariant.fill => _ButtonStyle(
        background: colors.labelStrong,
        foreground: colors.staticWhite,
        text: text,
      ),
      AppButtonVariant.danger => _ButtonStyle(
        background: colors.statusDestructive,
        foreground: colors.staticWhite,
        text: text,
      ),
      AppButtonVariant.weak => _ButtonStyle(
        background: colors.backgroundNormal,
        // Figma: 떠 있는 Weak만 본문색, 나머지 Weak는 보조 본문색.
        foreground: size == AppButtonSize.floating
            ? colors.labelNormal
            : colors.labelNeutral,
        border: colors.lineNeutral,
        text: text,
      ),
    };
  }

  /// Figma 글자 스타일: 바탕이 칠해진 버튼은 굵게, Weak·테두리 버튼은 얇게.
  static TextStyle _text(
    AppTextStyles s,
    AppButtonSize size, {
    required bool emphasized,
  }) => switch (size) {
    AppButtonSize.large ||
    AppButtonSize.floating => emphasized ? s.title2Bold : s.title2Regular,
    AppButtonSize.medium => emphasized ? s.body1Bold : s.body1Medium,
    AppButtonSize.small => emphasized ? s.body1SemiBold : s.body1Medium,
  };
}

/// Figma `loader`: 점 3개, 앞에서부터 점점 옅어진다.
class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const opacities = [1.0, 0.7, 0.4];
    return Row(
      key: const ValueKey('appButton_loader'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < opacities.length; i++) ...[
          if (i > 0) const SizedBox(width: AppButtonTokens.loaderDotGap),
          Container(
            width: AppButtonTokens.loaderDotSize,
            height: AppButtonTokens.loaderDotSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: opacities[i]),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
