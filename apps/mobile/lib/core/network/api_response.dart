import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// 서버 성공 응답 공통 겉봉투 `{ status, code, message, data }`.
/// Service는 이것으로 풀고 [data](기능별 DTO)만 돌려준다.
///
/// 오류 응답(4xx·5xx)은 Dio가 예외로 던지므로 여기까지 오지 않는다.
/// 오류 본문은 `api_error_mapper.dart`가 `AppException`으로 바꾼다. 그래서 `errors`는 두지 않는다.
@JsonSerializable(createToJson: false, genericArgumentFactories: true)
class ApiResponse<T> {
  const ApiResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  /// [fromJsonT]는 `data` 안을 기능별 DTO로 바꾼다.
  /// 예: `ApiResponse.fromJson(json, (data) => TermsResponseDto.fromJson(data! as Map<String, dynamic>))`
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  /// HTTP 상태와 같은 값 (성공이면 200).
  final int status;

  /// 성공이면 `COMMON_000`.
  final String code;

  final String message;

  /// 기능별 DTO.
  final T data;
}
