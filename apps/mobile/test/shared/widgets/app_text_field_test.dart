import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_colors.dart';
import 'package:highfive/shared/theme/app_component_tokens.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_text_field.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

InputDecoration _decoration(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).decoration!;

void main() {
  testWidgets('입력하면 onChanged로 값을 넘긴다', (tester) async {
    String? value;
    await _pump(tester, AppTextField(onChanged: (v) => value = v));

    await tester.enterText(find.byType(TextField), '하이파이브');

    expect(value, '하이파이브');
  });

  testWidgets('비활성이면 입력되지 않는다', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, AppTextField(controller: controller, enabled: false));

    await tester.enterText(find.byType(TextField), '하이파이브');

    expect(controller.text, isEmpty);
  });

  testWidgets('오류면 테두리를 statusDestructive로 바꾼다', (tester) async {
    await _pump(tester, const AppTextField(invalid: true));

    final border = _decoration(tester).enabledBorder! as OutlineInputBorder;
    expect(border.borderSide.color, AppColors.light.statusDestructive);
  });

  testWidgets('높이는 Input 토큰을 따른다', (tester) async {
    await _pump(tester, const SizedBox(width: 335, child: AppTextField()));

    expect(
      tester.getSize(find.byType(AppTextField)).height,
      AppInputTokens.height,
    );
  });

  testWidgets('보조행이 있어도 입력과 값 변경을 처리하고 보조행은 유지한다', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? changed;
    await _pump(
      tester,
      SizedBox(
        width: 335,
        child: AppTextField(
          controller: controller,
          subtext: '서울 마포구',
          onChanged: (value) => changed = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '공연장');

    expect(controller.text, '공연장');
    expect(changed, '공연장');
    expect(find.text('서울 마포구'), findsOneWidget);
    // V3 Input Fill/서브텍스트(1959:20282).
    expect(tester.getSize(find.byType(AppTextField)).height, 56);
    expect(
      tester.getRect(find.text('서울 마포구')).top,
      greaterThan(tester.getRect(find.byType(EditableText)).bottom),
    );
  });

  testWidgets('검색형은 prefix·suffix 사이 입력을 지울 수 있고 간격은 8이다', (tester) async {
    final controller = TextEditingController(text: '검색어');
    addTearDown(controller.dispose);
    await _pump(
      tester,
      SizedBox(
        width: 335,
        child: AppTextField(
          controller: controller,
          variant: AppTextFieldVariant.search,
          prefix: const SizedBox.square(
            key: ValueKey('search_prefix'),
            dimension: 24,
          ),
          suffix: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.clear,
            child: const SizedBox.square(
              key: ValueKey('search_clear'),
              dimension: 20,
            ),
          ),
        ),
      ),
    );

    final text = tester.getRect(find.byType(EditableText));
    final prefix = tester.getRect(find.byKey(const ValueKey('search_prefix')));
    final suffix = tester.getRect(find.byKey(const ValueKey('search_clear')));
    expect(text.left - prefix.right, 8);
    expect(suffix.left - text.right, 8);

    await tester.tap(find.byKey(const ValueKey('search_clear')));
    await tester.pump();

    expect(controller.text, isEmpty);
  });

  // Figma Input(1501:10747 글자 x=15, 654:5752 앞 아이콘 x=15 · 글자 x=49)과
  // 웹 TextField(border-box)처럼 여백 토큰은 1px 테두리 안쪽에서 잰다.
  testWidgets('글자·아이콘은 테두리 안쪽 Input 여백·간격에 둔다', (tester) async {
    const border = 1.0;
    const icon = 24.0;
    const inset = AppInputTokens.paddingX + border;
    Rect rectOf(Finder finder) => tester.getRect(finder);

    await _pump(
      tester,
      const SizedBox(width: 335, child: AppTextField(hintText: '이름')),
    );
    var field = rectOf(find.byType(AppTextField));
    var text = rectOf(find.byType(EditableText));
    expect(text.left - field.left, inset);
    expect(field.right - text.right, inset);

    await _pump(
      tester,
      const SizedBox(
        width: 335,
        child: AppTextField(
          hintText: '검색',
          prefix: SizedBox.square(key: ValueKey('prefix'), dimension: icon),
          suffix: SizedBox.square(key: ValueKey('suffix'), dimension: icon),
        ),
      ),
    );
    field = rectOf(find.byType(AppTextField));
    text = rectOf(find.byType(EditableText));
    final prefix = rectOf(find.byKey(const ValueKey('prefix')));
    final suffix = rectOf(find.byKey(const ValueKey('suffix')));
    expect(prefix.left - field.left, inset);
    expect(text.left - prefix.right, AppInputTokens.gap);
    expect(suffix.left - text.right, AppInputTokens.gap);
    expect(field.right - suffix.right, inset);
  });
}
