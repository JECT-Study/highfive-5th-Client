import 'package:dio/dio.dart';

import '../error/app_exception.dart';

/// `DioException`을 [AppException]으로 바꾼다. 서버 오류 본문은
/// `{ "status": 401, "code": "AUTH_006", "message": "..." }` 모양이다.
AppException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badResponse:
      final body = error.response?.data;
      return ApiException(
        statusCode: error.response?.statusCode,
        code: body is Map ? body['code'] as String? : null,
        message: body is Map ? body['message'] as String? : null,
      );
    case DioExceptionType.badCertificate:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return UnknownApiException(error.type);
  }
}
