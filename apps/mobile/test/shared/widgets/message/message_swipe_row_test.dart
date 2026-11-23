import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/message/message_swipe_row.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

const _row = SizedBox(width: double.infinity, height: 85, child: Text('밴드'));

void main() {
  testWidgets('열렸을 때만 행동 버튼이 보이고, 누르면 onAction을 부른다', (tester) async {
    var actions = 0;
    Widget swipeRow({required bool revealed}) => MessageSwipeRow(
      revealed: revealed,
      actionLabel: '나가기',
      onAction: () => actions++,
      child: _row,
    );

    await _pump(tester, swipeRow(revealed: false));
    expect(find.text('나가기'), findsNothing);

    await _pump(tester, swipeRow(revealed: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('나가기'));

    expect(actions, 1);
  });

  testWidgets('왼쪽으로 밀면 열고, 오른쪽으로 밀면 닫으라고 알린다', (tester) async {
    final changes = <bool>[];
    await _pump(
      tester,
      MessageSwipeRow(
        actionLabel: '나가기',
        onAction: () {},
        onRevealedChanged: changes.add,
        child: _row,
      ),
    );

    await tester.fling(find.text('밴드'), const Offset(-200, 0), 1000);
    await tester.fling(find.text('밴드'), const Offset(200, 0), 1000);

    expect(changes, [true, false]);
  });
}
