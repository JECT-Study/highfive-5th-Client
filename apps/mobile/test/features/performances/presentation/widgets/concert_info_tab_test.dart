import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/models/concert_status.dart';
import 'package:highfive/features/performances/models/recruitment_status.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_info_tab.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_participants_preview.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_section.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/show_header.dart';
import 'package:highfive/shared/widgets/show/show_progress_card.dart';
import 'package:highfive/shared/widgets/show/show_team_avatar.dart';

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
      '500,000원',
    ]);
    expect(rows.map((row) => row.pending), [false, false, false, false]);
    expect(find.text(FakeConcertRepository.sample.address!), findsOneWidget);
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

    expect(_rows(tester).map((row) => row.pending), [true, true, true, false]);
  });

  testWidgets('종료 시각이 없으면 시작 시각만 보인다', (tester) async {
    await _pump(
      tester,
      FakeConcertRepository.sample.copyWith(startTime: '09:05', endTime: null),
    );

    expect(_rows(tester)[1].value, '09:05');
    expect(_rows(tester)[1].pending, isFalse);
  });

  testWidgets('모집 요약은 조회만 보이고 주최자를 제외한 빈자리를 그린다', (tester) async {
    await _pump(tester, FakeConcertRepository.sample);

    final card = tester.widget<ShowProgressCard>(find.byType(ShowProgressCard));
    expect(card.actions, isEmpty);
    final avatars = tester
        .widgetList<ShowTeamAvatar>(find.byType(ShowTeamAvatar))
        .toList();
    expect(avatars.where((avatar) => avatar.recruiting).length, 2);
    expect(avatars.where((avatar) => !avatar.recruiting).length, 2);
    expect(avatars.where((avatar) => avatar.hostLabel != null).length, 1);
  });

  testWidgets('공고·주소·대관비가 없으면 값을 만들어 내지 않는다', (tester) async {
    await _pump(
      tester,
      FakeConcertRepository.sample.copyWith(
        recruitment: null,
        address: null,
        rentalFee: null,
      ),
    );

    expect(find.byType(ShowProgressCard), findsNothing);
    expect(_rows(tester).length, 3);
    expect(find.text(FakeConcertRepository.sample.address!), findsNothing);
    expect(
      tester
          .widget<ConcertParticipantsPreview>(
            find.byType(ConcertParticipantsPreview),
          )
          .recruiting,
      isFalse,
    );
  });

  testWidgets('판매·모집 마감 각각에서 실제 빈자리 표시와 진행 단계를 바꾼다', (tester) async {
    await _pump(tester, FakeConcertRepository.sample);
    final activeLabels = tester
        .widgetList<ShowTeamAvatar>(find.byType(ShowTeamAvatar))
        .where((avatar) => avatar.recruiting)
        .map((avatar) => avatar.name)
        .toSet();
    expect(activeLabels, hasLength(1));

    for (final (detail, stage) in [
      (
        FakeConcertRepository.sample.copyWith(
          recruitment: FakeConcertRepository.sample.recruitment!.copyWith(
            status: RecruitmentStatus.closed,
          ),
        ),
        ShowProgressStage.recruiting,
      ),
      (
        FakeConcertRepository.sample.copyWith(status: ConcertStatus.selling),
        ShowProgressStage.ticketSales,
      ),
    ]) {
      await _pump(tester, detail);

      expect(
        tester.widget<ShowProgressCard>(find.byType(ShowProgressCard)).stage,
        stage,
      );
      expect(
        tester
            .widget<ConcertParticipantsPreview>(
              find.byType(ConcertParticipantsPreview),
            )
            .recruiting,
        isFalse,
      );
      final placeholders = tester
          .widgetList<ShowTeamAvatar>(find.byType(ShowTeamAvatar))
          .where((avatar) => avatar.recruiting)
          .toList();
      expect(placeholders, hasLength(2));
      // 문구 자체를 고정하지 않고, 실제 캡션이 모집 중 상태와 구별되는지 검증한다.
      expect(
        placeholders
            .map((avatar) => avatar.name)
            .toSet()
            .intersection(activeLabels),
        isEmpty,
      );
    }
  });

  testWidgets('큰 모집 목표는 요약 수를 유지하되 빈자리 위젯을 제한한다', (tester) async {
    await _pump(
      tester,
      FakeConcertRepository.sample.copyWith(recruitTeamCount: 100),
    );

    expect(
      tester
          .widgetList<ShowTeamAvatar>(find.byType(ShowTeamAvatar))
          .where((avatar) => avatar.recruiting)
          .length,
      5,
    );
    expect(
      tester
          .widgetList<ConcertSection>(find.byType(ConcertSection))
          .last
          .summary,
      contains('101'),
    );
  });
}
