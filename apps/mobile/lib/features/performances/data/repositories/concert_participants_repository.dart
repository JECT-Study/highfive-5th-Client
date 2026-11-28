import '../../models/concert_participant.dart';

/// 참여 밴드 조회 계약. 라인업 조회 초안의 `teams[]`에서 밴드 ID·이름·주최 여부만 쓴다.
abstract interface class ConcertParticipantsRepository {
  /// 공연 순서대로 돌려준다. 없으면 `ApiException(404, CONCERT_001)`,
  /// 참여 팀 멤버가 아니면 `ApiException(403, AUTH_005)`.
  Future<List<ConcertParticipant>> fetchParticipants(int concertId);
}
