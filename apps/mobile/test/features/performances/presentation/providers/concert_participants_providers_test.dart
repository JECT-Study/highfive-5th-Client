import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';

class _CountingParticipantsRepository implements ConcertParticipantsRepository {
  _CountingParticipantsRepository(this.fetch);

  final Future<List<ConcertParticipant>> Function(int) fetch;
  var calls = 0;

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) {
    calls++;
    return fetch(concertId);
  }
}

ProviderContainer _container(ConcertParticipantsRepository repository) {
  final container = ProviderContainer(
    overrides: [
      concertParticipantsRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('없는 공연·참여하지 않은 공연은 자동 재시도 없이 바로 오류다', () async {
    final cases = [
      (FakeConcertParticipantsRepository(), 99),
      (FakeConcertParticipantsRepository(forbiddenConcertIds: {12}), 12),
    ];
    for (final (repository, concertId) in cases) {
      final counted = _CountingParticipantsRepository(
        repository.fetchParticipants,
      );
      final container = _container(counted);
      final firstError = Completer<AsyncValue<List<ConcertParticipant>>>();
      final subscription = container.listen(
        concertParticipantsProvider(concertId),
        (_, next) {
          if (next.hasError && !firstError.isCompleted) {
            firstError.complete(next);
          }
        },
      );
      addTearDown(subscription.close);

      final state = await firstError.future.timeout(const Duration(seconds: 5));

      expect(state, isA<AsyncError<List<ConcertParticipant>>>());
      expect(state.retrying, isFalse, reason: '$concertId');
      expect(counted.calls, 1);
    }
  });

  test('서버에 닿지 못한 오류는 자동 재시도를 기다린다', () async {
    final counted = _CountingParticipantsRepository(
      (_) => Future.error(const NetworkException()),
    );
    final container = _container(counted);
    final firstError = Completer<AsyncValue<List<ConcertParticipant>>>();
    final subscription = container.listen(concertParticipantsProvider(12), (
      _,
      next,
    ) {
      if (next.hasError && !firstError.isCompleted) {
        firstError.complete(next);
      }
    });
    addTearDown(subscription.close);

    final state = await firstError.future.timeout(const Duration(seconds: 5));

    expect(state.error, isA<NetworkException>());
    expect(state.retrying, isTrue);
    expect(counted.calls, 1);
  });
}
