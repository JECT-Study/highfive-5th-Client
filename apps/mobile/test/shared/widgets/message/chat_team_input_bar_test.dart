import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/message/chat_team_input_bar.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('대표자는 글자를 넣고 보낼 수 있다', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var sends = 0;
    await _pump(
      tester,
      ChatTeamInputBar(
        role: ChatTeamRole.representative,
        controller: controller,
        hintText: '궁금한 점을 입력해 주세요.',
        sendLabel: '보내기',
        onSend: () => sends++,
      ),
    );

    await tester.enterText(find.byType(TextField), '안녕하세요');
    await tester.pump();
    await tester.tap(find.byTooltip('보내기'));

    expect(sends, 1);
  });

  testWidgets('팀원은 입력창이 막히고 글자가 있어도 보낼 수 없다', (tester) async {
    final controller = TextEditingController(text: '안녕하세요');
    addTearDown(controller.dispose);
    var sends = 0;
    await _pump(
      tester,
      ChatTeamInputBar(
        role: ChatTeamRole.member,
        controller: controller,
        hintText: '팀 대표만 입력 가능해요',
        sendLabel: '보내기',
        onSend: () => sends++,
      ),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    await tester.tap(find.byTooltip('보내기'));
    expect(sends, 0);
  });
}
