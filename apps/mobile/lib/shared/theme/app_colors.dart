import 'package:flutter/material.dart';

/// 원시(primitive) 팔레트. 이 파일 밖에서 쓰지 않는다.
///
/// 값의 기준은 `docs/design-tokens.md`이고,
/// `apps/web/src/shared/styles/tokens.css`와 같은 값을 유지한다.
abstract final class _Palette {
  static const brand500 = Color(0xFF4F46E5);
  static const brand600 = Color(0xFF4338CA);
  static const gray50 = Color(0xFFF9FAFB);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray600 = Color(0xFF4B5563);
  static const gray900 = Color(0xFF111827);
  static const red500 = Color(0xFFEF4444);
  static const white = Color(0xFFFFFFFF);
}

/// 의미(semantic) 색 토큰. 위젯은 `context.colors.primary`처럼 이것만 쓰고
/// hex 값이나 `Colors.*`를 직접 쓰지 않는다.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.danger,
  });

  static const light = AppColors(
    primary: _Palette.brand500,
    primaryPressed: _Palette.brand600,
    onPrimary: _Palette.white,
    background: _Palette.gray50,
    surface: _Palette.white,
    textPrimary: _Palette.gray900,
    textSecondary: _Palette.gray600,
    border: _Palette.gray200,
    danger: _Palette.red500,
  );

  final Color primary;
  final Color primaryPressed;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color danger;

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryPressed,
    Color? onPrimary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? danger,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// `context.colors.primary` 형태로 쓴다.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
