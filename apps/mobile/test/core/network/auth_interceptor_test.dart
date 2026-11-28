import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/network/auth_interceptor.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/storage/secure_store.dart';

/// 재발급 API가 어떻게 답할지.
enum _Refresh { ok, expired, offline }

/// 네트워크 대신 서버처럼 답한다.
/// - `GET /me`: `new-access`면 200, 아니면 [meError] 코드로 401.
/// - `POST /api/v1/auth/refresh`: [refresh]대로 답하고 호출 수를 센다.
class _FakeServer implements HttpClientAdapter {
  _FakeServer({this.refresh = _Refresh.ok, this.meError = 'AUTH_002'});

  final _Refresh refresh;
  final String meError;
  int refreshCalls = 0;
  final refreshStarted = Completer<void>();
  Completer<void>? refreshRelease;
  final meTokens = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == AuthInterceptor.refreshPath) {
      refreshCalls++;
      if (!refreshStarted.isCompleted) refreshStarted.complete();
      await refreshRelease?.future;
      return switch (refresh) {
        _Refresh.ok => _json(200, {
          'code': 'COMMON_000',
          'data': {'accessToken': 'new-access', 'refreshToken': 'new-refresh'},
        }),
        _Refresh.expired => _json(401, {'code': 'AUTH_004'}),
        _Refresh.offline => throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ),
      };
    }
    final token = options.headers['Authorization'] as String?;
    meTokens.add(token);
    return token == 'Bearer new-access'
        ? _json(200, {'code': 'COMMON_000', 'data': 'me'})
        : _json(401, {'code': meError});
  }

  static ResponseBody _json(int status, Map<String, Object?> body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

/// 앱과 같은 구성: 인터셉터가 붙은 Dio + 재발급·재시도용 Dio (같은 가짜 서버).
({Dio dio, SecureStore store, List<String> expired}) _setUp(
  _FakeServer server, {
  Map<String, String> stored = const {
    SecureStore.accessTokenKey: 'old-access',
    SecureStore.refreshTokenKey: 'old-refresh',
  },
}) {
  FlutterSecureStorage.setMockInitialValues(Map.of(stored));
  final store = SecureStore(const FlutterSecureStorage());
  final expiry = SessionExpiry();
  final expired = <String>[];
  final subscription = expiry.stream.listen(expired.add);
  addTearDown(subscription.cancel);

  Dio newDio() =>
      Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = server;
  final dio = newDio()
    ..interceptors.add(
      AuthInterceptor(store: store, plainDio: newDio(), expiry: expiry),
    );
  return (dio: dio, store: store, expired: expired);
}

void main() {
  test('재전송을 끈 POST도 확정 만료 시 토큰만 갱신하고 다음 수동 요청은 성공한다', () async {
    final server = _FakeServer();
    final (:dio, :store, :expired) = _setUp(server);
    final options = Options(extra: {AuthInterceptor.allowReplayKey: false});

    await expectLater(
      dio.post<Object?>('/concerts', options: options),
      throwsA(isA<DioException>()),
    );

    expect(server.refreshCalls, 1);
    expect(server.meTokens, ['Bearer old-access']);
    expect(await store.read(SecureStore.accessTokenKey), 'new-access');
    final response = await dio.post<Map<String, dynamic>>(
      '/concerts',
      options: options,
    );
    expect(response.data?['data'], 'me');
    expect(server.meTokens, ['Bearer old-access', 'Bearer new-access']);
    expect(expired, isEmpty);
  });

  test('재전송을 끈 요청도 재발급이 최종 거절되면 세션 만료를 알린다', () async {
    final server = _FakeServer(refresh: _Refresh.expired);
    final (:dio, store: _, :expired) = _setUp(server);

    await expectLater(
      dio.post<Object?>(
        '/concerts',
        options: Options(extra: {AuthInterceptor.allowReplayKey: false}),
      ),
      throwsA(isA<DioException>()),
    );

    expect(server.meTokens, ['Bearer old-access']);
    expect(expired, ['AUTH_004']);
  });

  test('재발급을 기다리는 동안 계정이 바뀌면 새 계정 토큰을 덮거나 POST를 재전송하지 않는다', () async {
    for (final refresh in [_Refresh.ok, _Refresh.expired]) {
      final server = _FakeServer(refresh: refresh)
        ..refreshRelease = Completer<void>();
      final (:dio, :store, :expired) = _setUp(server);
      final result = expectLater(
        dio.post<Object?>(
          '/concerts',
          options: Options(extra: {AuthInterceptor.allowReplayKey: false}),
        ),
        throwsA(isA<DioException>()),
      );
      await server.refreshStarted.future;
      await store.write(SecureStore.refreshTokenKey, 'other-refresh');
      await store.write(SecureStore.accessTokenKey, 'other-access');
      server.refreshRelease!.complete();
      await result;

      expect(await store.read(SecureStore.accessTokenKey), 'other-access');
      expect(await store.read(SecureStore.refreshTokenKey), 'other-refresh');
      expect(server.meTokens, ['Bearer old-access']);
      expect(expired, isEmpty);
    }
  });

  test('저장된 액세스 토큰을 Bearer 헤더로 붙인다', () async {
    final server = _FakeServer();
    final (:dio, store: _, expired: _) = _setUp(
      server,
      stored: {SecureStore.accessTokenKey: 'new-access'},
    );

    await dio.get<Object?>('/me');

    expect(server.meTokens, ['Bearer new-access']);
  });

  test('AUTH_002면 한 번 재발급하고 두 토큰을 저장한 뒤 새 토큰으로 다시 보낸다', () async {
    final server = _FakeServer();
    final (:dio, :store, :expired) = _setUp(server);

    final response = await dio.get<Map<String, dynamic>>('/me');

    expect(response.data?['data'], 'me');
    expect(server.refreshCalls, 1);
    expect(server.meTokens, ['Bearer old-access', 'Bearer new-access']);
    expect(await store.read(SecureStore.accessTokenKey), 'new-access');
    expect(await store.read(SecureStore.refreshTokenKey), 'new-refresh');
    expect(expired, isEmpty);
  });

  test('여러 요청이 동시에 AUTH_002를 받아도 재발급은 한 번이다', () async {
    final server = _FakeServer();
    final (:dio, store: _, :expired) = _setUp(server);

    final responses = await Future.wait([
      for (var i = 0; i < 3; i++) dio.get<Map<String, dynamic>>('/me'),
    ]);

    expect(responses.map((r) => r.data?['data']), ['me', 'me', 'me']);
    expect(server.refreshCalls, 1);
    expect(expired, isEmpty);
  });

  test('재발급이 AUTH_004면 세션 만료를 알리고 요청은 실패한다', () async {
    final server = _FakeServer(refresh: _Refresh.expired);
    final (:dio, store: _, :expired) = _setUp(server);

    await expectLater(dio.get<Object?>('/me'), throwsA(isA<DioException>()));

    expect(server.refreshCalls, 1);
    expect(expired, ['AUTH_004']);
  });

  test('저장된 리프레시 토큰이 없으면 재발급하지 않고 세션 만료를 알린다', () async {
    final server = _FakeServer();
    final (:dio, store: _, :expired) = _setUp(
      server,
      stored: {SecureStore.accessTokenKey: 'old-access'},
    );

    await expectLater(dio.get<Object?>('/me'), throwsA(isA<DioException>()));

    expect(server.refreshCalls, 0);
    expect(expired, ['AUTH_004']);
  });

  test('AUTH_001·AUTH_003이면 재발급하지 않고 바로 세션 만료를 알린다', () async {
    for (final code in ['AUTH_001', 'AUTH_003']) {
      final server = _FakeServer(meError: code);
      final (:dio, store: _, :expired) = _setUp(server);

      await expectLater(dio.get<Object?>('/me'), throwsA(isA<DioException>()));

      expect(server.refreshCalls, 0, reason: code);
      expect(expired, [code], reason: code);
    }
  });

  test('재발급이 네트워크 오류로 실패하면 로그아웃하지 않고 토큰도 그대로다', () async {
    final server = _FakeServer(refresh: _Refresh.offline);
    final (:dio, :store, :expired) = _setUp(server);

    await expectLater(dio.get<Object?>('/me'), throwsA(isA<DioException>()));

    expect(expired, isEmpty);
    expect(await store.read(SecureStore.refreshTokenKey), 'old-refresh');
  });

  test('토큰과 관계없는 오류는 재발급하지 않고 그대로 돌려준다', () async {
    final server = _FakeServer(meError: 'AUTH_006');
    final (:dio, store: _, :expired) = _setUp(server);

    await expectLater(
      dio.get<Object?>('/me'),
      throwsA(
        isA<DioException>().having(
          (e) => (e.response?.data as Map)['code'],
          'code',
          'AUTH_006',
        ),
      ),
    );
    expect(server.refreshCalls, 0);
    expect(expired, isEmpty);
  });
}
