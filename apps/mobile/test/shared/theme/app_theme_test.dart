import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_colors.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/theme/app_typography.dart';

void main() {
  test('글자 스타일의 색은 labelNormal 토큰이다', () {
    final t = AppTheme.light.textTheme;

    for (final style in [
      t.headlineSmall,
      t.titleLarge,
      t.bodyMedium,
      t.bodySmall,
    ]) {
      expect(style?.color, AppColors.light.labelNormal);
    }
  });

  test('Material 글자 스타일은 Pretendard와 Figma 스타일 값을 쓴다', () {
    final t = AppTheme.light.textTheme;
    final s = AppTextStyles.standard;

    expect(t.bodyMedium?.fontFamily, AppFontFamily.pretendard);
    expect(t.bodyMedium?.fontSize, s.body1Regular.fontSize);
    expect(t.bodyMedium?.fontWeight, FontWeight.w400);
    expect(t.titleLarge?.fontSize, s.title1Bold.fontSize);
    expect(t.titleLarge?.fontWeight, FontWeight.w700);
  });

  test('Head(B)는 Head(SB)와 크기·행간이 같고 굵기만 Bold다', () {
    final s = AppTextStyles.standard;

    expect(s.headBold.fontSize, s.head.fontSize);
    expect(s.headBold.height, s.head.height);
    expect(s.headBold.fontWeight, FontWeight.w700);
    // 기존 화면이 쓰는 head는 Head(SB) 그대로다.
    expect(s.head.fontWeight, FontWeight.w600);
  });
}
