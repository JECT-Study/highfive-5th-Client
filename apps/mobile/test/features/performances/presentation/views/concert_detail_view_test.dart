import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_detail_view.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_info_tab.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_page_header.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_participants_preview.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_tab_list.dart';
import 'package:highfive/shared/widgets/app_top_bar.dart';
import 'package:highfive/shared/widgets/empty_view.dart';
import 'package:highfive/shared/widgets/loading_view.dart';
import 'package:highfive/shared/widgets/show/show_header.dart';
import 'package:highfive/shared/widgets/show/show_team_avatar.dart';

/// 응답 시점을 테스트가 정한다.
class _PendingConcertRepository implements ConcertRepository {
  final response = Completer<ConcertDetail>();

  @override
  Future<ConcertDetail> fetchDetail(int concertId) => response.future;
}

class _ControlledConcertRepository implements ConcertRepository {
  var calls = 0;
  Future<ConcertDetail> Function() respond = () async =>
      FakeConcertRepository.sample;

  @override
  Future<ConcertDetail> fetchDetail(int concertId) {
    calls++;
    return respond();
  }
}

class _ControlledParticipantsRepository
    implements ConcertParticipantsRepository {
  var calls = 0;
  Future<List<ConcertParticipant>> Function() respond = () async =>
      FakeConcertParticipantsRepository.sample;

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) {
    calls++;
    return respond();
  }
}

Future<void> _pump(
  WidgetTester tester, {
  ConcertRepository? concerts,
  ConcertParticipantsRepository? participants,
  int? concertId = 12,
  VoidCallback? onBack,
  VoidCallback? onEdit,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        concertRepositoryProvider.overrideWithValue(
          concerts ?? FakeConcertRepository(),
        ),
        concertParticipantsRepositoryProvider.overrideWithValue(
          participants ?? FakeConcertParticipantsRepository(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: ConcertDetailView(
          concertId: concertId,
          onBack: onBack ?? () {},
          onEdit: onEdit,
          clock: () => DateTime(2026, 11, 28),
        ),
      ),
    ),
  );
  // 공연 상세와 참여 밴드 응답(마이크로태스크)을 차례로 반영한다. 시간을 흘려 자동 재시도를 부르지 않는다.
  await tester.pump();
  await tester.pump();
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ConcertDetailView)));

Finder _actionOf(Key key) =>
    find.descendant(of: find.byKey(key), matching: find.byType(AppButton));

Finder _tab(ConcertPageTab tab) => find
    .descendant(of: find.byType(AppTabList), matching: find.byType(InkWell))
    .at(tab.index);

void main() {
  testWidgets('참여자는 머리·탭과 정보 탭의 공연 정보·참여 밴드를 본다', (tester) async {
    await _pump(tester);

    expect(find.byType(ConcertPageHeader), findsOneWidget);
    expect(
      tester.widget<AppTabList>(find.byType(AppTabList)).labels,
      hasLength(ConcertPageTab.values.length),
    );
    expect(find.byType(ConcertInfoTab), findsOneWidget);
    expect(find.byType(ShowHeaderInfoRow), findsNWidgets(3));
    expect(
      find.byType(ShowTeamAvatar),
      findsNWidgets(FakeConcertParticipantsRepository.sample.length),
    );
  });

  testWidgets('불러오는 동안은 상단 바와 진행 표시만 보인다', (tester) async {
    final repository = _PendingConcertRepository();
    await _pump(tester, concerts: repository);

    expect(find.byType(AppTopBar), findsOneWidget);
    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.byType(ConcertPageHeader), findsNothing);

    repository.response.complete(FakeConcertRepository.sample);
    await tester.pump();
    expect(find.byType(ConcertPageHeader), findsOneWidget);
  });

  testWidgets('참여 팀 멤버가 아니면(403) 내용 없이 안내하고 이전 화면으로 돌아가게 한다', (tester) async {
    var backs = 0;
    await _pump(
      tester,
      concerts: FakeConcertRepository(forbiddenConcertIds: {12}),
      onBack: () => backs++,
    );

    expect(find.byKey(ConcertDetailView.forbiddenKey), findsOneWidget);
    expect(find.byType(ConcertPageHeader), findsNothing);

    await tester.tap(_actionOf(ConcertDetailView.forbiddenKey));
    expect(backs, 1);
  });

  testWidgets('응답의 내 밴드가 비어 있으면 참여자가 아닌 것으로 본다', (tester) async {
    await _pump(
      tester,
      concerts: FakeConcertRepository(
        concerts: [FakeConcertRepository.sample.copyWith(myBandIds: [])],
      ),
    );

    expect(find.byKey(ConcertDetailView.forbiddenKey), findsOneWidget);
    expect(find.byType(ConcertInfoTab), findsNothing);
  });

  testWidgets('없는 공연(404)은 안내하고 이전 화면으로 돌아가게 한다', (tester) async {
    var backs = 0;
    await _pump(tester, concertId: 99, onBack: () => backs++);

    expect(find.byKey(ConcertDetailView.notFoundKey), findsOneWidget);
    expect(find.byType(ConcertPageHeader), findsNothing);

    await tester.tap(_actionOf(ConcertDetailView.notFoundKey));
    expect(backs, 1);
  });

  testWidgets('다시 시도는 즉시 요청하고 응답 전 중복 탭은 새 요청을 보내지 않는다', (tester) async {
    final repository = _ControlledConcertRepository()
      ..respond = () => Future.error(const NetworkException());
    await _pump(tester, concerts: repository);
    expect(find.byKey(ConcertDetailView.failureKey), findsOneWidget);
    final response = Completer<ConcertDetail>();
    repository.respond = () => response.future;

    await tester.tap(_actionOf(ConcertDetailView.failureKey));
    await tester.pump();
    expect(repository.calls, 2);
    expect(
      tester.widget<AppButton>(_actionOf(ConcertDetailView.failureKey)).loading,
      isTrue,
    );
    await tester.tap(_actionOf(ConcertDetailView.failureKey));
    await tester.pump();
    expect(repository.calls, 2);

    response.complete(FakeConcertRepository.sample);
    await tester.pump();
    expect(find.byKey(ConcertDetailView.failureKey), findsNothing);
    expect(find.byType(ConcertPageHeader), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('상세 갱신이 실패하면 옛 내용 대신 실패와 다시 시도를 보인다', (tester) async {
    final repository = _ControlledConcertRepository();
    await _pump(tester, concerts: repository);
    expect(find.byType(ConcertPageHeader), findsOneWidget);

    repository.respond = () => Future.error(const NetworkException());
    _container(tester).invalidate(concertDetailProvider(12));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ConcertPageHeader), findsNothing);
    expect(find.byKey(ConcertDetailView.failureKey), findsOneWidget);
    repository.respond = () async => FakeConcertRepository.sample;
    await tester.tap(_actionOf(ConcertDetailView.failureKey));
    await tester.pump();
    await tester.pump();
    expect(find.byType(ConcertPageHeader), findsOneWidget);
  });

  testWidgets('참여 밴드 갱신에서 권한 철회·삭제를 알리면 이전 내용도 숨긴다', (tester) async {
    for (final (error, key) in [
      (
        const ApiException(statusCode: 403, code: 'AUTH_005'),
        ConcertDetailView.forbiddenKey,
      ),
      (
        const ApiException(statusCode: 404, code: 'CONCERT_001'),
        ConcertDetailView.notFoundKey,
      ),
    ]) {
      final repository = _ControlledParticipantsRepository();
      await _pump(tester, participants: repository);
      expect(find.byType(ShowTeamAvatar), findsNWidgets(2));

      repository.respond = () => Future.error(error);
      _container(tester).invalidate(concertParticipantsProvider(12));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(key), findsOneWidget);
      expect(find.byType(ConcertPageHeader), findsNothing);
      expect(find.byType(ShowTeamAvatar), findsNothing);
    }
  });

  testWidgets('다른 403·404와 코드가 어긋난 오류는 접근 차단 대신 다시 시도를 보인다', (tester) async {
    for (final error in [
      const ApiException(statusCode: 403, code: 'OTHER'),
      const ApiException(statusCode: 404),
      const ApiException(statusCode: 500, code: 'CONCERT_001'),
    ]) {
      await _pump(
        tester,
        concerts: _ControlledConcertRepository()
          ..respond = () => Future.error(error),
      );

      expect(find.byKey(ConcertDetailView.failureKey), findsOneWidget);
      expect(find.byKey(ConcertDetailView.forbiddenKey), findsNothing);
      expect(find.byKey(ConcertDetailView.notFoundKey), findsNothing);
    }
  });

  testWidgets('참여 밴드 재시도 중 탭을 왕복해도 중복 요청을 보내지 않는다', (tester) async {
    final repository = _ControlledParticipantsRepository()
      ..respond = () => Future.error(const NetworkException());
    await _pump(tester, participants: repository);
    final retry = find.descendant(
      of: find.byType(ConcertParticipantsPreview),
      matching: find.byType(AppButton),
    );
    final response = Completer<List<ConcertParticipant>>();
    repository.respond = () => response.future;
    await tester.tap(retry);
    await tester.pump();
    expect(repository.calls, 2);

    await tester.tap(_tab(ConcertPageTab.feed));
    await tester.pump();
    await tester.tap(_tab(ConcertPageTab.info));
    await tester.pump();

    expect(tester.widget<AppButton>(retry).loading, isTrue);
    await tester.tap(retry);
    await tester.pump();
    expect(repository.calls, 2);
    response.complete(FakeConcertParticipantsRepository.sample);
    await tester.pump();
    expect(find.byType(ShowTeamAvatar), findsNWidgets(2));
  });

  testWidgets('탭을 누르면 같은 화면에서 정보·피드·일정 내용이 바뀐다', (tester) async {
    await _pump(tester);

    for (final tab in [ConcertPageTab.feed, ConcertPageTab.schedule]) {
      await tester.tap(_tab(tab));
      await tester.pump();

      expect(
        tester.widget<AppTabList>(find.byType(AppTabList)).selectedIndex,
        tab.index,
      );
      expect(find.byType(ConcertInfoTab), findsNothing, reason: '$tab');
      expect(find.byType(EmptyView), findsOneWidget, reason: '$tab');
    }

    await tester.tap(_tab(ConcertPageTab.info));
    await tester.pump();
    expect(find.byType(ConcertInfoTab), findsOneWidget);
  });

  testWidgets('정보 수정을 누르면 onEdit을 부른다', (tester) async {
    var edits = 0;
    await _pump(tester, onEdit: () => edits++);

    await tester.tap(
      find.descendant(
        of: find.byType(ConcertPageHeader),
        matching: find.byType(AppButton),
      ),
    );

    expect(edits, 1);
  });

  testWidgets('폭 320의 작은 화면에서도 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester);

    expect(tester.takeException(), isNull);
  });
}
