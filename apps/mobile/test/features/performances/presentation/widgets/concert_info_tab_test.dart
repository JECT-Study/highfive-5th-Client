import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_info_tab.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/show_header.dart';

Future<void> _pump(WidgetTester tester, ConcertDetail detail) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        concertParticipantsRepositoryProvider.overrideWithValue(
          FakeConcertParticipantsRepository(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(child: ConcertInfoTab(detail: detail)),
        ),
      ),
    ),
  );
  await tester.pump();
}

List<ShowHeaderInfoRow> _rows(WidgetTester tester) => tester
    .widgetList<ShowHeaderInfoRow>(find.byType(ShowHeaderInfoRow))
    .toList();

void main() {
  testWidgets('정해진 날짜·시작과 종료 시각·장소를 화면 값으로 옮긴다', (tester) async {
    await _pump(
      tester,
      FakeConcertRepository.sample.copyWith(
        startTime: '19:00:00',
        endTime: '21:30:59',
      ),
    );

    final rows = _rows(tester);
    expect(rows.map((row) => row.value), [
      '2026.12.20 (일)',
      '19:00 – 21:30',
      '홍대 롤링홀',
    ]);
    expect(rows.map((row) => row.pending), [false, false, false]);
  });

  testWidgets('정해지지 않은 값은 각 행을 미정 상태로 보인다', (tester) async {
    await _pump(
      tester,
      FakeConcertRepository.sample.copyWith(
        performDate: null,
        startTime: null,
        endTime: null,
        place: null,
      ),
    );

    expect(_rows(tester).map((row) => row.pending), [true, true, true]);
  });

  testWidgets('종료 시각이 없으면 시작 시각만 보인다', (tester) async {
    await _pump(
      tester,
      FakeConcertRepository.sample.copyWith(startTime: '09:05', endTime: null),
    );

    expect(_rows(tester)[1].value, '09:05');
    expect(_rows(tester)[1].pending, isFalse);
  });
}
