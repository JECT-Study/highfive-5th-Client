import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/core/network/api_error_mapper.dart';

DioException _error(DioExceptionType type, {Response<Object?>? response}) =>
    DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: type,
      response: response,
    );

void main() {
  test('연결 실패·시간 초과는 NetworkException이다', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ]) {
      expect(mapDioException(_error(type)), isA<NetworkException>());
    }
  });

  test('오류 응답은 상태 코드와 서버 오류 코드를 담은 ApiException이다', () {
    final error = _error(
      DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 401,
        data: {'status': 401, 'code': 'AUTH_006', 'message': '실패'},
      ),
    );

    expect(
      mapDioException(error),
      isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 401)
          .having((e) => e.code, 'code', 'AUTH_006'),
    );
  });

  test('오류 응답 본문이 JSON이 아니면 code 없이 상태 코드만 담는다', () {
    final error = _error(
      DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 502,
        data: '<html>Bad Gateway</html>',
      ),
    );

    expect(
      mapDioException(error),
      isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 502)
          .having((e) => e.code, 'code', isNull),
    );
  });

  test('그 밖의 오류는 UnknownApiException이다', () {
    expect(
      mapDioException(_error(DioExceptionType.unknown)),
      isA<UnknownApiException>(),
    );
  });
}
