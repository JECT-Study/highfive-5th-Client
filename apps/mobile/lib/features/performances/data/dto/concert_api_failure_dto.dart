/// 전송 계층이 보존하는 오류 응답. 의미와 사용자 행동은 Repository가 정한다.
class ConcertApiFailureDto implements Exception {
  const ConcertApiFailureDto({
    this.statusCode,
    this.code,
    this.fields = const {},
    this.definitelyUnsent = false,
  });

  final int? statusCode;
  final String? code;
  final Map<String, String> fields;
  final bool definitelyUnsent;
}
