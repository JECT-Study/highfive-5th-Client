import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';

ProviderContainer _container([
  Map<String, String> stored = const {},
  SessionExpiry? expiry,
]) {
  FlutterSecureStorage.setMockInitialValues(Map.of(stored));
  final container = ProviderContainer(
    overrides: [
      sessionExpiryProvider.overrideWithValue(expiry ?? SessionExpiry()),
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
}
