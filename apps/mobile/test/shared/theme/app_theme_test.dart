import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_colors.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/theme/app_typography.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_chip.dart';
import 'package:highfive/shared/widgets/app_text_field.dart';

void main() {
  testWidgets('공연 다크 테마는 범위 안의 컨트롤만 바꾸고 OS 다크가 밖으로 새지 않는다', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    Brightness? outsideBrightness;
    Color? concertIconColor;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 335,
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    outsideBrightness = Theme.of(context).brightness;
                    return AppButton(
                      key: const ValueKey('light_button'),
                      label: '기존 버튼',
                      onPressed: () {},
                    );
                  },
                ),
                Theme(
                  data: AppTheme.concertDark,
                  child: Column(
                    children: [
                      Builder(
                        builder: (context) {
                          concertIconColor = IconTheme.of(context).color;
                          return const SizedBox.shrink();
                        },
                      ),
                      AppButton(
                        key: const ValueKey('concert_button'),
                        label: '공연 버튼',
                        onPressed: () {},
                      ),
                      AppChip(
                        key: const ValueKey('concert_chip'),
                        label: '선택 장르',
                        selected: true,
                        onTap: () {},
                      ),
                      const AppTextField(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Material materialIn(String key) => tester.widget<Material>(
      find
          .descendant(
            of: find.byKey(ValueKey(key)),
            matching: find.byType(Material),
          )
          .first,
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(outsideBrightness, Brightness.light);
    expect(concertIconColor, const Color(0xFFEAEAEB));
    expect(materialIn('light_button').color, const Color(0xFF000000));
    expect(materialIn('concert_button').color, const Color(0xFFC4FD5E));
    expect(materialIn('concert_chip').color, const Color(0xFFC4FD5E));
    expect(
      tester.widget<Text>(find.text('공연 버튼')).style?.color,
      const Color(0xFF0B0712),
    );
    expect(field.decoration?.fillColor, const Color(0xFF222125));
  });

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
