import 'package:flutter/painting.dart';

/// 그림자 토큰. Figma 디자인 시스템 v3 Elevation(Shadow/Normal, Shadow/Spread).
/// 웹의 `--shadow-*`와 같은 값을 쓴다. Figma radius → `blurRadius`, spread → `spreadRadius`.
/// 위젯은 `BoxDecoration(boxShadow: AppShadows.small)`처럼 이것만 쓴다.
abstract final class AppShadows {
  static const xsmall = [
    BoxShadow(
      color: Color(0x1A171717),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
  ];

  static const small = [
    BoxShadow(
      color: Color(0x0F171717),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0F171717),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  static const medium = [
    BoxShadow(
      color: Color(0x12171717),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x12171717),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];

  static const large = [
    BoxShadow(
      color: Color(0x14171717),
      offset: Offset(0, 16),
      blurRadius: 24,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x14171717),
      offset: Offset(0, 6),
      blurRadius: 10,
      spreadRadius: -4,
    ),
  ];

  static const xlarge = [
    BoxShadow(
      color: Color(0x1F171717),
      offset: Offset(0, 24),
      blurRadius: 38,
      spreadRadius: -10,
    ),
    BoxShadow(
      color: Color(0x1A171717),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -5,
    ),
  ];

  /// 넓게 퍼지는 그림자 (Shadow/Spread). 바텀시트·떠 있는 카드.
  static const spreadSmall = [
    BoxShadow(color: Color(0x1A171717), blurRadius: 60),
  ];

  static const spreadMedium = [
    BoxShadow(color: Color(0x29171717), offset: Offset(0, 15), blurRadius: 75),
  ];
}
