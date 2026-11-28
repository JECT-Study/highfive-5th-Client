import 'dart:async';

import '../../../../core/error/app_exception.dart';
import '../../models/concert_access.dart';
import '../../models/concert_detail.dart';
import '../../models/concert_participant.dart';
import '../../models/concert_management_failure.dart';
import '../../models/concert_status.dart';
import 'concert_management_repository.dart';
import 'concert_participants_repository.dart';
import 'concert_repository.dart';

/// GET/DELETE 미배포용 메모리 저장소. 같은 인스턴스를 조회·명령 DI에 등록한다.
/// 삭제 기록과 참여 상태는 라우트/Provider 수명 밖에 두어 재진입에도 유지한다.
class FakeConcertManagementRepository implements ConcertManagementRepository {
  FakeConcertManagementRepository(this._details, this._participantReads);

  final ConcertRepository _details;
  final ConcertParticipantsRepository _participantReads;
  final _deletedIds = <int>{};
  final _removedBandIds = <int, Set<int>>{};
  final _ended = StreamController<void>.broadcast(sync: true);
  var _active = true;

  @override
  bool get active => _active;

  @override
  Stream<void> get sessionEnded => _ended.stream;

  @override
  void endSession() {
    if (!_active) return;
    _active = false;
    _ended.add(null);
    unawaited(_ended.close());
  }

  void _checkSession() {
    if (!_active) {
      throw const ApiException(statusCode: 403, code: 'AUTH_005');
    }
  }

  void _checkAvailable(int concertId) {
    _checkSession();
    if (_deletedIds.contains(concertId)) {
      throw const ApiException(statusCode: 404, code: 'CONCERT_001');
    }
  }

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async {
    final detail = await _details.fetchDetail(concertId);
    _checkAvailable(concertId);
    final removed = _removedBandIds[concertId];
    if (removed == null) return detail;
    final recruitment = detail.recruitment;
    final participants = await _participantReads.fetchParticipants(concertId);
    _checkAvailable(concertId);
    return detail.copyWith(
      myBandIds: detail.myBandIds.where((id) => !removed.contains(id)).toList(),
      recruitment: recruitment?.copyWith(
        joinedTeamCount: participants
            .where((team) => !team.isHost && !removed.contains(team.bandId))
            .length,
      ),
    );
  }

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) async {
    await fetchDetail(concertId);
    final participants = await _participantReads.fetchParticipants(concertId);
    _checkAvailable(concertId);
    final removed = _removedBandIds[concertId] ?? const <int>{};
    return List.unmodifiable(
      participants.where((team) => !removed.contains(team.bandId)),
    );
  }

  @override
  Future<void> deleteConcert(int concertId) async {
    // 쓰기 판정은 모집 현황을 합성하는 조회가 아닌 원본의 마지막 권한·상태로 한다.
    final detail = await _details.fetchDetail(concertId);
    _checkAvailable(concertId);
    final access = ConcertAccess(detail);
    if (!access.canManage) {
      throw const ApiException(statusCode: 403, code: 'AUTH_005');
    }
    if (detail.status == ConcertStatus.unknown) {
      throw ConcertManagementFailure.unknownStatus;
    }
    if (!access.canDelete) {
      throw const ApiException(statusCode: 409, code: 'CONCERT_009');
    }
    _checkSession();
    if (!_deletedIds.add(concertId)) {
      throw const ApiException(statusCode: 404, code: 'CONCERT_001');
    }
  }

  @override
  Future<void> removeBand(int concertId, int bandId) async {
    final participants = await fetchParticipants(concertId);
    // 조회 중 권한이 바뀔 수 있으므로 마지막 await 뒤의 값으로 확정한다.
    final detail = await _details.fetchDetail(concertId);
    _checkAvailable(concertId);
    if (!ConcertAccess(detail).canManage) {
      throw const ApiException(statusCode: 403, code: 'AUTH_005');
    }
    final matching = participants.where((team) => team.bandId == bandId);
    if (matching.isEmpty) {
      throw const ApiException(statusCode: 404, code: 'CONCERT_007');
    }
    if (bandId == detail.hostBandId || matching.first.isHost) {
      throw const ApiException(statusCode: 409, code: 'CONCERT_008');
    }
    _checkSession();
    if (_deletedIds.contains(concertId)) {
      throw const ApiException(statusCode: 404, code: 'CONCERT_001');
    }
    if (!(_removedBandIds[concertId] ??= {}).add(bandId)) {
      throw const ApiException(statusCode: 404, code: 'CONCERT_007');
    }
  }
}
