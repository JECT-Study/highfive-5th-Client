import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_selection_controls.dart';
import 'package:highfive/shared/widgets/message/report_item.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('글자나 라디오 어디를 눌러도 onTap을 한 번씩 부른다', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      ReportItem(label: '스팸·광고', selected: false, onTap: () => taps++),
    );

    await tester.tap(find.text('스팸·광고'));
    await tester.tap(find.byType(AppRadio));

    expect(taps, 2);
  });

  testWidgets('고르고 입력 컨트롤러가 있을 때만 사유 입력칸을 연다', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    for (final (selected, withController, shown) in [
      (true, true, true),
      (false, true, false),
      (true, false, false),
    ]) {
      await _pump(
        tester,
        ReportItem(
          label: '기타',
          selected: selected,
          onTap: () {},
          reasonController: withController ? controller : null,
          reasonHintText: '(선택)구체적인 사유를 입력해 주세요.',
          reasonMaxLength: 200,
        ),
      );
      expect(
        find.byType(TextField),
        shown ? findsOneWidget : findsNothing,
        reason: 'selected=$selected, controller=$withController',
      );
    }
  });

  testWidgets('고른 상태를 접근성 정보로 알린다', (tester) async {
    final semantics = tester.ensureSemantics();
    for (final selected in [false, true]) {
      await _pump(
        tester,
        ReportItem(label: '스팸·광고', selected: selected, onTap: () {}),
      );
      expect(
        tester.getSemantics(find.text('스팸·광고')),
        isSemantics(
          isButton: true,
          isSelected: selected,
          hasSelectedState: true,
        ),
        reason: 'selected=$selected',
      );
    }
    semantics.dispose();
  });
}
