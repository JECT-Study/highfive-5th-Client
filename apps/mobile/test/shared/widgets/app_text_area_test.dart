import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_text_area.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(child: SizedBox(width: 335, child: child)),
    ),
  ),
);

void main() {
  testWidgets('입력하면 글자 수가 바뀌고 최대 글자 수를 넘지 않는다', (tester) async {
    await _pump(tester, const AppTextArea(maxLength: 5));
    expect(find.text('0/5'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '하이파이브공연');
    await tester.pump();

    expect(find.text('5/5'), findsOneWidget);
  });

  testWidgets('비활성이면 입력되지 않는다', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, AppTextArea(controller: controller, enabled: false));

    await tester.enterText(find.byType(TextField), '공연');

    expect(controller.text, isEmpty);
  });
}
