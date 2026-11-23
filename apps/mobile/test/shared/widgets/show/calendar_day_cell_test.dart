import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/calendar_day_cell.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('날짜 칸을 누르면 onTap을 부른다', (tester) async {
    var taps = 0;
    await _pump(tester, CalendarDayCell(date: '12', onTap: () => taps++));

    await tester.tap(find.byType(CalendarDayCell));

    expect(taps, 1);
  });

  testWidgets('고른 날인지와 누를 수 있는지를 접근성 정보로 알린다', (tester) async {
    final semantics = tester.ensureSemantics();
    for (final selected in [false, true]) {
      await _pump(
        tester,
        CalendarDayCell(date: '12', selected: selected, onTap: () {}),
      );
      expect(
        tester.getSemantics(find.byType(CalendarDayCell)),
        isSemantics(
          isButton: true,
          isSelected: selected,
          hasSelectedState: true,
          isEnabled: true,
          hasEnabledState: true,
        ),
        reason: 'selected=$selected',
      );
    }

    await _pump(tester, const CalendarDayCell(date: '12'));
    expect(
      tester.getSemantics(find.byType(CalendarDayCell)),
      isSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
    );
    semantics.dispose();
  });

  testWidgets('빈 칸(Null)은 날짜 없이 날짜 칸과 같은 크기의 자리만 차지한다', (tester) async {
    await _pump(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CalendarDayCell.empty(),
          CalendarDayCell(date: '1'),
        ],
      ),
    );
    final empty = find.byType(CalendarDayCell).first;
    final day = find.byType(CalendarDayCell).last;

    expect(
      find.descendant(of: empty, matching: find.byType(Text)),
      findsNothing,
    );
    expect(tester.getSize(empty), tester.getSize(day));
  });
}
