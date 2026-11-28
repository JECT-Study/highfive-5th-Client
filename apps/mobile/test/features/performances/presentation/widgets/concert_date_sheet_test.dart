import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_date_sheet.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_top_bar.dart';
import 'package:highfive/shared/widgets/show/calendar_day_cell.dart';
import 'package:highfive/shared/widgets/show/calendar_week_row.dart';

class _Result {
  bool done = false;
  String? value;
}

/// 서울 기준 오늘이 2026-11-28인 상태로 시트를 연다.
Future<_Result> _open(
  WidgetTester tester, {
  String? initialDate,
  String? originalDate,
  Size size = const Size(375, 812),
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
  final result = _Result();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const ValueKey('open'),
              onPressed: () async {
                result.value = await showConcertDateSheet(
                  context,
                  initialDate: initialDate,
                  originalDate: originalDate,
                  today: DateTime(2026, 11, 28),
                );
                result.done = true;
              },
              child: const SizedBox.square(dimension: 44),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('open')));
  await tester.pumpAndSettle();
  return result;
}

CalendarDayCell _day(WidgetTester tester, String date) =>
    tester.widget<CalendarDayCell>(find.byKey(ValueKey('concertDate_$date')));

AppButton _confirm(WidgetTester tester) =>
    tester.widget<AppButton>(find.byKey(const ValueKey('concertDate_confirm')));

AppIconButton _arrow(WidgetTester tester, String name) =>
    tester.widget<AppIconButton>(find.byKey(ValueKey('concertDate_$name')));

void main() {
  testWidgets('오늘 이전 날짜는 고를 수 없고 원래 날짜는 지났어도 고를 수 있다', (tester) async {
    await _open(tester, initialDate: '2026-11-20', originalDate: '2026-11-20');

    expect(_day(tester, '2026-11-27').onTap, isNull);
    expect(_day(tester, '2026-11-20').onTap, isNotNull);
    expect(_day(tester, '2026-11-28').onTap, isNotNull);
    expect(_day(tester, '2026-11-20').selected, isTrue);
  });

  testWidgets('날짜를 고르고 확인해야 돌려주고, 닫으면 null을 돌려준다', (tester) async {
    final picked = await _open(
      tester,
      initialDate: '2026-12-20',
      originalDate: '2026-12-20',
    );
    await tester.tap(find.byKey(const ValueKey('concertDate_2026-12-24')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertDate_confirm')));
    await tester.pumpAndSettle();
    expect((picked.done, picked.value), (true, '2026-12-24'));

    final dismissed = await _open(tester, initialDate: '2026-12-20');
    await tester.tap(find.byKey(const ValueKey('concertDate_2026-12-24')));
    await tester.pump();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect((dismissed.done, dismissed.value), (true, null));
  });

  testWidgets('날짜를 고르기 전에는 확인할 수 없다', (tester) async {
    await _open(tester);

    expect(_confirm(tester).onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('concertDate_2026-11-30')));
    await tester.pump();
    expect(_confirm(tester).onPressed, isNotNull);
  });

  testWidgets('월요일부터 그 달의 주 수만큼 그리고, 가장 이른 달 앞으로는 가지 않는다', (tester) async {
    await _open(tester);

    // 2026년 11월 1일은 일요일: 빈 칸 6개 + 30일 = 6주 (+ 요일 줄 1개).
    expect(find.byType(CalendarWeekRow), findsNWidgets(7));
    expect(_arrow(tester, 'previous').onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('concertDate_next')));
    await tester.pump();
    // 12월 1일은 화요일: 빈 칸 1개 + 31일 = 5주.
    expect(find.byType(CalendarWeekRow), findsNWidgets(6));
    expect(_arrow(tester, 'previous').onPressed, isNotNull);
  });

  test('입력칸과 확인 팝업의 날짜 글자를 만든다', () {
    expect(concertDateLabel('2026-12-20'), '2026.12.20 (일)');
    expect(concertShortDateLabel('2026-10-12'), '10.12(월)');
  });

  testWidgets('320×480 화면에서도 넘치지 않고 확인 버튼을 누를 수 있다', (tester) async {
    final result = await _open(tester, size: const Size(320, 480));
    expect(tester.takeException(), isNull);
    final targetSize = tester.getSize(
      find.byKey(const ValueKey('concertDate_2026-11-30')),
    );
    expect(targetSize.width, greaterThanOrEqualTo(44));
    expect(targetSize.height, greaterThanOrEqualTo(44));

    // 마지막 주는 달력만 스크롤해서 닿는다. 확인 버튼은 아래에 고정돼 있다.
    await tester.ensureVisible(
      find.byKey(const ValueKey('concertDate_2026-11-30')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concertDate_2026-11-30')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertDate_confirm')));
    await tester.pumpAndSettle();

    expect(result.value, '2026-11-30');
  });
}
