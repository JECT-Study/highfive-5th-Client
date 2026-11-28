import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_date_picker.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/show/calendar_day_cell.dart';
import 'package:highfive/shared/widgets/show/calendar_week_row.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    String? initialDate,
    String? originalDate,
    DateTime? today,
    DateTime? initialMonth,
    ValueChanged<({String? date})?>? onResult,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              key: const ValueKey('openDate'),
              onPressed: () async {
                final result = await showConcertDateSheet(
                  context,
                  initialDate: initialDate,
                  originalDate: originalDate,
                  today: today ?? DateTime(2026, 11, 26),
                  initialMonth: initialMonth,
                );
                onResult?.call(result);
              },
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('openDate')));
    await tester.pumpAndSettle();
  }

  Finder day(String date) => find.byKey(ValueKey('concertDate_$date'));

  testWidgets('날짜 입력은 API 값을 점과 한글 요일로 표시하며 달력 아이콘을 제공한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ConcertDateInput(value: '2026-11-26', onTap: () {}),
        ),
      ),
    );
    expect(find.text('2026.11.26 (목)'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
  });

  testWidgets('초기 미정은 오늘의 월만 열고 임의 날짜를 선택하지 않는다', (tester) async {
    ({String? date})? result;
    await open(tester, onResult: (value) => result = value);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('concertDate_month'))).data,
      '2026년 11월',
    );
    expect(
      tester
          .widgetList<CalendarDayCell>(find.byType(CalendarDayCell))
          .where((cell) => cell.selected),
      isEmpty,
    );
    await tester.tap(find.byKey(const ValueKey('concertDate_confirm')));
    await tester.pumpAndSettle();
    expect(result, (date: null));
  });

  testWidgets('기존 지난 날짜는 원래 월에 선택된 채 열리고 그대로 확인할 수 있다', (tester) async {
    ({String? date})? result;
    await open(
      tester,
      initialDate: '2020-02-29',
      originalDate: '2020-02-29',
      onResult: (value) => result = value,
    );
    expect(tester.widget<CalendarDayCell>(day('2020-02-29')).selected, isTrue);
    expect(tester.widget<CalendarDayCell>(day('2020-02-28')).onTap, isNull);
    await tester.tap(find.byKey(const ValueKey('concertDate_confirm')));
    await tester.pumpAndSettle();
    expect(result, (date: '2020-02-29'));
  });

  testWidgets('선택 중인 날짜는 닫을 때까지 호출자에게 전달하지 않고 취소 시 결과가 없다', (tester) async {
    var calls = 0;
    ({String? date})? result;
    await open(
      tester,
      initialDate: '2026-11-26',
      originalDate: '2026-11-26',
      onResult: (value) {
        calls++;
        result = value;
      },
    );
    await tester.tap(day('2026-11-27'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(tester.widget<CalendarDayCell>(day('2026-11-27')).selected, isTrue);
    final context = tester.element(
      find.byKey(const ValueKey('concertDate_sheet')),
    );
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(result, isNull);
  });

  testWidgets('확인한 날짜만 YYYY-MM-DD로 한 번 전달한다', (tester) async {
    var calls = 0;
    ({String? date})? result;
    await open(
      tester,
      onResult: (value) {
        calls++;
        result = value;
      },
    );
    await tester.tap(day('2026-11-27'));
    await tester.pumpAndSettle();
    final confirm = tester
        .widget<AppButton>(find.byKey(const ValueKey('concertDate_confirm')))
        .onPressed!;
    confirm();
    confirm();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(result, (date: '2026-11-27'));
  });

  for (final month in [
    (initial: '2026-12-31', next: '2027년 1월', back: '2026년 12월'),
    (initial: '2028-01-31', next: '2028년 2월', back: '2028년 1월'),
  ]) {
    testWidgets('연도·월 경계를 넘겨도 선택일은 자동 변경되지 않는다 (${month.initial})', (
      tester,
    ) async {
      ({String? date})? result;
      await open(
        tester,
        initialDate: month.initial,
        originalDate: month.initial,
        onResult: (value) => result = value,
      );
      await tester.tap(find.byKey(const ValueKey('concertDate_next')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('concertDate_month')))
            .data,
        month.next,
      );
      if (month.initial == '2028-01-31') {
        expect(day('2028-02-29'), findsOneWidget);
        expect(day('2028-02-30'), findsNothing);
      }
      await tester.tap(find.byKey(const ValueKey('concertDate_previous')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('concertDate_month')))
            .data,
        month.back,
      );
      await tester.tap(find.byKey(const ValueKey('concertDate_confirm')));
      await tester.pumpAndSettle();
      expect(result, (date: month.initial));
    });
  }

  testWidgets('일요일에 시작하는 달도 월요일 기준 빈 칸 여섯 개 후에 1일을 둔다', (tester) async {
    await open(tester);
    final rows = tester
        .widgetList<CalendarWeekRow>(find.byType(CalendarWeekRow))
        .toList();
    expect(
      tester.getCenter(day('2026-11-01')).dx,
      tester.getCenter(find.text('일')).dx,
    );
    expect(
      tester.getCenter(day('2026-11-02')).dx,
      tester.getCenter(find.text('월')).dx,
    );
    expect(rows.length, 7); // 요일 한 줄 + 6주
  });

  for (final size in [const Size(375, 812), const Size(320, 480)]) {
    testWidgets('일반 전화기와 짧은 화면에서 확인 버튼과 달력 끝에 접근할 수 있다 ($size)', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester);
      expect(
        find.byKey(const ValueKey('concertDate_confirm')).hitTestable(),
        findsOneWidget,
      );
      await tester.ensureVisible(day('2026-11-30'));
      await tester.pumpAndSettle();
      expect(day('2026-11-30').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
