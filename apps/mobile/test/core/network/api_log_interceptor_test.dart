import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/network/api_log_interceptor.dart';

/// 네트워크 대신 정해진 응답을 돌려준다.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Map<String, Object?> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

Future<List<String>> _logsOf(int statusCode, Map<String, Object?> body) async {
  final logs = <String>[];
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = _FakeAdapter(statusCode, body)
    ..interceptors.add(ApiLogInterceptor(log: logs.add));
  try {
    await dio.post<Object?>('/login', data: {'token': 'social-secret'});
  } on DioException {
    // 오류 응답도 로그만 본다.
  }
  return logs;
}

void main() {
  test('요청·응답을 찍되 토큰 값은 가리고 나머지는 그대로 둔다', () async {
    final logs = await _logsOf(200, {
      'code': 'COMMON_000',
      'data': {
        'accessToken': 'access-secret',
        'refreshToken': 'refresh-secret',
        'user': {'id': 12, 'nickname': null},
        'nextStep': 'TERMS',
      },
    });
    final all = logs.join('\n');

    expect(all, isNot(contains('social-secret')));
    expect(all, isNot(contains('access-secret')));
    expect(all, isNot(contains('refresh-secret')));
    expect(all, contains('/login'));
    expect(all, contains('200'));
    expect(all, contains('TERMS'));
    expect(all, contains('12'));
  });

  test('오류 응답은 상태 코드와 서버 오류 코드를 찍는다', () async {
    final logs = await _logsOf(401, {'code': 'AUTH_006', 'message': '실패'});
    final all = logs.join('\n');

    expect(all, contains('401'));
    expect(all, contains('AUTH_006'));
    expect(all, isNot(contains('social-secret')));
  });
}
