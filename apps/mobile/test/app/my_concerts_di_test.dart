import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/di.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/core/di/locator.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_my_concerts_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/providers/my_concerts_providers.dart';
import 'package:highfive/features/performances/presentation/view_models/my_concerts_view_model.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _DelayedConcertRepository extends FakeConcertRepository {
  _DelayedConcertRepository(this.response);

  final Completer<ConcertDetail> response;

  @override
  Future<ConcertDetail> fetchDetail(int concertId) =>
      concertId == 12 ? response.future : super.fetchDetail(concertId);
}

void main() {
  setUp(() {
    final previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
  });
  tearDown(() => getIt.reset());

  for (final flavor in Flavor.values) {
    test('${flavor.name} 실제 DI에서 내 공연 카드마다 같은 ID의 공연 상세와 참여 밴드가 열린다', () async {
      setupDi(AppEnv.forFlavorName(flavor.name));
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final concerts = await container
          .read(myConcertsRepositoryProvider)
          .fetchMyConcerts();

      expect(concerts, isNotEmpty);
      for (final concert in concerts) {
        final id = concert.concertId;
        // autoDispose 조회라 결과를 받을 때까지 구독해 둔다.
        final subscriptions = [
          container.listen(concertDetailProvider(id), (_, _) {}),
          container.listen(concertParticipantsProvider(id), (_, _) {}),
        ];
        addTearDown(() {
          for (final subscription in subscriptions) {
            subscription.close();
          }
        });

        final detail = await container.read(concertDetailProvider(id).future);
        final participants = await container.read(
          concertParticipantsProvider(id).future,
        );

        expect(detail.title, concert.title);
        expect(
          participants.singleWhere((band) => band.isHost).bandId,
          detail.hostBandId,
          reason: '$id',
        );
        expect(
          participants.map((band) => band.bandId),
          containsAll(detail.myBandIds),
          reason: '$id',
        );
        expect(
          participants.where((band) => !band.isHost).length,
          detail.recruitment!.joinedTeamCount,
          reason: '$id',
        );
      }
    });
  }

  test('계정 스코프를 바꾸면 새 상세 저장소로 목록을 읽고 이전 계정의 늦은 응답을 버린다', () async {
    setupDi(AppEnv.forFlavorName('dev'));
    final root = ProviderContainer(
      overrides: [
        myConcertsClockProvider.overrideWithValue(() => DateTime(2026, 11, 28)),
      ],
    );
    addTearDown(root.dispose);
    final pending = Completer<ConcertDetail>();
    final accountA = ProviderContainer(
      parent: root,
      overrides: [
        concertRepositoryProvider.overrideWithValue(
          _DelayedConcertRepository(pending),
        ),
      ],
    );
    accountA.listen(myConcertsViewModelProvider, (_, _) {});
    expect(accountA.read(myConcertsViewModelProvider).isLoading, isTrue);
    accountA.dispose();

    final accountB = ProviderContainer(
      parent: root,
      overrides: [
        concertRepositoryProvider.overrideWithValue(
          FakeConcertRepository(
            concerts: [
              FakeMyConcertsRepository.samples
                  .singleWhere((concert) => concert.concertId == 990002)
                  .copyWith(title: '계정 B 공연'),
            ],
          ),
        ),
      ],
    );
    addTearDown(accountB.dispose);
    final subscription = accountB.listen(
      myConcertsViewModelProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    final state = await accountB.read(myConcertsViewModelProvider.future);

    expect(state.current.map((concert) => concert.concertId), [990002]);
    pending.complete(FakeConcertRepository.sample.copyWith(title: '계정 A 공연'));
    await pending.future;
    await accountB.pump();

    expect(
      accountB
          .read(myConcertsViewModelProvider)
          .requireValue
          .current
          .map((concert) => (concert.concertId, concert.title)),
      [(990002, '계정 B 공연')],
    );
  });
}
