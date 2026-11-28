import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../models/concert_detail.dart';
import '../../models/concert_edit_failure.dart';
import '../../models/concert_update.dart';
import '../providers/concert_detail_providers.dart';
import '../providers/concert_edit_providers.dart';

enum ConcertEditStatus {
  /// 입력 중. 저장할 수 있다.
  editing,

  /// 저장 요청 중이거나, 응답을 못 받아 저장 여부를 확인하는 중.
  saving,

  /// 서버 처리 완료 여부를 아직 모른다. 입력 대신 결과만 다시 확인한다.
  unconfirmed,

  /// 저장했다. 다시 보내지 않는다.
  saved,
}

/// 저장 명령의 상태. 입력 값은 화면이, 상세는 공용 [concertDetailProvider]가 들고 있다.
class ConcertEditState {
  const ConcertEditState({
    this.status = ConcertEditStatus.editing,
    this.failure,
  });

  final ConcertEditStatus status;

  /// 마지막 저장 실패. 다시 저장하면 지운다.
  final ConcertEditFailure? failure;
}

/// 공연 ID별 수정 저장. 화면이 닫히면 버리고, 그 뒤에 도착한 응답은 반영하지 않는다.
final concertEditProvider = NotifierProvider.autoDispose
    .family<ConcertEditViewModel, ConcertEditState, int>(
      ConcertEditViewModel.new,
      dependencies: [concertEditRepositoryProvider, concertRepositoryProvider],
    );

class ConcertEditViewModel extends Notifier<ConcertEditState> {
  ConcertEditViewModel(this.concertId);

  final int concertId;
  late ConcertUpdate _submitted;

  @override
  ConcertEditState build() => const ConcertEditState();

  /// 공연 정보를 저장한다. 저장 중이거나 이미 저장했으면 다시 보내지 않는다.
  /// 성공하면 공용 상세를 다시 불러오게 한다 (쓰기를 한 쪽이 갱신 책임을 진다).
  Future<void> save(ConcertUpdate update) async {
    if (state.status == ConcertEditStatus.unconfirmed) {
      await recheck();
      return;
    }
    if (state.status != ConcertEditStatus.editing) return;
    final operation = ref;
    _submitted = update;
    state = const ConcertEditState(status: ConcertEditStatus.saving);
    try {
      await operation
          .read(concertEditRepositoryProvider)
          .update(concertId, update);
    } on ConcertEditFailure catch (failure) {
      if (!operation.mounted) return;
      if (failure.reason == ConcertEditFailureReason.unconfirmed) {
        await _confirm(update, failure);
      } else {
        _fail(failure);
      }
      return;
    }
    if (!operation.mounted) return;
    _saved();
  }

  /// 새 폼의 version이 아니라 최초 PUT 본문으로만 비교한다. 쓰기는 재전송하지 않는다.
  Future<void> recheck() async {
    if (state.status != ConcertEditStatus.unconfirmed) return;
    state = const ConcertEditState(status: ConcertEditStatus.saving);
    await _confirm(
      _submitted,
      const ConcertEditFailure(ConcertEditFailureReason.unconfirmed),
    );
  }

  void _saved() {
    ref.invalidate(concertDetailProvider(concertId));
    state = const ConcertEditState(status: ConcertEditStatus.saved);
  }

  void _fail(ConcertEditFailure failure) {
    state = ConcertEditState(
      status: failure.reason == ConcertEditFailureReason.unconfirmed
          ? ConcertEditStatus.unconfirmed
          : ConcertEditStatus.editing,
      failure: failure,
    );
    // 명세: 다른 멤버가 먼저 고쳤으면 안내하고 최신 상세로 수정 화면을 다시 채운다.
    if (failure.reason == ConcertEditFailureReason.conflict) {
      ref.invalidate(concertDetailProvider(concertId));
    }
  }

  /// 응답을 받지 못한 저장은 실패로 단정하지 않는다 (docs/pr-checklist.md A4).
  /// 최신 상세를 한 번 읽어 version으로 반영 여부를 가린다. 같은 version으로 다시 보내도
  /// 서버가 `CONCERT_012`로 막으므로 두 번 반영되지 않는다.
  Future<void> _confirm(ConcertUpdate sent, ConcertEditFailure failure) async {
    final operation = ref;
    final ConcertDetail latest;
    try {
      latest = await operation
          .read(concertRepositoryProvider)
          .fetchDetail(concertId);
    } catch (error) {
      if (!operation.mounted) return;
      _fail(switch (error) {
        ApiException(code: 'CONCERT_001') => ConcertEditFailure(
          ConcertEditFailureReason.missing,
          cause: error,
        ),
        ApiException(code: 'AUTH_005') => ConcertEditFailure(
          ConcertEditFailureReason.forbidden,
          cause: error,
        ),
        _ => ConcertEditFailure(
          ConcertEditFailureReason.unconfirmed,
          cause: error,
        ),
      });
      return;
    }
    if (!operation.mounted) return;
    if (latest.version == sent.version) {
      // GET이 아직 처리 중인 PUT보다 먼저 끝났을 수 있다. 재전송하지 않고 다시 확인한다.
      _fail(
        ConcertEditFailure(
          ConcertEditFailureReason.unconfirmed,
          cause: failure,
        ),
      );
    } else if (ConcertUpdate.fromDetail(latest).sameContentAs(sent)) {
      _saved();
    } else {
      _fail(
        ConcertEditFailure(ConcertEditFailureReason.conflict, cause: failure),
      );
    }
  }
}
