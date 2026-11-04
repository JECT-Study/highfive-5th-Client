import 'package:flutter/material.dart';

/// 글자 크기 토큰. 웹의 `--font-size-*`와 같은 값을 쓴다.
abstract final class AppFontSize {
  static const sm = 14.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
}

/// 토큰을 Material `TextTheme`에 매핑한다. 위젯은 `Theme.of(context).textTheme.*`를 쓰고
/// `TextStyle(fontSize: 16)`처럼 크기를 직접 쓰지 않는다.
/// 지정하지 않은 스타일은 Material 기본값과 합쳐진다. 폰트 패밀리는 디자인 확정 후 넣는다.
abstract final class AppTypography {
  static const textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontSize: AppFontSize.xl,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontSize: AppFontSize.lg,
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: TextStyle(fontSize: AppFontSize.md),
    bodySmall: TextStyle(fontSize: AppFontSize.sm),
  );
}
