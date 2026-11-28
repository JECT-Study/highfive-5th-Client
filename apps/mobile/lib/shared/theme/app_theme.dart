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
    fontFamily: AppFontFamily.pretendard,
    textTheme: AppTextStyles.standard.toTextTheme(),
    extensions: [AppColors.light, AppTextStyles.standard],
  );

  /// V3 공연 화면에서 Theme(data: AppTheme.concertDark, child: ...)로만 적용한다.
  /// MaterialApp.darkTheme·themeMode에는 연결하지 않는다.
  static final concertDark = light.copyWith(
    colorScheme: light.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: AppColors.concertDark.actionFill,
      onPrimary: AppColors.concertDark.actionForeground,
      secondary: AppColors.concertDark.actionSecondary,
      onSecondary: AppColors.concertDark.staticWhite,
      surface: AppColors.concertDark.backgroundNormal,
      onSurface: AppColors.concertDark.labelNormal,
      error: AppColors.concertDark.statusDestructive,
    ),
    scaffoldBackgroundColor: AppColors.concertDark.backgroundNormal,
    iconTheme: light.iconTheme.copyWith(
      color: AppColors.concertDark.labelNormal,
    ),
    primaryIconTheme: light.primaryIconTheme.copyWith(
      color: AppColors.concertDark.labelNormal,
    ),
    textTheme: light.textTheme.apply(
      bodyColor: AppColors.concertDark.labelNormal,
      displayColor: AppColors.concertDark.labelNormal,
    ),
    extensions: [AppColors.concertDark, AppTextStyles.standard],
  );
}
