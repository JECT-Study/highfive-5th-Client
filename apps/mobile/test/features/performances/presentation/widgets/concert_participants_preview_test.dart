import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_management_repository.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_management_providers.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_participants_preview.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/empty_view.dart';
import 'package:highfive/shared/widgets/error_view.dart';
import 'package:highfive/shared/widgets/loading_view.dart';
import 'package:highfive/shared/widgets/show/show_team_avatar.dart';

/// 응답 시점을 테스트가 정한다.
class _PendingParticipantsRepository implements ConcertParticipantsRepository {
  final response = Completer<List<ConcertParticipant>>();

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) =>
      response.future;
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
  WidgetTester tester,
  ConcertParticipantsRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        concertRepositoryProvider.overrideWithValue(FakeConcertRepository()),
        concertManagementRepositoryProvider.overrideWith(
          (ref) => FakeConcertManagementRepository(
            ref.watch(concertRepositoryProvider),
            ref.watch(concertParticipantsRepositoryProvider),
          ),
        ),
        concertParticipantsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ConcertParticipantsPreview(concertId: 12),
          ),
        ),
      ),
    ),
  );
  // 저장소 응답(마이크로태스크)을 반영한다. 시간을 흘려 자동 재시도를 부르지 않는다.
  await tester.pump();
}

void main() {
  testWidgets('참여 밴드를 공연 순서대로 보이고 주최 팀에만 주최 배지를 단다', (tester) async {
    await _pump(tester, FakeConcertParticipantsRepository());

    final avatars = tester
        .widgetList<ShowTeamAvatar>(find.byType(ShowTeamAvatar))
        .toList();
    expect(
      avatars.map((avatar) => avatar.name),
      FakeConcertParticipantsRepository.sample.map((team) => team.name),
    );
    expect(avatars.map((avatar) => avatar.hostLabel != null), [true, false]);
  });

  testWidgets('불러오는 동안은 진행 표시만 보인다', (tester) async {
    final repository = _PendingParticipantsRepository();
    await _pump(tester, repository);

    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.byType(ShowTeamAvatar), findsNothing);

    repository.response.complete(const []);
    await tester.pump();
  });

  testWidgets('참여 밴드가 없으면 빈 안내를 보인다', (tester) async {
    await _pump(
      tester,
      FakeConcertParticipantsRepository(participants: {12: const []}),
    );

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.byType(ShowTeamAvatar), findsNothing);
  });

  testWidgets('다시 시도는 즉시 요청하고 응답 전 중복 탭은 새 요청을 보내지 않는다', (tester) async {
    for (final error in [
      const NetworkException(),
      const ApiException(statusCode: 404),
    ]) {
      final repository = _ControlledParticipantsRepository()
        ..respond = () => Future.error(error);
      await _pump(tester, repository);
      expect(find.byType(ErrorView), findsOneWidget);
      final response = Completer<List<ConcertParticipant>>();
      repository.respond = () => response.future;

      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(repository.calls, 2);
      expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isTrue);
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(repository.calls, 2);

      response.complete(FakeConcertParticipantsRepository.sample);
      await tester.pump();
      expect(find.byType(ErrorView), findsNothing);
      expect(find.byType(ShowTeamAvatar), findsNWidgets(2));
    }
  });

  testWidgets('갱신이 실패하면 옛 이름 대신 오류와 다시 시도를 보인다', (tester) async {
    final repository = _ControlledParticipantsRepository();
    await _pump(tester, repository);
    expect(find.byType(ShowTeamAvatar), findsNWidgets(2));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertParticipantsPreview)),
    );

    repository.respond = () => Future.error(const NetworkException());
    container.invalidate(concertParticipantsProvider(12));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ShowTeamAvatar), findsNothing);
    expect(find.byType(ErrorView), findsOneWidget);
    repository.respond = () async => FakeConcertParticipantsRepository.sample;
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    await tester.pump();
    expect(find.byType(ShowTeamAvatar), findsNWidgets(2));
  });
}
