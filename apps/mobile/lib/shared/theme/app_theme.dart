import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// 토큰(app_colors, app_typography, app_spacing, app_radius)을 `ThemeData`로 묶는다.
/// 색·크기 값은 여기서 새로 정하지 않고 토큰 파일에서만 가져온다.
abstract final class AppTheme {
  static final light = ThemeData(
    // Material 기본 위젯이 쓰는 primary는 Primary-Pink/500.
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.light.pink500,
      primary: AppColors.light.pink500,
      onPrimary: AppColors.light.staticWhite,
      secondary: AppColors.light.blue500,
      onSecondary: AppColors.light.staticWhite,
      surface: AppColors.light.backgroundNormal,
      // Material 3의 기본 글자색은 onSurface다. 토큰의 본문 색으로 맞춘다.
      onSurface: AppColors.light.labelNormal,
      error: AppColors.light.statusDestructive,
    ),
    scaffoldBackgroundColor: AppColors.light.backgroundNormal,
    textTheme: AppTypography.textTheme,
    extensions: const [AppColors.light],
  );
}
