import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/models/concert_status.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_page_header.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/show/show_header.dart';

const _sample = FakeConcertRepository.sample;

Future<void> _pump(
  WidgetTester tester,
  ConcertDetail detail, {
  DateTime Function()? clock,
  VoidCallback? onEdit,
}) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: ConcertPageHeader(
        detail: detail,
        clock: clock ?? () => DateTime(2026, 11, 28),
        onEdit: onEdit,
      ),
    ),
  ),
);

List<AppTag> _tags(WidgetTester tester) =>
    tester.widgetList<AppTag>(find.byType(AppTag)).toList();

void main() {
  testWidgets('상태 태그와 공연 날짜까지 남은 날 수를 보인다', (tester) async {
    await _pump(tester, _sample);

    final tags = _tags(tester);
    expect(tags.map((tag) => tag.style), [
      AppTagStyle.filled,
      AppTagStyle.neutral,
    ]);
    expect(tags.last.label, 'D - 22');
  });

  testWidgets('앱이 모르는 상태는 상태 태그 없이 D-day만 보인다', (tester) async {
    await _pump(tester, _sample.copyWith(status: ConcertStatus.unknown));

    expect(_tags(tester).map((tag) => tag.style), [AppTagStyle.neutral]);
  });

  testWidgets('공연 당일·지난 공연·날짜 미정이면 D-day 태그가 없다', (tester) async {
    for (final performDate in ['2026-11-28', '2026-11-27', null]) {
      await _pump(tester, _sample.copyWith(performDate: performDate));

      expect(_tags(tester).map((tag) => tag.style), [
        AppTagStyle.filled,
      ], reason: '$performDate');
    }
  });

  testWidgets('정보 수정은 onEdit이 있을 때만 눌리고 누르면 onEdit을 부른다', (tester) async {
    await _pump(tester, _sample);
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);

    var edits = 0;
    await _pump(tester, _sample, onEdit: () => edits++);
    await tester.tap(find.byType(AppButton));

    expect(edits, 1);
  });

  testWidgets('장르 코드는 코드 목록의 이름으로 바꾸고 모르는 코드는 뺀다', (tester) async {
    await _pump(
      tester,
      _sample.copyWith(genres: ['ROCK', 'NEW_GENRE', 'PUNK']),
    );

    expect(tester.widget<ShowHeader>(find.byType(ShowHeader)).genres, [
      '록',
      '펑크',
    ]);
  });

  testWidgets('열어 둔 채 자정을 넘으면 D-day가 줄어든다', (tester) async {
    var now = DateTime(2026, 12, 18, 23, 59);
    await _pump(tester, _sample, clock: () => now);
    expect(_tags(tester).last.label, 'D - 2');

    now = DateTime(2026, 12, 19);
    await tester.pump(const Duration(minutes: 1));

    expect(_tags(tester).last.label, 'D - 1');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('공연 당일 앱에 돌아오면 D-day 태그를 숨긴다', (tester) async {
    var now = DateTime(2026, 12, 19);
    await _pump(tester, _sample, clock: () => now);
    expect(_tags(tester).last.label, 'D - 1');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    now = DateTime(2026, 12, 20);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(_tags(tester).map((tag) => tag.style), [AppTagStyle.filled]);
    await tester.pumpWidget(const SizedBox());
  });
}
