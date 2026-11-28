/// 공연 생성이 실패한 이유. 화면은 이유마다 안내 문구와 다음 행동을 정한다.
enum ConcertCreationFailureReason {
  /// 기본 앱의 실서버 생성이 비활성이다.
  unavailable,

  /// 서버가 입력값을 거절했다 (COMMON_004·COMMON_001·CONCERT_010). 고쳐서 다시 보낼 수 있다.
  invalidInput,

  /// 공연 날짜가 서버 기준 오늘보다 이전이다 (CONCERT_002).
  pastDate,

  /// 주최 밴드의 대표자가 아니다 (AUTH_005). 안내한 뒤 이전 화면으로 돌아간다.
  forbidden,

  /// 서버에 닿지 못했다. 다시 보낼 수 있다.
  network,

  /// 그 밖의 이유로 서버가 거절했다 (4xx). 다시 보낼 수 있다.
  rejected,

  /// 서버가 받았는지 알 수 없다 (보낸 뒤 시간 초과·5xx·응답 해석 실패).
  /// 결과 조회·멱등성 키 계약이 없어 다시 보내면 같은 공연이 두 번 생길 수 있다.
  uncertain,
}

/// 공연 생성 실패. [cause]는 원래 오류(로그·디버그용).
class ConcertCreationFailure implements Exception {
  const ConcertCreationFailure(this.reason, [this.cause]);

  final ConcertCreationFailureReason reason;
  final Object? cause;

  @override
  String toString() => 'ConcertCreationFailure($reason, $cause)';
}
