import '../../../../core/error/app_exception.dart';

/// 공연 수정 PUT의 구조화된 실패. [error]는 HTTP 상태·코드 또는 전송 오류이고,
/// [fieldErrors]는 `COMMON_004` 본문의 `errors[]`(`{ "field": "title", "reason": "..." }`)를
/// 요청 필드 이름별로 모은 것이다. 공통 `ApiException`에는 `errors`가 없어 여기서 따로 읽는다.
class ConcertUpdateErrorDto implements Exception {
  const ConcertUpdateErrorDto(this.error, {this.fieldErrors = const {}});

  final AppException error;
  final Map<String, String> fieldErrors;

  /// 서버 오류 본문에서 `errors[]`를 읽는다. 모양이 다른 항목은 건너뛴다.
  static Map<String, String> fieldErrorsOf(Object? body) => {
    if (body case {'errors': final List<dynamic> errors})
      for (final entry in errors)
        if (entry case {
          'field': final String field,
          'reason': final String reason,
        })
          field: reason,
  };

  @override
  String toString() => 'ConcertUpdateErrorDto($error, $fieldErrors)';
}
