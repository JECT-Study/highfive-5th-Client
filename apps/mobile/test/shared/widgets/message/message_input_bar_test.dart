import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/message/message_input_bar.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('글자가 없거나 공백뿐이면 보내기를 눌러도 onSend를 부르지 않는다', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var sends = 0;
    await _pump(
      tester,
      MessageInputBar(
        controller: controller,
        hintText: '메시지를 입력해 주세요',
        sendLabel: '보내기',
        onSend: () => sends++,
      ),
    );

    await tester.tap(find.byTooltip('보내기'));
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    await tester.tap(find.byTooltip('보내기'));

    expect(sends, 0);
  });

  testWidgets('글자를 넣으면 보내기가 켜지고 누르면 onSend를 부른다', (tester) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var sends = 0;
    await _pump(
      tester,
      MessageInputBar(
        controller: controller,
        hintText: '메시지를 입력해 주세요',
        sendLabel: '보내기',
        onSend: () => sends++,
      ),
    );
    expect(
      tester.getSemantics(find.byTooltip('보내기')),
      isSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
    );

    await tester.enterText(find.byType(TextField), '안녕하세요');
    await tester.pump();
    expect(
      tester.getSemantics(find.byTooltip('보내기')),
      isSemantics(isButton: true, isEnabled: true, hasEnabledState: true),
    );
    await tester.tap(find.byTooltip('보내기'));

    expect(sends, 1);
    semantics.dispose();
  });

  testWidgets('enabled가 false면 입력창이 막히고 글자가 있어도 보낼 수 없다', (tester) async {
    final controller = TextEditingController(text: '안녕하세요');
    addTearDown(controller.dispose);
    var sends = 0;
    await _pump(
      tester,
      MessageInputBar(
        controller: controller,
        hintText: '팀 대표만 입력 가능해요',
        sendLabel: '보내기',
        onSend: () => sends++,
        enabled: false,
      ),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    await tester.tap(find.byTooltip('보내기'));
    expect(sends, 0);
  });
}
