import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../models/concert_access.dart';
import '../../models/concert_management_failure.dart';
import '../../models/concert_status.dart';
import '../providers/concert_detail_providers.dart';
import '../providers/concert_management_providers.dart';
import '../providers/concert_participants_providers.dart';

// 쓰기와 조회 갱신은 화면을 닫아도 현재 세션에서 끝까지 처리한다.
final concertManagementViewModelProvider =
    NotifierProvider.family<
      ConcertManagementViewModel,
      ConcertManagementState,
      int
    >(
      ConcertManagementViewModel.new,
      dependencies: [
        concertDetailProvider,
        concertManagementRepositoryProvider,
        concertParticipantsProvider,
      ],
    );

class ConcertManagementState {
  const ConcertManagementState({
    this.submitting = false,
    this.deleted = false,
    this.failure,
    this.removedBandIds = const {},
    this.owner,
    this.deleting = false,
  });

  final bool submitting;
  final bool deleted;
  final ConcertManagementFailure? failure;
  final Set<int> removedBandIds;
  final Object? owner;
  final bool deleting;
}

/// 버튼 노출과 별개로 명령에서도 권한·주최 팀·판매 상태·중복 호출을 막는다.
/// 최종 판단은 Repository(배포 후 서버)가 한다.
class ConcertManagementViewModel extends Notifier<ConcertManagementState> {
  ConcertManagementViewModel(this.concertId);

  final int concertId;

  @override
  ConcertManagementState build() {
    final repository = ref.watch(concertManagementRepositoryProvider);
    // 약한 구독은 화면 밖에서 GET 캐시를 붙잡지 않는다. 새 명단에 재합류한 ID만 푼다.
    ref.listen(concertParticipantsProvider(concertId), (_, next) {
      if (!repository.active ||
          next.isLoading ||
          next.hasError ||
          !next.hasValue ||
          state.submitting ||
          state.removedBandIds.isEmpty) {
        return;
      }
      final returned = {for (final team in next.value!) team.bandId};
      final remaining = state.removedBandIds.difference(returned);
      if (remaining.length == state.removedBandIds.length) return;
      state = ConcertManagementState(
        deleted: state.deleted,
        removedBandIds: Set.unmodifiable(remaining),
        owner: state.owner,
        deleting: state.deleting,
      );
    }, weak: true);
    return const ConcertManagementState();
  }

  Future<void> deleteConcert({Object? owner}) => _execute(owner: owner);

  Future<void> removeBand(int bandId, {Object? owner}) =>
      _execute(bandId: bandId, owner: owner);

  Future<void> _execute({int? bandId, Object? owner}) async {
    if (state.submitting ||
        state.deleted ||
        state.removedBandIds.contains(bandId)) {
      return;
    }
    final repository = ref.read(concertManagementRepositoryProvider);
    if (!repository.active) return;
    final removed = state.removedBandIds;
    final detail = ref.read(concertDetailProvider(concertId)).asData?.value;
    if (detail == null) return;
    final access = ConcertAccess(detail);
    final denied = !access.canManage
        ? ConcertManagementFailure.forbidden
        : bandId != null && bandId == detail.hostBandId
        ? ConcertManagementFailure.hostBand
        : bandId == null && !access.canDelete
        ? detail.status == ConcertStatus.unknown
              ? ConcertManagementFailure.unknownStatus
              : ConcertManagementFailure.sellingStarted
        : null;
    if (denied != null) {
      state = ConcertManagementState(
        failure: denied,
        owner: owner,
        deleting: bandId == null,
        removedBandIds: removed,
      );
      return;
    }

    state = ConcertManagementState(
      submitting: true,
      owner: owner,
      deleting: bandId == null,
      removedBandIds: removed,
    );
    try {
      if (bandId == null) {
        await repository.deleteConcert(concertId);
      } else {
        await repository.removeBand(concertId, bandId);
      }
      if (!ref.mounted || !repository.active) return;
      state = ConcertManagementState(
        deleted: bandId == null,
        removedBandIds: Set.unmodifiable({...removed, ?bandId}),
        owner: owner,
        deleting: bandId == null,
      );
      ref.invalidate(concertDetailProvider(concertId));
      ref.invalidate(concertParticipantsProvider(concertId));
    } on Exception catch (error) {
      if (!ref.mounted || !repository.active) return;
      final failure = switch (error) {
        ConcertManagementFailure failure => failure,
        ApiException(code: 'CONCERT_001') =>
          ConcertManagementFailure.concertNotFound,
        ApiException(code: 'AUTH_005') => ConcertManagementFailure.forbidden,
        ApiException(code: 'CONCERT_007') =>
          ConcertManagementFailure.bandNotParticipating,
        ApiException(code: 'CONCERT_008') => ConcertManagementFailure.hostBand,
        ApiException(code: 'CONCERT_009') =>
          ConcertManagementFailure.sellingStarted,
        NetworkException() => ConcertManagementFailure.network,
        _ => ConcertManagementFailure.unknown,
      };
      state = ConcertManagementState(
        failure: failure,
        owner: owner,
        deleting: bandId == null,
        removedBandIds: failure == ConcertManagementFailure.bandNotParticipating
            ? Set.unmodifiable({...removed, ?bandId})
            : removed,
      );
      if (failure == ConcertManagementFailure.forbidden ||
          failure == ConcertManagementFailure.sellingStarted ||
          failure == ConcertManagementFailure.unknownStatus) {
        ref.invalidate(concertDetailProvider(concertId));
      }
      if (failure == ConcertManagementFailure.bandNotParticipating) {
        ref.invalidate(concertParticipantsProvider(concertId));
        ref.invalidate(concertDetailProvider(concertId));
      }
    }
  }
}
