import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/concert_creation_repository.dart';
import 'package:highfive/features/performances/models/concert_creation_failure.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/models/concert_genre.dart';
import 'package:highfive/features/performances/models/host_band.dart';
import 'package:highfive/features/performances/presentation/providers/concert_creation_providers.dart';
import 'package:highfive/features/performances/presentation/view_models/concert_creation_view_model.dart';

/// 서버 대신 응답 시점을 테스트가 정한다. [results]를 앞에서부터 하나씩 쓴다.
class _FakeRepository extends ConcertCreationRepository {
  _FakeRepository(this.results);

  final List<Completer<int>> results;
  final drafts = <ConcertDraft>[];
  final abandoned = <Future<void>?>[];

  @override
  Future<int> create(
    HostBand band,
    ConcertDraft draft, {
    Future<void>? abandoned,
  }) {
    drafts.add(draft);
    this.abandoned.add(abandoned);
    return results[drafts.length - 1].future;
  }
}

const _band = HostBand(
  id: 3,
  name: '소음공장',
  genres: [ConcertGenre.rock],
  memberCount: 4,
);

final _valid = ConcertDraft(
  title: '겨울 합동공연',
  genres: const {ConcertGenre.rock},
  recruitTeamCount: 1,
  performDate: DateTime(2026, 12, 20),
  rentalFeeUndecided: true,
  rentalFeeText: '',
);

(ProviderContainer, ProviderSubscription<ConcertCreationState>) _container(
  _FakeRepository repository,
) {
  final container = ProviderContainer(
    overrides: [
      concertCreationRepositoryProvider.overrideWithValue(repository),
      concertTodayProvider.overrideWithValue(() => DateTime(2026, 11, 28)),
    ],
  );
  addTearDown(container.dispose);
  // 화면이 보고 있는 동안처럼 autoDispose 상태를 살려 둔다.
  final subscription = container.listen(
    concertCreationViewModelProvider,
    (_, _) {},
  );
  return (container, subscription);
}

Completer<int> _failWith(ConcertCreationFailureReason reason) =>
    Completer<int>()..completeError(ConcertCreationFailure(reason));

void main() {
  test('입력이 틀리면 보내지 않고 고칠 항목만 남긴다', () async {
    final repository = _FakeRepository([]);
    final (container, _) = _container(repository);

    await container
        .read(concertCreationViewModelProvider.notifier)
        .submit(
          _band,
          ConcertDraft(
            title: '',
            genres: const {},
            recruitTeamCount: 0,
            performDate: null,
            rentalFeeUndecided: true,
            rentalFeeText: '',
          ),
        );

    final state = container.read(concertCreationViewModelProvider);
    expect(repository.drafts, isEmpty);
    expect(state.submitting, isFalse);
    expect(state.errors.keys, {
      ConcertDraftField.title,
      ConcertDraftField.genres,
      ConcertDraftField.performDate,
      ConcertDraftField.recruitTeamCount,
    });
  });

  test('보내는 동안 다시 눌러도 한 번만 보내고, 성공하면 공연 ID를 남기고 잠근다', () async {
    final result = Completer<int>();
    final repository = _FakeRepository([result]);
    final (container, _) = _container(repository);
    final viewModel = container.read(concertCreationViewModelProvider.notifier);

    final first = viewModel.submit(_band, _valid);
    expect(container.read(concertCreationViewModelProvider).submitting, isTrue);
    await viewModel.submit(_band, _valid);
    expect(repository.drafts, hasLength(1));

    result.complete(12);
    await first;
    final state = container.read(concertCreationViewModelProvider);
    expect(state.concertId, 12);
    expect(state.locked, isTrue);

    await viewModel.submit(_band, _valid);
    expect(repository.drafts, hasLength(1));
  });

  test('네트워크 실패처럼 다시 보내도 되는 실패면 이유를 남기고 다시 보낼 수 있다', () async {
    final repository = _FakeRepository([
      _failWith(ConcertCreationFailureReason.network),
      Completer<int>()..complete(13),
    ]);
    final (container, _) = _container(repository);
    final viewModel = container.read(concertCreationViewModelProvider.notifier);

    await viewModel.submit(_band, _valid);
    expect(
      container.read(concertCreationViewModelProvider).failure,
      ConcertCreationFailureReason.network,
    );
    expect(container.read(concertCreationViewModelProvider).locked, isFalse);

    await viewModel.submit(_band, _valid);
    expect(repository.drafts, hasLength(2));
    expect(container.read(concertCreationViewModelProvider).concertId, 13);
  });

  test('서버가 받았는지 모르거나 권한이 없으면 이 화면에서 다시 보내지 않는다', () async {
    for (final reason in [
      ConcertCreationFailureReason.uncertain,
      ConcertCreationFailureReason.forbidden,
    ]) {
      final repository = _FakeRepository([_failWith(reason)]);
      final (container, _) = _container(repository);
      final viewModel = container.read(
        concertCreationViewModelProvider.notifier,
      );

      await viewModel.submit(_band, _valid);
      await viewModel.submit(_band, _valid);

      final state = container.read(concertCreationViewModelProvider);
      expect(state.failure, reason);
      expect(state.locked, isTrue, reason: '$reason');
      expect(repository.drafts, hasLength(1), reason: '$reason');
    }
  });

  test('서버가 지난 날짜라고 하면 날짜 항목에 오류를 남긴다', () async {
    final repository = _FakeRepository([
      _failWith(ConcertCreationFailureReason.pastDate),
    ]);
    final (container, _) = _container(repository);

    await container
        .read(concertCreationViewModelProvider.notifier)
        .submit(_band, _valid);

    expect(container.read(concertCreationViewModelProvider).errors, {
      ConcertDraftField.performDate: ConcertDraftError.pastDate,
    });
  });

  test('성공 응답을 해석하지 못하면 서버가 만들었을 수 있어 결과 불명으로 잠근다', () async {
    final repository = _FakeRepository([
      Completer<int>()..completeError(const FormatException('data 없음')),
    ]);
    final (container, _) = _container(repository);

    await container
        .read(concertCreationViewModelProvider.notifier)
        .submit(_band, _valid);

    final state = container.read(concertCreationViewModelProvider);
    expect(state.failure, ConcertCreationFailureReason.uncertain);
    expect(state.locked, isTrue);
  });

  test('화면이 닫힌 뒤 도착한 응답은 새로 연 화면의 상태를 바꾸지 않는다', () async {
    final lateResult = Completer<int>();
    final repository = _FakeRepository([lateResult]);
    final (container, subscription) = _container(repository);

    final pending = container
        .read(concertCreationViewModelProvider.notifier)
        .submit(_band, _valid);
    subscription.close();
    await container.pump();
    // 화면이 닫히면 보내는 중인 요청을 취소하라고 알린다.
    await expectLater(repository.abandoned.single, completes);

    // 같은 화면을 다시 열었다.
    container.listen(concertCreationViewModelProvider, (_, _) {});
    lateResult.complete(12);
    await pending;

    final state = container.read(concertCreationViewModelProvider);
    expect(state.concertId, isNull);
    expect(state.submitting, isFalse);
  });
}
