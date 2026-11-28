import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/my_concerts_repository.dart';
import 'package:highfive/features/performances/models/concert_status.dart';
import 'package:highfive/features/performances/models/my_concert.dart';
import 'package:highfive/features/performances/presentation/providers/my_concerts_providers.dart';
import 'package:highfive/features/performances/presentation/views/my_concerts_section.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/theme/app_spacing.dart';
import 'package:highfive/shared/widgets/app_band_card.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_tag.dart';

/// 서버 대신 목록을 돌려주고 읽은 횟수를 센다.
/// [response]가 있으면 응답 시점을 테스트가 정하고, [error]가 있으면 실패한다.
class _FakeMyConcertsRepository implements MyConcertsRepository {
  _FakeMyConcertsRepository(this.concerts, {this.error, this.response});

  final List<MyConcert> concerts;
  Object? error;
  final Completer<List<MyConcert>>? response;
  int fetchCount = 0;

  @override
  Future<List<MyConcert>> fetchMyConcerts() async {
    fetchCount++;
    if (response case final response?) return response.future;
    if (error case final error?) throw error;
    return concerts;
  }
}

MyConcert _concert(
  int id,
  String? performDate, {
  ConcertStatus status = ConcertStatus.recruiting,
  bool isHost = false,
  String? startTime,
  String title = '공연',
}) => MyConcert(
  concertId: id,
  title: '$title $id',
  status: status,
  performDate: performDate,
  startTime: startTime,
  area: '서울 마포구',
  isHost: isHost,
  posterImageUrl: null,
);

Future<void> _pump(
  WidgetTester tester,
  _FakeMyConcertsRepository repository, {
  Future<void> Function(int concertId)? onOpenConcert,
  Future<void> Function()? onAddConcert,
  DateTime Function()? clock,
  double textScale = 1,
}) {
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        myConcertsRepositoryProvider.overrideWithValue(repository),
        myConcertsClockProvider.overrideWithValue(
          clock ?? () => DateTime(2026, 11, 28, 12),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
            child: MyConcertsSection(
              onOpenConcert: onOpenConcert ?? (_) async {},
              onAddConcert: onAddConcert,
            ),
          ),
        ),
      ),
    ),
  );
}

AppBandCard _card(WidgetTester tester, int concertId) =>
    tester.widget<AppBandCard>(
      find.descendant(
        of: find.byKey(MyConcertsSection.cardKey(concertId)),
        matching: find.byType(AppBandCard),
      ),
    );

List<AppTagStyle> _tagStyles(AppBandCard card) => [
  for (final tag in card.tags) tag.style,
];

void main() {
  testWidgets('목록을 받는 동안 로딩을 보이고, 받으면 내용을 보인다', (tester) async {
    final response = Completer<List<MyConcert>>();
    await _pump(
      tester,
      _FakeMyConcertsRepository(const [], response: response),
    );

    expect(find.byKey(MyConcertsSection.loadingKey), findsOneWidget);

    response.complete([_concert(1, '2026-12-20')]);
    await tester.pumpAndSettle();

    expect(find.byKey(MyConcertsSection.loadingKey), findsNothing);
    expect(find.byKey(MyConcertsSection.cardKey(1)), findsOneWidget);
  });

  testWidgets('진행 중 공연은 카드로, 지난 공연은 이력 줄로 나눠 보인다', (tester) async {
    await _pump(
      tester,
      _FakeMyConcertsRepository([
        _concert(1, '2026-12-20'),
        _concert(2, null),
        _concert(3, '2026-10-02'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(MyConcertsSection.cardKey(1)), findsOneWidget);
    expect(find.byKey(MyConcertsSection.cardKey(2)), findsOneWidget);
    expect(find.byKey(MyConcertsSection.historyKey(3)), findsOneWidget);
    expect(find.byKey(MyConcertsSection.cardKey(3)), findsNothing);
    expect(find.byType(AppBandEmptyCard), findsNothing);
    expect(find.byKey(MyConcertsSection.emptyHistoryKey), findsNothing);
  });

  testWidgets('공연이 하나도 없으면 내 공연·공연 이력 모두 빈 안내를 보인다', (tester) async {
    await _pump(tester, _FakeMyConcertsRepository(const []));
    await tester.pumpAndSettle();

    expect(find.byType(AppBandCard), findsNothing);
    expect(find.byType(AppBandEmptyCard), findsOneWidget);
    expect(find.byKey(MyConcertsSection.emptyHistoryKey), findsOneWidget);
    // 공연 만들기 화면이 연결되지 않으면 추가 버튼은 비활성이다.
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);
  });

  testWidgets('지난 공연만 있으면 내 공연에는 빈 안내, 공연 이력에는 줄을 보인다', (tester) async {
    await _pump(tester, _FakeMyConcertsRepository([_concert(3, '2026-10-02')]));
    await tester.pumpAndSettle();

    expect(find.byType(AppBandEmptyCard), findsOneWidget);
    expect(find.byKey(MyConcertsSection.historyKey(3)), findsOneWidget);
  });

  testWidgets('카드 태그는 공연 상태·주최 여부·남은 날로 정한다', (tester) async {
    await _pump(
      tester,
      _FakeMyConcertsRepository([
        _concert(1, '2026-12-20', status: ConcertStatus.selling, isHost: true),
        _concert(2, null),
        _concert(3, '2026-11-28', status: ConcertStatus.saleClosed),
      ]),
    );
    await tester.pumpAndSettle();

    // 판매 중(Fill) · 주최 · D-day
    expect(_tagStyles(_card(tester, 1)), [
      AppTagStyle.filled,
      AppTagStyle.neutral,
      AppTagStyle.neutral,
    ]);
    expect(_card(tester, 1).tags.last.label, contains('22'));
    // 티켓 전(Outline). 날짜 미정이라 D-day 없음
    expect(_tagStyles(_card(tester, 2)), [AppTagStyle.outlined]);
    // 판매 마감은 시안에 상태 태그가 없고, 공연 당일은 D-day를 보이지 않는다.
    expect(_tagStyles(_card(tester, 3)), isEmpty);
  });

  testWidgets('카드는 월.일(요일)과 시:분, 이력 줄은 연.월.일로 날짜를 보인다', (tester) async {
    await _pump(
      tester,
      _FakeMyConcertsRepository([
        _concert(1, '2026-12-20', startTime: '19:00:00'),
        _concert(3, '2026-10-02'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(_card(tester, 1).date, '12.20(일)');
    expect(_card(tester, 1).time, '19:00');
    expect(
      find.descendant(
        of: find.byKey(MyConcertsSection.historyKey(3)),
        matching: find.text('2026.10.02'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('카드를 누르면 그 공연 ID로 공연 페이지를 열고, 돌아오면 목록을 다시 읽는다', (tester) async {
    final repository = _FakeMyConcertsRepository([
      _concert(1, '2026-12-20'),
      _concert(2, '2027-01-15'),
    ]);
    final opened = <int>[];
    final closed = Completer<void>();
    await _pump(
      tester,
      repository,
      onOpenConcert: (concertId) {
        opened.add(concertId);
        return closed.future;
      },
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(MyConcertsSection.cardKey(2)));
    await tester.pump();

    expect(opened, [2]);
    expect(repository.fetchCount, 1);

    closed.complete();
    await tester.pumpAndSettle();

    expect(repository.fetchCount, 2);
    expect(find.byKey(MyConcertsSection.cardKey(2)), findsOneWidget);
  });

  testWidgets('지난 공연 줄을 눌러도 그 공연 페이지를 연다', (tester) async {
    final opened = <int>[];
    await _pump(
      tester,
      _FakeMyConcertsRepository([_concert(3, '2026-10-02')]),
      onOpenConcert: (concertId) async => opened.add(concertId),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(MyConcertsSection.historyKey(3)));
    await tester.pumpAndSettle();

    expect(opened, [3]);
  });

  testWidgets('목록을 못 받으면 안내와 다시 시도를 보이고, 누르면 다시 읽는다', (tester) async {
    final repository = _FakeMyConcertsRepository([
      _concert(1, '2026-12-20'),
    ], error: const ApiException(statusCode: 503, code: 'SERVER_001'));
    await _pump(tester, repository);
    await tester.pumpAndSettle();

    expect(find.byKey(MyConcertsSection.failureKey), findsOneWidget);
    expect(find.byType(AppBandEmptyCard), findsNothing);

    repository.error = null;
    await tester.tap(
      find.descendant(
        of: find.byKey(MyConcertsSection.failureKey),
        matching: find.byType(AppButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(MyConcertsSection.failureKey), findsNothing);
    expect(find.byKey(MyConcertsSection.cardKey(1)), findsOneWidget);
    expect(repository.fetchCount, 2);
  });

  testWidgets('공연 만들기에서 돌아오면 새 공연을 다시 읽어 표시한다', (tester) async {
    final repository = _FakeMyConcertsRepository([]);
    final closed = Completer<void>();
    await _pump(tester, repository, onAddConcert: () => closed.future);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(repository.fetchCount, 1);

    repository.concerts.add(_concert(4, '2027-01-10'));
    closed.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(MyConcertsSection.cardKey(4)), findsOneWidget);
  });

  testWidgets('화면을 켜 둔 채 자정을 넘기면 어제 공연을 이력으로 옮긴다', (tester) async {
    var now = DateTime(2026, 11, 28, 23, 59, 59);
    await _pump(
      tester,
      _FakeMyConcertsRepository([_concert(1, '2026-11-28')]),
      clock: () => now,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(MyConcertsSection.cardKey(1)), findsOneWidget);

    now = DateTime(2026, 11, 29);
    // 시간 경계 자체가 검증 대상이다. 실제 대기 없이 가상 시계의 자정 타이머를 실행한다.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byKey(MyConcertsSection.cardKey(1)), findsNothing);
    expect(find.byKey(MyConcertsSection.historyKey(1)), findsOneWidget);
  });

  testWidgets('다음 날 앱으로 돌아오면 공연 분류를 갱신한다', (tester) async {
    var now = DateTime(2026, 11, 28, 12);
    await _pump(
      tester,
      _FakeMyConcertsRepository([_concert(1, '2026-11-28')]),
      clock: () => now,
    );
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2026, 11, 29, 12);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.byKey(MyConcertsSection.cardKey(1)), findsNothing);
    expect(find.byKey(MyConcertsSection.historyKey(1)), findsOneWidget);
  });

  testWidgets('폭 320에서 긴 제목이어도 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final longTitle = '아주 긴 제목의 합동공연' * 4;

    await _pump(
      tester,
      _FakeMyConcertsRepository([
        _concert(
          1,
          '2026-12-20',
          status: ConcertStatus.selling,
          isHost: true,
          startTime: '19:00:00',
          title: longTitle,
        ),
        _concert(3, '2026-10-02', title: longTitle),
      ]),
      textScale: 2.5,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
