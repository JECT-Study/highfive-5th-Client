import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// 토큰(app_colors, app_typography, app_spacing, app_radius)을 `ThemeData`로 묶는다.
/// 색·크기 값은 여기서 새로 정하지 않고 토큰 파일에서만 가져온다.
abstract final class AppTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.light.primary,
      primary: AppColors.light.primary,
      onPrimary: AppColors.light.onPrimary,
      surface: AppColors.light.surface,
      error: AppColors.light.danger,
    ),
    scaffoldBackgroundColor: AppColors.light.background,
    textTheme: AppTypography.textTheme,
    extensions: const [AppColors.light],
  );
}
