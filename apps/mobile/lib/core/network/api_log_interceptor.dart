import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 디버그 빌드에서 요청·응답을 찍는다. 토큰 값은 `***`로 가린다.
/// 헤더는 찍지 않는다 (`Authorization`에 토큰이 들어간다).
class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor({void Function(String message)? log})
    : _log = log ?? debugPrint;

  final void Function(String message) _log;

  /// 개인정보가 포함된 폼은 요청·응답 본문을 기록하지 않는다.
  static const logBodyKey = 'api.logBody';

  static Object? _body(RequestOptions options, Object? data) =>
      options.extra[logBodyKey] == false ? '' : _mask(data);

  /// 값을 가리는 키. 요청 본문의 소셜 토큰(`token`)과 응답의 서비스 토큰이다.
  static const _secretKeys = {
    'token',
    'accessToken',
    'refreshToken',
    'idToken',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log(
      '[API] → ${options.method} ${options.path} '
      '${_body(options, options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    _log(
      '[API] ← ${response.statusCode} ${options.method} ${options.path}\n'
      '${_body(options, response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final response = err.response;
    _log(
      response == null
          ? '[API] ✕ ${options.method} ${options.path} ${err.type.name}'
          : '[API] ✕ ${response.statusCode} ${options.method} ${options.path}\n'
                '${_body(options, response.data)}',
    );
    handler.next(err);
  }

  /// [_secretKeys]의 값을 가린 사본. 중첩된 Map·List도 따라 들어간다.
  static Object? _mask(Object? data) => switch (data) {
    Map() => {
      for (final MapEntry(:key, :value) in data.entries)
        key: _secretKeys.contains(key) && value != null ? '***' : _mask(value),
    },
    List() => [for (final item in data) _mask(item)],
    _ => data,
  };
}
