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
  for (final hasEvent in [false, true]) {
    testWidgets('일정 표시 $hasEvent는 날짜 선택과 함께 전달한다', (tester) async {
      var taps = 0;
      final semantics = tester.ensureSemantics();
      await _pump(
        tester,
        CalendarDayCell(
          date: '12',
          hasEvent: hasEvent,
          selected: true,
          onTap: () => taps++,
        ),
      );

      await tester.tap(find.byType(CalendarDayCell));

      expect(taps, 1);
      expect(
        find.byKey(const ValueKey('calendarDay_event')),
        hasEvent ? findsOneWidget : findsNothing,
      );
      if (hasEvent) {
        final event = tester.getRect(
          find.byKey(const ValueKey('calendarDay_event')),
        );
        final day = tester.getRect(find.byType(CalendarDayCell));
        expect(event.size, const Size(4, 4));
        expect(event.top - day.top, 32);
        expect(
          tester.getSemantics(find.byType(CalendarDayCell)).value,
          '일정 있음',
        );
      }
      semantics.dispose();
    });
  }

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
