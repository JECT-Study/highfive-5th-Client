import 'package:flutter/material.dart';

/// 글꼴. `pubspec.yaml`의 fonts에 Regular·Medium·SemiBold·Bold만 넣었다.
abstract final class AppFontFamily {
  static const pretendard = 'Pretendard';
}

/// 글자 크기 토큰 (Figma 디자인 시스템 v3 타이포그래피). 웹의 `--font-size-*`와 같은 값을 쓴다.
abstract final class AppFontSize {
  static const head = 24.0;
  static const title1 = 18.0;
  static const title2 = 16.0;
  static const body1 = 14.0;
  static const caption1 = 12.0;
  static const tag = 10.0;
}

/// 행간(배수). Figma에서 auto인 스타일은 지정하지 않는다(글꼴 기본 행간).
abstract final class AppLineHeight {
  static const head = 1.3;
  static const body1 = 1.4;
  static const caption1 = 1.4;
}

TextStyle _style(double size, FontWeight weight, [double? height]) => TextStyle(
  fontFamily: AppFontFamily.pretendard,
  fontSize: size,
  fontWeight: weight,
  height: height,
  letterSpacing: 0,
);

/// 글자 스타일 토큰. 이름은 Figma 텍스트 스타일 이름(Title-1(B) → `title1Bold`).
/// 위젯은 `context.textStyles.body1Regular`처럼 이것만 쓰고 `TextStyle(fontSize: 16)`을 직접 만들지 않는다.
/// 색은 넣지 않는다. 기본 글자색(`labelNormal`)을 물려받고, 바꿀 때만 `.copyWith(color: context.colors.*)`.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.head,
    required this.title1Bold,
    required this.title1Regular,
    required this.title2Bold,
    required this.title2SemiBold,
    required this.title2Regular,
    required this.body1Bold,
    required this.body1SemiBold,
    required this.body1Medium,
    required this.body1Regular,
    required this.caption1SemiBold,
    required this.caption1Medium,
    required this.caption1Regular,
    required this.tag1,
    required this.tag2,
  });

  static final standard = AppTextStyles(
    head: _style(AppFontSize.head, FontWeight.w600, AppLineHeight.head),
    title1Bold: _style(AppFontSize.title1, FontWeight.w700),
    title1Regular: _style(AppFontSize.title1, FontWeight.w400),
    title2Bold: _style(AppFontSize.title2, FontWeight.w700),
    title2SemiBold: _style(AppFontSize.title2, FontWeight.w600),
    title2Regular: _style(AppFontSize.title2, FontWeight.w400),
    body1Bold: _style(AppFontSize.body1, FontWeight.w700, AppLineHeight.body1),
    body1SemiBold: _style(
      AppFontSize.body1,
      FontWeight.w600,
      AppLineHeight.body1,
    ),
    body1Medium: _style(
      AppFontSize.body1,
      FontWeight.w500,
      AppLineHeight.body1,
    ),
    body1Regular: _style(
      AppFontSize.body1,
      FontWeight.w400,
      AppLineHeight.body1,
    ),
    caption1SemiBold: _style(
      AppFontSize.caption1,
      FontWeight.w600,
      AppLineHeight.caption1,
    ),
    caption1Medium: _style(
      AppFontSize.caption1,
      FontWeight.w500,
      AppLineHeight.caption1,
    ),
    caption1Regular: _style(
      AppFontSize.caption1,
      FontWeight.w400,
      AppLineHeight.caption1,
    ),
    tag1: _style(AppFontSize.tag, FontWeight.w600),
    tag2: _style(AppFontSize.tag, FontWeight.w500),
  );

  final TextStyle head;
  final TextStyle title1Bold;
  final TextStyle title1Regular;
  final TextStyle title2Bold;
  final TextStyle title2SemiBold;
  final TextStyle title2Regular;
  final TextStyle body1Bold;
  final TextStyle body1SemiBold;
  final TextStyle body1Medium;
  final TextStyle body1Regular;
  final TextStyle caption1SemiBold;
  final TextStyle caption1Medium;
  final TextStyle caption1Regular;
  final TextStyle tag1;
  final TextStyle tag2;

  /// Material 기본 위젯(버튼·입력창·다이얼로그 등)이 쓰는 `TextTheme`에 Figma 스타일을 넣는다.
  /// 화면 코드는 `TextTheme` 이름 대신 `context.textStyles.*`를 쓴다.
  TextTheme toTextTheme() => TextTheme(
    headlineSmall: head,
    titleLarge: title1Bold,
    titleMedium: title2SemiBold,
    titleSmall: body1SemiBold,
    bodyLarge: title2Regular,
    bodyMedium: body1Regular,
    bodySmall: caption1Regular,
    labelLarge: body1SemiBold,
    labelMedium: caption1Medium,
    labelSmall: tag2,
  );

  @override
  AppTextStyles copyWith({
    TextStyle? head,
    TextStyle? title1Bold,
    TextStyle? title1Regular,
    TextStyle? title2Bold,
    TextStyle? title2SemiBold,
    TextStyle? title2Regular,
    TextStyle? body1Bold,
    TextStyle? body1SemiBold,
    TextStyle? body1Medium,
    TextStyle? body1Regular,
    TextStyle? caption1SemiBold,
    TextStyle? caption1Medium,
    TextStyle? caption1Regular,
    TextStyle? tag1,
    TextStyle? tag2,
  }) {
    return AppTextStyles(
      head: head ?? this.head,
      title1Bold: title1Bold ?? this.title1Bold,
      title1Regular: title1Regular ?? this.title1Regular,
      title2Bold: title2Bold ?? this.title2Bold,
      title2SemiBold: title2SemiBold ?? this.title2SemiBold,
      title2Regular: title2Regular ?? this.title2Regular,
      body1Bold: body1Bold ?? this.body1Bold,
      body1SemiBold: body1SemiBold ?? this.body1SemiBold,
      body1Medium: body1Medium ?? this.body1Medium,
      body1Regular: body1Regular ?? this.body1Regular,
      caption1SemiBold: caption1SemiBold ?? this.caption1SemiBold,
      caption1Medium: caption1Medium ?? this.caption1Medium,
      caption1Regular: caption1Regular ?? this.caption1Regular,
      tag1: tag1 ?? this.tag1,
      tag2: tag2 ?? this.tag2,
    );
  }

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other == null) return this;
    return AppTextStyles(
      head: TextStyle.lerp(head, other.head, t)!,
      title1Bold: TextStyle.lerp(title1Bold, other.title1Bold, t)!,
      title1Regular: TextStyle.lerp(title1Regular, other.title1Regular, t)!,
      title2Bold: TextStyle.lerp(title2Bold, other.title2Bold, t)!,
      title2SemiBold: TextStyle.lerp(title2SemiBold, other.title2SemiBold, t)!,
      title2Regular: TextStyle.lerp(title2Regular, other.title2Regular, t)!,
      body1Bold: TextStyle.lerp(body1Bold, other.body1Bold, t)!,
      body1SemiBold: TextStyle.lerp(body1SemiBold, other.body1SemiBold, t)!,
      body1Medium: TextStyle.lerp(body1Medium, other.body1Medium, t)!,
      body1Regular: TextStyle.lerp(body1Regular, other.body1Regular, t)!,
      caption1SemiBold: TextStyle.lerp(
        caption1SemiBold,
        other.caption1SemiBold,
        t,
      )!,
      caption1Medium: TextStyle.lerp(caption1Medium, other.caption1Medium, t)!,
      caption1Regular: TextStyle.lerp(
        caption1Regular,
        other.caption1Regular,
        t,
      )!,
      tag1: TextStyle.lerp(tag1, other.tag1, t)!,
      tag2: TextStyle.lerp(tag2, other.tag2, t)!,
    );
  }
}

extension AppTextStylesContext on BuildContext {
  /// `context.textStyles.body1Regular` 형태로 쓴다.
  AppTextStyles get textStyles => Theme.of(this).extension<AppTextStyles>()!;
}
