import '../../models/concert_detail.dart';

/// 상세 조회만의 계약. 생성·수정·티켓·라인업 API는 포함하지 않는다.
abstract interface class ConcertRepository {
  /// 없으면 `ApiException(404, CONCERT_001)`,
  /// 참여 팀 멤버가 아니면 `ApiException(403, AUTH_005)`.
  Future<ConcertDetail> fetchDetail(int concertId);
}
