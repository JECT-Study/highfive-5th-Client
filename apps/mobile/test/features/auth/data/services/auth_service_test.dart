import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';

/// 네트워크 대신 정해진 응답을 돌려주고 받은 요청을 기록한다.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Map<String, Object?> body;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

(AuthService, _FakeAdapter) _service(
  int statusCode,
  Map<String, Object?> body,
) {
  final adapter = _FakeAdapter(statusCode, body);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = adapter;
  return (AuthService(dio), adapter);
}

void main() {
  test('POST /api/v1/auth/login/{provider}에 token을 보내고 data를 읽는다', () async {
    final (service, adapter) = _service(200, {
      'status': 200,
      'code': 'COMMON_000',
      'message': '요청이 성공했습니다.',
      'data': {
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'user': {'id': 12, 'status': 'PENDING', 'nickname': null},
        'nextStep': 'TERMS',
      },
    });

    final response = await service.login('kakao', providerToken: 'kakao-token');

    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.path, '/api/v1/auth/login/kakao');
    expect(adapter.request?.data, {'token': 'kakao-token'});
    expect(response.accessToken, 'access');
    expect(response.refreshToken, 'refresh');
    expect(response.user.id, 12);
    expect(response.user.nickname, isNull);
    expect(response.nextStep, 'TERMS');
  });

  test('오류 응답이면 서버 오류 코드를 담은 ApiException을 던진다', () async {
    final (service, _) = _service(401, {
      'status': 401,
      'code': 'AUTH_006',
      'message': '소셜 로그인 인증에 실패했습니다.',
    });

    await expectLater(
      service.login('google', providerToken: 'bad'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.code, 'code', 'AUTH_006'),
      ),
    );
  });
}
