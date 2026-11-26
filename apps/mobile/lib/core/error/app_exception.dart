/// 서버 호출 오류. Service가 `DioException`을 이것으로 바꿔 던진다 (`api_error_mapper.dart`).
/// 화면은 종류(와 [ApiException.code])로 안내 문구를 고른다.
sealed class AppException implements Exception {
  const AppException();
}

/// 서버에 닿지 못했다 (연결 실패·시간 초과).
final class NetworkException extends AppException {
  const NetworkException();

  @override
  String toString() => 'NetworkException';
}

/// 서버가 오류 응답을 줬다. [code]는 서버 오류 코드 (예: `AUTH_006`). 본문이 없으면 null.
final class ApiException extends AppException {
  const ApiException({required this.statusCode, this.code, this.message});

  final int? statusCode;
  final String? code;
  final String? message;

  @override
  String toString() => 'ApiException($statusCode, $code: $message)';
}

/// 그 밖의 오류 (요청 취소, 응답 해석 실패 등).
final class UnknownApiException extends AppException {
  const UnknownApiException(this.cause);

  final Object cause;

  @override
  String toString() => 'UnknownApiException($cause)';
}
