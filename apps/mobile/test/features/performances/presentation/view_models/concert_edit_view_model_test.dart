import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/concert_edit_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/models/concert_edit_failure.dart';
import 'package:highfive/features/performances/models/concert_update.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_edit_providers.dart';
import 'package:highfive/features/performances/presentation/view_models/concert_edit_view_model.dart';

const _sample = FakeConcertRepository.sample;
final _update = ConcertUpdate.fromDetail(_sample).copyWith(title: '새 제목');

/// 서버의 공연 상세. 다른 멤버의 수정·조회 실패를 바꿔 끼운다.
class _Details implements ConcertRepository {
  ConcertDetail detail = _sample;
  Object? error;
  int fetches = 0;

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async {
    fetches++;
    if (error case final error?) throw error;
    return detail;
  }
}

class _HeldConfirmation extends _Details {
  final requested = Completer<void>();
  final response = Completer<ConcertDetail>();

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async {
    if (fetches == 0) return super.fetchDetail(concertId);
    fetches++;
    if (!requested.isCompleted) requested.complete();
    return response.future;
  }
}

/// 저장 요청. [respond]가 서버 처리와 응답을 흉내 낸다.
class _Edits implements ConcertEditRepository {
  _Edits(this.respond);

  final Future<void> Function(ConcertUpdate update) respond;
  final calls = <ConcertUpdate>[];

  @override
  Future<void> update(int concertId, ConcertUpdate update) {
    calls.add(update);
    return respond(update);
  }
}

/// 상세를 한 번 읽은 수정 화면 상태 (공연 페이지에서 들어온 경우와 같다).
Future<ProviderContainer> _open(_Details details, _Edits edits) async {
  final container = ProviderContainer(
    overrides: [
      concertRepositoryProvider.overrideWithValue(details),
      concertEditRepositoryProvider.overrideWithValue(edits),
    ],
  );
  addTearDown(container.dispose);
  final detail = container.listen(concertDetailProvider(12), (_, _) {});
  final edit = container.listen(concertEditProvider(12), (_, _) {});
  addTearDown(detail.close);
  addTearDown(edit.close);
  await container.read(concertDetailProvider(12).future);
  return container;
}

ConcertEditViewModel _viewModel(ProviderContainer container) =>
    container.read(concertEditProvider(12).notifier);

ConcertEditState _state(ProviderContainer container) =>
    container.read(concertEditProvider(12));

void main() {
  test('provider 재빌드 전에 시작한 결과 확인 GET도 새 상태를 바꾸지 않는다', () async {
    final details = _HeldConfirmation();
    final container = await _open(
      details,
      _Edits((_) async {
        throw const ConcertEditFailure(ConcertEditFailureReason.unconfirmed);
      }),
    );
    final saving = _viewModel(container).save(_update);
    await details.requested.future.timeout(const Duration(seconds: 5));

    container.invalidate(concertEditProvider(12));
    expect(_state(container).status, ConcertEditStatus.editing);
    details.response.complete(
      _sample.copyWith(title: _update.title, version: 4),
    );
    await saving;

    expect(_state(container).status, ConcertEditStatus.editing);
    expect(_state(container).failure, isNull);
  });

  test('provider를 재빌드한 뒤 이전 저장의 응답은 새 상태에 전달하지 않는다', () async {
    final details = _Details();
    final response = Completer<void>();
    final edits = _Edits((_) => response.future);
    final container = await _open(details, edits);
    final saving = _viewModel(container).save(_update);

    container.invalidate(concertEditProvider(12));
    expect(_state(container).status, ConcertEditStatus.editing);
    response.completeError(
      const ConcertEditFailure(ConcertEditFailureReason.forbidden),
    );
    await saving;

    expect(_state(container).failure, isNull);
    expect(_state(container).status, ConcertEditStatus.editing);
  });

  test('상세가 새 version으로 갱신되어도 최초 PUT 본문으로 결과를 확인한다', () async {
    final details = _Details();
    final edits = _Edits((_) async {
      throw const ConcertEditFailure(ConcertEditFailureReason.unconfirmed);
    });
    final container = await _open(details, edits);
    await _viewModel(container).save(_update);
    details.detail = _sample.copyWith(title: _update.title, version: 4);
    container.invalidate(concertDetailProvider(12));
    final reloaded = await container.read(concertDetailProvider(12).future);

    await _viewModel(container).save(ConcertUpdate.fromDetail(reloaded));

    expect(_state(container).status, ConcertEditStatus.saved);
    expect(edits.calls, hasLength(1));
  });

  test('저장에 성공하면 saved가 되고 공용 상세를 다시 읽는다', () async {
    final details = _Details();
    final edits = _Edits((update) async {
      details.detail = _sample.copyWith(title: update.title, version: 4);
    });
    final container = await _open(details, edits);

    await _viewModel(container).save(_update);

    expect(_state(container).status, ConcertEditStatus.saved);
    expect(edits.calls, [_update]);
    expect((await container.read(concertDetailProvider(12).future)).version, 4);
    expect(details.fetches, 2);
  });

  test('저장 중에 다시 눌러도, 저장한 뒤에 다시 눌러도 한 번만 보낸다', () async {
    final details = _Details();
    final response = Completer<void>();
    final edits = _Edits((_) => response.future);
    final container = await _open(details, edits);

    final first = _viewModel(container).save(_update);
    expect(_state(container).status, ConcertEditStatus.saving);
    await _viewModel(container).save(_update);
    response.complete();
    await first;
    await _viewModel(container).save(_update);

    expect(_state(container).status, ConcertEditStatus.saved);
    expect(edits.calls, hasLength(1));
  });

  test('다른 멤버가 먼저 수정했으면 충돌을 알리고 최신 상세를 다시 읽는다', () async {
    final details = _Details();
    final edits = _Edits((_) async {
      details.detail = _sample.copyWith(title: '다른 멤버', version: 5);
      throw const ConcertEditFailure(ConcertEditFailureReason.conflict);
    });
    final container = await _open(details, edits);

    await _viewModel(container).save(_update);

    final state = _state(container);
    expect(state.status, ConcertEditStatus.editing);
    expect(state.failure?.reason, ConcertEditFailureReason.conflict);
    expect((await container.read(concertDetailProvider(12).future)).version, 5);
  });

  test('입력 오류는 상세를 다시 읽지 않고 실패만 남겨 다시 저장할 수 있게 한다', () async {
    final details = _Details();
    final edits = _Edits(
      (_) async =>
          throw const ConcertEditFailure(ConcertEditFailureReason.invalid),
    );
    final container = await _open(details, edits);

    await _viewModel(container).save(_update);

    expect(_state(container).status, ConcertEditStatus.editing);
    expect(_state(container).failure?.reason, ConcertEditFailureReason.invalid);
    expect(details.fetches, 1);
  });

  group('응답을 받지 못하면 상세의 version으로 저장 여부를 가린다', () {
    test('결과 미확인 상태에서 다시 누르면 PUT 없이 GET으로만 확인한다', () async {
      final details = _Details();
      final edits = _Edits((_) async {
        throw const ConcertEditFailure(ConcertEditFailureReason.unconfirmed);
      });
      final container = await _open(details, edits);
      await _viewModel(container).save(_update);
      expect(_state(container).status, ConcertEditStatus.unconfirmed);
      details.detail = _sample.copyWith(title: _update.title, version: 4);

      await _viewModel(container).save(_update);

      expect(edits.calls, hasLength(1));
      expect(_state(container).status, ConcertEditStatus.saved);
    });

    Future<ConcertEditState> saveUnconfirmed(
      void Function(_Details details) serverAfter,
    ) async {
      final details = _Details();
      final edits = _Edits((_) async {
        serverAfter(details);
        throw const ConcertEditFailure(ConcertEditFailureReason.unconfirmed);
      });
      final container = await _open(details, edits);
      await _viewModel(container).save(_update);
      return _state(container);
    }

    test('version을 한 번 그대로 읽어도 처리 중일 수 있어 미확인으로 남긴다', () async {
      final state = await saveUnconfirmed((_) {});

      expect(state.status, ConcertEditStatus.unconfirmed);
      expect(state.failure?.reason, ConcertEditFailureReason.unconfirmed);
    });

    test('보낸 내용으로 version이 올랐으면 저장된 것으로 본다', () async {
      final state = await saveUnconfirmed(
        (details) =>
            details.detail = _sample.copyWith(title: _update.title, version: 4),
      );

      expect(state.status, ConcertEditStatus.saved);
    });

    test('다른 내용으로 version이 올랐으면 충돌로 본다', () async {
      final state = await saveUnconfirmed(
        (details) =>
            details.detail = _sample.copyWith(title: '다른 멤버', version: 4),
      );

      expect(state.failure?.reason, ConcertEditFailureReason.conflict);
    });

    test('상세도 읽지 못하면 확인하지 못했다고 남긴다', () async {
      final state = await saveUnconfirmed(
        (details) => details.error = const NetworkException(),
      );

      expect(state.status, ConcertEditStatus.unconfirmed);
      expect(state.failure?.reason, ConcertEditFailureReason.unconfirmed);
    });

    test('상세 해석이 실패해도 저장 중에 갇히지 않고 미확인으로 남긴다', () async {
      final state = await saveUnconfirmed(
        (details) => details.error = const FormatException('잘못된 상세 응답'),
      );

      expect(state.failure?.reason, ConcertEditFailureReason.unconfirmed);
      expect(state.status, isNot(ConcertEditStatus.saving));
    });

    test('그 사이 공연이 지워졌으면 공연 없음으로 알린다', () async {
      final state = await saveUnconfirmed(
        (details) => details.error = const ApiException(
          statusCode: 404,
          code: 'CONCERT_001',
        ),
      );

      expect(state.failure?.reason, ConcertEditFailureReason.missing);
    });
  });

  test('화면이 닫힌 뒤 도착한 응답은 상세를 건드리지 않는다', () async {
    final details = _Details();
    final response = Completer<void>();
    final edits = _Edits((_) => response.future);
    final container = ProviderContainer(
      overrides: [
        concertRepositoryProvider.overrideWithValue(details),
        concertEditRepositoryProvider.overrideWithValue(edits),
      ],
    );
    addTearDown(container.dispose);
    final detail = container.listen(concertDetailProvider(12), (_, _) {});
    addTearDown(detail.close);
    await container.read(concertDetailProvider(12).future);
    final edit = container.listen(concertEditProvider(12), (_, _) {});
    final saving = container
        .read(concertEditProvider(12).notifier)
        .save(_update);

    edit.close();
    await container.pump();
    response.complete();
    await saving;

    expect(details.fetches, 1);
  });
}
