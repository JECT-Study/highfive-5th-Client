import 'package:dio/dio.dart';

import '../storage/secure_store.dart';
import 'session_expiry.dart';

/// 요청에 액세스 토큰을 붙이고, 만료(`AUTH_002`)면 한 번 재발급한 뒤 원래 요청을 다시 보낸다.
///
/// - [QueuedInterceptor]라 여러 요청이 동시에 `AUTH_002`를 받아도 재발급은 한 번만 나간다.
///   뒤 요청은 저장된 토큰이 이미 바뀐 것을 보고 재발급 없이 새 토큰으로 다시 보낸다.
/// - 재발급이 `AUTH_004`(만료·이미 쓴 토큰·다른 기기 로그인)이거나 요청이 `AUTH_001`·`AUTH_003`이면
///   [SessionExpiry]로 알린다. 토큰 삭제와 로그인 화면 이동은 세션 ViewModel이 한다.
/// - 재발급이 네트워크 등으로 실패하면 로그아웃하지 않고 원래 오류를 돌려준다.
/// - 재발급·재시도는 이 인터셉터가 없는 [_plainDio]로 보낸다 (같은 Dio로 보내면 큐가 막힌다).
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this._store,
    required this._plainDio,
    required this._expiry,
  });

  final SecureStore _store;
  final Dio _plainDio;
  final SessionExpiry _expiry;

  static const refreshPath = '/api/v1/auth/refresh';

  /// 멱등성·결과 확인 계약이 없는 쓰기 요청은 false로 지정한다.
  static const allowReplayKey = 'auth.allowReplay';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _store.read(SecureStore.accessTokenKey);
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    switch (_codeOf(err.response)) {
      case 'AUTH_001' || 'AUTH_003':
        if (_bearerOf(err.requestOptions) ==
            await _store.read(SecureStore.accessTokenKey)) {
          _expiry.notify(_codeOf(err.response)!);
        }
        return handler.next(err);
      case 'AUTH_002':
        break;
      default:
        return handler.next(err);
    }

    final sentToken = _bearerOf(err.requestOptions);
    var accessToken = await _store.read(SecureStore.accessTokenKey);
    // 앞 요청이 이미 재발급했으면 저장된 토큰이 보낸 토큰과 다르다. 그 토큰으로 다시 보낸다.
    if (accessToken == null || accessToken == sentToken) {
      accessToken = await _refresh();
      if (accessToken == null) return handler.next(err);
    }

    // AUTH_002는 확정 거절이다. 토큰만 갱신하고 사용자의 다음 제출을 기다린다.
    if (err.requestOptions.extra[allowReplayKey] == false) {
      return handler.next(err);
    }
    final options = err.requestOptions;
    options.headers['Authorization'] = 'Bearer $accessToken';
    try {
      handler.resolve(await _plainDio.fetch<Object?>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// 새 액세스 토큰. 재발급하지 못하면 null.
  Future<String?> _refresh() async {
    final refreshToken = await _store.read(SecureStore.refreshTokenKey);
    if (refreshToken == null) {
      _expiry.notify('AUTH_004');
      return null;
    }
    try {
      final response = await _plainDio.post<Map<String, dynamic>>(
        refreshPath,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      // 갱신 중 로그아웃·다른 계정 로그인으로 바뀐 세션을 덮어쓰지 않는다.
      if (await _store.read(SecureStore.refreshTokenKey) != refreshToken) {
        return null;
      }
      // 재발급하면 리프레시 토큰도 바뀐다. 쓴 값은 다시 못 쓰므로 새 값으로 바꿔 둔다.
      await _store.write(
        SecureStore.refreshTokenKey,
        data['refreshToken'] as String,
      );
      await _store.write(SecureStore.accessTokenKey, accessToken);
      return accessToken;
    } on DioException catch (error) {
      if (_codeOf(error.response) == 'AUTH_004' &&
          await _store.read(SecureStore.refreshTokenKey) == refreshToken) {
        _expiry.notify('AUTH_004');
      }
      return null;
    }
  }

  static String? _codeOf(Response<Object?>? response) =>
      switch (response?.data) {
        {'code': final String code} => code,
        _ => null,
      };

  static String? _bearerOf(RequestOptions options) =>
      switch (options.headers['Authorization']) {
        final String header when header.startsWith('Bearer ') =>
          header.substring(7),
        _ => null,
      };
}
