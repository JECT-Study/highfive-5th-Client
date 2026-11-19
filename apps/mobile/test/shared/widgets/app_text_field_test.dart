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
}
