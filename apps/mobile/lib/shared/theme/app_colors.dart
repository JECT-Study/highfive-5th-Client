import 'package:flutter/material.dart';

/// 원시(primitive) 팔레트. Figma 디자인 시스템 v3의 Primitive와 같은 이름·값.
/// 이 파일 밖에서 쓰지 않는다. 아직 안 쓰는 원시 값(gray.800 외 gray.*)은 docs 표에만 있고, 쓸 때 여기에 추가한다.
///
/// 값의 기준은 `docs/design-tokens.md`이고,
/// `apps/web/src/shared/styles/tokens.css`와 같은 값을 유지한다.
abstract final class _Palette {
  static const pink50 = Color(0xFFFFEAF4);
  static const pink300 = Color(0xFFFF5FA6);
  static const pink500 = Color(0xFFFF2F8C);
  static const pink600 = Color(0xFFE62A7E);
  static const pink700 = Color(0xFFC7256D);
  static const blue50 = Color(0xFFE9F4FF);
  static const blue500 = Color(0xFF2F97FF);
  static const blue600 = Color(0xFF2887E6);
  static const blue700 = Color(0xFF1A6EC2);
  static const gray800 = Color(0xFF0B0B0C);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

/// 의미(semantic) 색 토큰. 이름은 Figma Semantic 이름을 camelCase로 옮긴 것.
/// 위젯은 `context.colors.labelNormal`처럼 이것만 쓰고 hex 값이나 `Colors.*`를 직접 쓰지 않는다.
/// Figma Semantic 값이 Primitive에 없으면 여기에 값을 그대로 둔다.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.labelNormal,
    required this.labelStrong,
    required this.labelNeutral,
    required this.labelAlternative,
    required this.labelAssistive,
    required this.labelDisable,
    required this.backgroundNormal,
    required this.backgroundAlternative,
    required this.backgroundWarning,
    required this.interactionInactive,
    required this.interactionDisable,
    required this.lineNormal,
    required this.lineNeutral,
    required this.lineAlternative,
    required this.lineStrong,
    required this.statusPositive,
    required this.statusCautionary,
    required this.statusDestructive,
    required this.inversePrimary,
    required this.inverseBackground,
    required this.inverseLabel,
    required this.staticWhite,
    required this.staticBlack,
    required this.fillNormal,
    required this.fillStrong,
    required this.fillAlternative,
    required this.materialDimmer,
    required this.pink50,
    required this.pink300,
    required this.pink500,
    required this.pink600,
    required this.pink700,
    required this.blue50,
    required this.blue500,
    required this.blue600,
    required this.blue700,
    required this.gray800,
  });

  static const light = AppColors(
    labelNormal: Color(0xFF171719), // Label/Normal
    labelStrong: _Palette.black, // Label/Strong
    labelNeutral: Color(0xFF47484C), // Label/Neutral
    labelAlternative: Color(0xFF6E6E73), // Label/Alternative
    labelAssistive: Color(0xFFB9B9B9), // Label/Assistive
    labelDisable: Color(0xFFDFDFE0), // Label/Disable
    backgroundNormal: _Palette.white, // Background/Normal/Normal
    backgroundAlternative: Color(0xFFF7F7F8), // Background/Normal/Alternative
    backgroundWarning: Color(0xFFF1E1E1), // Background/Normal/Warning
    interactionInactive: Color(0xFF989BA2), // Interaction/Inactive
    interactionDisable: Color(0xFFF4F4F5), // Interaction/Disable
    lineNormal: Color(0xFFE0E0E2), // Line/Normal
    lineNeutral: Color(0xFFE8E8EA), // Line/Neutral
    lineAlternative: Color(0xFFF4F4F5), // Line/Alternative
    lineStrong: Color(0xFFD9D9D9), // Line/Strong
    statusPositive: Color(0xFF00BF40), // Status/Positive
    statusCautionary: Color(0xFFFF9200), // Status/Cautionary
    statusDestructive: Color(0xFFDB1F25), // Status/Destructive
    inversePrimary: Color(0xFF3385FF), // Inverse/Primary
    inverseBackground: Color(0xFF1B1C1E), // Inverse/Background
    inverseLabel: Color(0xFFF7F7F8), // Inverse/Label
    staticWhite: _Palette.white, // Static/White
    staticBlack: _Palette.black, // Static/Black
    fillNormal: Color(0xFFF4F4F5), // Fill/Normal
    fillStrong: Color(0xFFE8E8EA), // Fill/Strong
    fillAlternative: Color(0x0D70737C), // Fill/Alternative (5%)
    materialDimmer: Color(0x85171719), // Material/Dimmer (52%)
    pink50: _Palette.pink50, // Primary-Pink/50
    pink300: _Palette.pink300, // Primary-Pink/300
    pink500: _Palette.pink500, // Primary-Pink/500
    pink600: _Palette.pink600, // Primary-Pink/600
    pink700: _Palette.pink700, // Primary-Pink/700
    blue50: _Palette.blue50, // Primary-Blue/50
    blue500: _Palette.blue500, // Primary-Blue/500
    blue600: _Palette.blue600, // Primary-Blue/600
    blue700: _Palette.blue700, // Primary-Blue/700
    gray800: _Palette.gray800, // Neutral/Gray-800 (아이콘 기본색)
  );

  final Color labelNormal;
  final Color labelStrong;
  final Color labelNeutral;
  final Color labelAlternative;
  final Color labelAssistive;
  final Color labelDisable;
  final Color backgroundNormal;
  final Color backgroundAlternative;
  final Color backgroundWarning;
  final Color interactionInactive;
  final Color interactionDisable;
  final Color lineNormal;
  final Color lineNeutral;
  final Color lineAlternative;
  final Color lineStrong;
  final Color statusPositive;
  final Color statusCautionary;
  final Color statusDestructive;
  final Color inversePrimary;
  final Color inverseBackground;
  final Color inverseLabel;
  final Color staticWhite;
  final Color staticBlack;
  final Color fillNormal;
  final Color fillStrong;
  final Color fillAlternative;
  final Color materialDimmer;
  final Color pink50;
  final Color pink300;
  final Color pink500;
  final Color pink600;
  final Color pink700;
  final Color blue50;
  final Color blue500;
  final Color blue600;
  final Color blue700;
  final Color gray800;

  @override
  AppColors copyWith({
    Color? labelNormal,
    Color? labelStrong,
    Color? labelNeutral,
    Color? labelAlternative,
    Color? labelAssistive,
    Color? labelDisable,
    Color? backgroundNormal,
    Color? backgroundAlternative,
    Color? backgroundWarning,
    Color? interactionInactive,
    Color? interactionDisable,
    Color? lineNormal,
    Color? lineNeutral,
    Color? lineAlternative,
    Color? lineStrong,
    Color? statusPositive,
    Color? statusCautionary,
    Color? statusDestructive,
    Color? inversePrimary,
    Color? inverseBackground,
    Color? inverseLabel,
    Color? staticWhite,
    Color? staticBlack,
    Color? fillNormal,
    Color? fillStrong,
    Color? fillAlternative,
    Color? materialDimmer,
    Color? pink50,
    Color? pink300,
    Color? pink500,
    Color? pink600,
    Color? pink700,
    Color? blue50,
    Color? blue500,
    Color? blue600,
    Color? blue700,
    Color? gray800,
  }) {
    return AppColors(
      labelNormal: labelNormal ?? this.labelNormal,
      labelStrong: labelStrong ?? this.labelStrong,
      labelNeutral: labelNeutral ?? this.labelNeutral,
      labelAlternative: labelAlternative ?? this.labelAlternative,
      labelAssistive: labelAssistive ?? this.labelAssistive,
      labelDisable: labelDisable ?? this.labelDisable,
      backgroundNormal: backgroundNormal ?? this.backgroundNormal,
      backgroundAlternative:
          backgroundAlternative ?? this.backgroundAlternative,
      backgroundWarning: backgroundWarning ?? this.backgroundWarning,
      interactionInactive: interactionInactive ?? this.interactionInactive,
      interactionDisable: interactionDisable ?? this.interactionDisable,
      lineNormal: lineNormal ?? this.lineNormal,
      lineNeutral: lineNeutral ?? this.lineNeutral,
      lineAlternative: lineAlternative ?? this.lineAlternative,
      lineStrong: lineStrong ?? this.lineStrong,
      statusPositive: statusPositive ?? this.statusPositive,
      statusCautionary: statusCautionary ?? this.statusCautionary,
      statusDestructive: statusDestructive ?? this.statusDestructive,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      inverseBackground: inverseBackground ?? this.inverseBackground,
      inverseLabel: inverseLabel ?? this.inverseLabel,
      staticWhite: staticWhite ?? this.staticWhite,
      staticBlack: staticBlack ?? this.staticBlack,
      fillNormal: fillNormal ?? this.fillNormal,
      fillStrong: fillStrong ?? this.fillStrong,
      fillAlternative: fillAlternative ?? this.fillAlternative,
      materialDimmer: materialDimmer ?? this.materialDimmer,
      pink50: pink50 ?? this.pink50,
      pink300: pink300 ?? this.pink300,
      pink500: pink500 ?? this.pink500,
      pink600: pink600 ?? this.pink600,
      pink700: pink700 ?? this.pink700,
      blue50: blue50 ?? this.blue50,
      blue500: blue500 ?? this.blue500,
      blue600: blue600 ?? this.blue600,
      blue700: blue700 ?? this.blue700,
      gray800: gray800 ?? this.gray800,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      labelNormal: Color.lerp(labelNormal, other.labelNormal, t)!,
      labelStrong: Color.lerp(labelStrong, other.labelStrong, t)!,
      labelNeutral: Color.lerp(labelNeutral, other.labelNeutral, t)!,
      labelAlternative: Color.lerp(
        labelAlternative,
        other.labelAlternative,
        t,
      )!,
      labelAssistive: Color.lerp(labelAssistive, other.labelAssistive, t)!,
      labelDisable: Color.lerp(labelDisable, other.labelDisable, t)!,
      backgroundNormal: Color.lerp(
        backgroundNormal,
        other.backgroundNormal,
        t,
      )!,
      backgroundAlternative: Color.lerp(
        backgroundAlternative,
        other.backgroundAlternative,
        t,
      )!,
      backgroundWarning: Color.lerp(
        backgroundWarning,
        other.backgroundWarning,
        t,
      )!,
      interactionInactive: Color.lerp(
        interactionInactive,
        other.interactionInactive,
        t,
      )!,
      interactionDisable: Color.lerp(
        interactionDisable,
        other.interactionDisable,
        t,
      )!,
      lineNormal: Color.lerp(lineNormal, other.lineNormal, t)!,
      lineNeutral: Color.lerp(lineNeutral, other.lineNeutral, t)!,
      lineAlternative: Color.lerp(lineAlternative, other.lineAlternative, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      statusPositive: Color.lerp(statusPositive, other.statusPositive, t)!,
      statusCautionary: Color.lerp(
        statusCautionary,
        other.statusCautionary,
        t,
      )!,
      statusDestructive: Color.lerp(
        statusDestructive,
        other.statusDestructive,
        t,
      )!,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
      inverseBackground: Color.lerp(
        inverseBackground,
        other.inverseBackground,
        t,
      )!,
      inverseLabel: Color.lerp(inverseLabel, other.inverseLabel, t)!,
      staticWhite: Color.lerp(staticWhite, other.staticWhite, t)!,
      staticBlack: Color.lerp(staticBlack, other.staticBlack, t)!,
      fillNormal: Color.lerp(fillNormal, other.fillNormal, t)!,
      fillStrong: Color.lerp(fillStrong, other.fillStrong, t)!,
      fillAlternative: Color.lerp(fillAlternative, other.fillAlternative, t)!,
      materialDimmer: Color.lerp(materialDimmer, other.materialDimmer, t)!,
      pink50: Color.lerp(pink50, other.pink50, t)!,
      pink300: Color.lerp(pink300, other.pink300, t)!,
      pink500: Color.lerp(pink500, other.pink500, t)!,
      pink600: Color.lerp(pink600, other.pink600, t)!,
      pink700: Color.lerp(pink700, other.pink700, t)!,
      blue50: Color.lerp(blue50, other.blue50, t)!,
      blue500: Color.lerp(blue500, other.blue500, t)!,
      blue600: Color.lerp(blue600, other.blue600, t)!,
      blue700: Color.lerp(blue700, other.blue700, t)!,
      gray800: Color.lerp(gray800, other.gray800, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// `context.colors.labelNormal` 형태로 쓴다.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
