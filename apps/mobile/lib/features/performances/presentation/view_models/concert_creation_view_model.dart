import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/concert_creation_failure.dart';
import '../../models/concert_draft.dart';
import '../../models/host_band.dart';
import '../providers/concert_creation_providers.dart';

/// 합동공연 만들기 화면의 상태와 명령. 화면을 닫으면(로그아웃 포함) 정리된다.
final concertCreationViewModelProvider =
    NotifierProvider.autoDispose<
      ConcertCreationViewModel,
      ConcertCreationState
    >(ConcertCreationViewModel.new);

/// 합동공연 만들기 상태. 입력 중인 값은 화면(TextEditingController 등)이 갖는다.
class ConcertCreationState {
  const ConcertCreationState({
    this.submitting = false,
    this.errors = const {},
    this.failure,
    this.concertId,
  });

  /// 보내는 중. 버튼은 로딩으로 보이고 다시 눌리지 않는다.
  final bool submitting;

  /// 고쳐야 할 항목. 화면이 입력칸 아래에 안내한다.
  final Map<ConcertDraftField, ConcertDraftError> errors;

  /// 마지막 요청이 실패한 이유. 화면은 이 값이 생기면 안내를 띄운다.
  final ConcertCreationFailureReason? failure;

  /// 서버가 만든 공연 ID. 생기면 화면이 다음으로 넘어간다.
  final int? concertId;

  /// 다시 보낼 수 없는 상태: 보내는 중, 이미 만듦, 서버가 받았는지 모름, 권한 없음.
  /// 결과를 모르는 요청은 같은 공연이 두 번 생기지 않도록 이 화면에서 다시 보내지 않는다.
  bool get locked =>
      submitting ||
      concertId != null ||
      failure == ConcertCreationFailureReason.unavailable ||
      failure == ConcertCreationFailureReason.uncertain ||
      failure == ConcertCreationFailureReason.forbidden;
}

class ConcertCreationViewModel extends Notifier<ConcertCreationState> {
  @override
  ConcertCreationState build() => const ConcertCreationState();

  /// 밴드를 정한 즉시 기존 전송 차단 이유를 보여 준다.
  void restore(HostBand band) {
    final reason = ref
        .read(concertCreationRepositoryProvider)
        .blockReasonFor(band);
    if (reason != null) state = _failed(reason);
  }

  /// [draft]를 검사하고, 통과하면 [band]를 주최 팀으로 공연을 만든다. [ConcertCreationState.locked]면 무시한다.
  Future<void> submit(HostBand band, ConcertDraft draft) async {
    if (state.locked) return;
    final errors = draft.validate(today: ref.read(concertTodayProvider)());
    if (errors.isNotEmpty) {
      state = ConcertCreationState(errors: errors);
      return;
    }
    state = const ConcertCreationState(submitting: true);
    // 화면이 닫히면 보내는 중인 요청을 취소한다.
    final abandoned = Completer<void>();
    ref.onDispose(abandoned.complete);
    try {
      final concertId = await ref
          .read(concertCreationRepositoryProvider)
          .create(band, draft, abandoned: abandoned.future);
      // 화면을 닫았으면(로그아웃 포함) 늦은 응답은 버린다.
      if (!ref.mounted) return;
      state = ConcertCreationState(concertId: concertId);
    } on ConcertCreationFailure catch (failure) {
      if (!ref.mounted) return;
      if (kDebugMode) debugPrint('[ConcertCreation] 생성 실패: $failure');
      state = _failed(failure.reason);
    } catch (error) {
      // 성공 응답을 해석하지 못한 경우 등: 서버는 이미 만들었을 수 있다.
      if (!ref.mounted) return;
      if (kDebugMode) debugPrint('[ConcertCreation] 결과 불명: $error');
      state = _failed(ConcertCreationFailureReason.uncertain);
    }
  }

  static ConcertCreationState _failed(ConcertCreationFailureReason reason) =>
      ConcertCreationState(
        failure: reason,
        errors: reason == ConcertCreationFailureReason.pastDate
            ? const {ConcertDraftField.performDate: ConcertDraftError.pastDate}
            : const {},
      );
}
