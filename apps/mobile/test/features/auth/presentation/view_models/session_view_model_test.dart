import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';
import 'package:highfive/features/auth/data/services/google_auth_service.dart';
import 'package:highfive/features/auth/data/services/kakao_auth_service.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/providers/auth_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';

/// 서버 로그아웃 호출 수를 센다. [error]가 있으면 그 오류로 실패한다.
/// [response]를 주면 그 Future가 끝날 때까지 응답을 미룬다.
class _FakeAuthService extends AuthService {
  _FakeAuthService({this.error, this.response}) : super(Dio());

  final AppException? error;
  final Future<void>? response;
  int logoutCalls = 0;

  @override
  Future<void> logout() async {
    logoutCalls++;
    await response;
    if (error case final error?) throw error;
  }
}

ProviderContainer _container([
  Map<String, String> stored = const {},
  SessionExpiry? expiry,
  AuthService? authService,
]) {
  FlutterSecureStorage.setMockInitialValues(Map.of(stored));
  final container = ProviderContainer(
    overrides: [
      sessionExpiryProvider.overrideWithValue(expiry ?? SessionExpiry()),
      authRepositoryProvider.overrideWithValue(
        AuthRepository(
          authService ?? _FakeAuthService(),
          KakaoAuthService(),
          GoogleAuthService(iosClientId: '', serverClientId: ''),
        ),
      ),
      sessionRepositoryProvider.overrideWithValue(
        SessionRepository(SecureStore(const FlutterSecureStorage())),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('시작할 때 저장된 세션을 복원한다', () async {
    final container = _container({SecureStore.accessTokenKey: 'a'});

    expect(
      await container.read(sessionProvider.future),
      const Session(accessToken: 'a'),
    );
  });

  test('저장된 세션이 없으면 로그인 안 된 상태(null)다', () async {
    final container = _container();

    expect(await container.read(sessionProvider.future), isNull);
  });

  test('로그인하면 상태가 바뀌고 저장소에도 남는다', () async {
    final container = _container();
    await container.read(sessionProvider.future);
    const session = Session(accessToken: 'a', refreshToken: 'r');

    await container.read(sessionProvider.notifier).signIn(session);

    expect(container.read(sessionProvider).value, session);
    expect(await container.read(sessionRepositoryProvider).restore(), session);
  });

  test('로그아웃하면 상태가 null이 되고 저장소에서도 지워진다', () async {
    final container = _container({SecureStore.accessTokenKey: 'a'});
    await container.read(sessionProvider.future);

    await container.read(sessionProvider.notifier).signOut();

    expect(container.read(sessionProvider).value, isNull);
    expect(await container.read(sessionRepositoryProvider).restore(), isNull);
  });

  test('서버가 세션을 끝냈다고 알리면 로그아웃하고 저장소에서도 지운다', () async {
    final expiry = SessionExpiry();
    final container = _container({
      SecureStore.accessTokenKey: 'a',
      SecureStore.refreshTokenKey: 'r',
    }, expiry);
    await container.read(sessionProvider.future);
    final signedOut = Completer<void>();
    container.listen(sessionProvider, (_, next) {
      if (next.hasValue && next.value == null && !signedOut.isCompleted) {
        signedOut.complete();
      }
    });

    expiry.notify('AUTH_004');
    await signedOut.future;

    expect(await container.read(sessionRepositoryProvider).restore(), isNull);
  });

  test('로그아웃을 누르면 서버에 알리고 저장된 세션을 지운다', () async {
    final service = _FakeAuthService();
    final container = _container(
      {SecureStore.accessTokenKey: 'a', SecureStore.refreshTokenKey: 'r'},
      null,
      service,
    );
    await container.read(sessionProvider.future);

    await container.read(sessionProvider.notifier).logout();

    expect(service.logoutCalls, 1);
    expect(container.read(sessionProvider).value, isNull);
    expect(await container.read(sessionRepositoryProvider).restore(), isNull);
  });

  test('서버 로그아웃이 실패해도 저장된 세션은 지운다', () async {
    final service = _FakeAuthService(
      error: const ApiException(statusCode: 401, code: 'AUTH_001'),
    );
    final container = _container(
      {SecureStore.accessTokenKey: 'a'},
      null,
      service,
    );
    await container.read(sessionProvider.future);

    await container.read(sessionProvider.notifier).logout();

    expect(container.read(sessionProvider).value, isNull);
    expect(await container.read(sessionRepositoryProvider).restore(), isNull);
  });

  test('로그아웃 중에 다시 눌러도 서버에는 한 번만 보낸다', () async {
    final response = Completer<void>();
    final service = _FakeAuthService(response: response.future);
    final container = _container(
      {SecureStore.accessTokenKey: 'a'},
      null,
      service,
    );
    await container.read(sessionProvider.future);
    final notifier = container.read(sessionProvider.notifier);

    final first = notifier.logout();
    await notifier.logout();
    response.complete();
    await first;

    expect(service.logoutCalls, 1);
  });
}
