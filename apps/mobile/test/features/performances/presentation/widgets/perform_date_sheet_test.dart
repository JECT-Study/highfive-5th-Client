import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/presentation/widgets/perform_date_sheet.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/show/calendar_day_cell.dart';

import '../../../../support/capture.dart';

const _openKey = ValueKey('test_openSheet');
final _today = DateTime(2026, 11, 28, 21, 40);

/// 시트를 띄우고, 시트가 돌려준 값을 모을 목록을 돌려준다.
Future<List<DateTime?>> _open(
  WidgetTester tester, {
  DateTime? initialDate,
  double width = 390,
  double height = 844,
}) async {
  usePhoneSize(tester, width: width, height: height);
  final results = <DateTime?>[];
  await tester.pumpWidget(
    capturable(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: _openKey,
                onPressed: () async => results.add(
                  await showPerformDateSheet(
                    context,
                    today: _today,
                    initialDate: initialDate,
                  ),
                ),
                child: const SizedBox.square(dimension: 44),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(_openKey));
  await tester.pumpAndSettle();
  return results;
}

VoidCallback? _confirm(WidgetTester tester) =>
    tester.widget<AppButton>(find.byKey(PerformDateSheet.confirmKey)).onPressed;

void main() {
  setUpAll(loadCaptureFonts);

  testWidgets('오늘보다 이전 날짜는 고를 수 없고 지난달로 가지 않는다', (tester) async {
    final results = await _open(tester);
    expect(
      tester
          .widget<IconButton>(find.byKey(PerformDateSheet.previousMonthKey))
          .onPressed,
      isNull,
    );

    await tester.tap(
      find.byKey(PerformDateSheet.dayKey(DateTime(2026, 11, 27))),
    );
    await tester.pump();
    expect(_confirm(tester), isNull);

    await tester.tap(
      find.byKey(PerformDateSheet.dayKey(DateTime(2026, 11, 28))),
    );
    await tester.pump();
    await capture(tester, 'perform-date-sheet-1-today');
    await tester.tap(find.byKey(PerformDateSheet.confirmKey));
    await tester.pumpAndSettle();

    expect(results, [DateTime(2026, 11, 28)]);
  });

  testWidgets('다음 달로 넘겨 고른 날짜를 돌려주고, 다시 이번 달로 돌아올 수 있다', (tester) async {
    final results = await _open(tester);

    await tester.tap(find.byKey(PerformDateSheet.nextMonthKey));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(PerformDateSheet.dayKey(DateTime(2026, 12, 20))),
    );
    await tester.pump();
    await tester.tap(find.byKey(PerformDateSheet.previousMonthKey));
    await tester.pumpAndSettle();
    expect(
      find.byKey(PerformDateSheet.dayKey(DateTime(2026, 11, 30))),
      findsOneWidget,
    );
    await tester.tap(find.byKey(PerformDateSheet.confirmKey));
    await tester.pumpAndSettle();

    expect(results, [DateTime(2026, 12, 20)]);
  });

  testWidgets('이미 고른 날짜가 있으면 그 달을 열고 골라 둔다', (tester) async {
    await _open(tester, initialDate: DateTime(2027, 1, 15, 9));

    final day = tester.widget<CalendarDayCell>(
      find.byKey(PerformDateSheet.dayKey(DateTime(2027, 1, 15))),
    );
    expect(day.selected, isTrue);
    expect(_confirm(tester), isNotNull);
  });

  testWidgets('초기 선택 날짜가 오늘보다 이전이면 현재 달을 열고 선택을 지운다', (tester) async {
    await _open(tester, initialDate: DateTime(2026, 10, 31));

    expect(
      find.byKey(PerformDateSheet.dayKey(DateTime(2026, 11, 28))),
      findsOneWidget,
    );
    expect(_confirm(tester), isNull);
    expect(
      tester
          .widgetList<CalendarDayCell>(find.byType(CalendarDayCell))
          .where((day) => day.selected),
      isEmpty,
    );
  });

  testWidgets('폭 320에서도 날짜 터치 영역은 44×44 이상이다', (tester) async {
    await _open(tester, width: 320);

    for (final date in [DateTime(2026, 11, 28), DateTime(2026, 11, 29)]) {
      final day = find.byKey(PerformDateSheet.dayKey(date));
      expect(tester.getSize(day).width, greaterThanOrEqualTo(44));
      expect(tester.getSize(day).height, greaterThanOrEqualTo(44));
    }
    await capture(tester, 'perform-date-sheet-2-320');
  });

  testWidgets('높이 400에서도 6주 달력의 마지막 날짜를 골라 확정할 수 있다', (tester) async {
    final results = await _open(
      tester,
      initialDate: DateTime(2027, 5),
      height: 400,
    );
    final day = find.byKey(PerformDateSheet.dayKey(DateTime(2027, 5, 31)));
    await tester.scrollUntilVisible(
      day,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(day);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(PerformDateSheet.confirmKey),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await capture(tester, 'perform-date-sheet-3-short-height');
    await tester.tap(find.byKey(PerformDateSheet.confirmKey));
    await tester.pumpAndSettle();

    expect(results, [DateTime(2027, 5, 31)]);
  });
}
