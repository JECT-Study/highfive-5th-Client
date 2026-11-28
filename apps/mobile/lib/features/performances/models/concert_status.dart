import 'package:json_annotation/json_annotation.dart';

/// 공연 GET 초안의 상태. 서버 상태 전이와 티켓 상태는 별도 계약이다.
enum ConcertStatus {
  @JsonValue('BEFORE_RECRUIT')
  beforeRecruit,
  @JsonValue('RECRUITING')
  recruiting,
  @JsonValue('SELLING')
  selling,
  @JsonValue('SALE_PAUSED')
  salePaused,
  @JsonValue('SALE_CLOSED')
  saleClosed,

  /// 새 서버 코드를 기존 상태로 해석하지 않는다.
  unknown,
}
