import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/dto/token_dto.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/providers/auth_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/login_view_model.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';

/// 응답 시점을 테스트가 정하고 호출 수를 센다.
class _FakeAuthService extends AuthService {
  final response = Completer<TokenDto>();
  int calls = 0;

  @override
  Future<TokenDto> login() {
    calls++;
    return response.future;
  }
}

ProviderContainer _container(AuthService service) {
  FlutterSecureStorage.setMockInitialValues({});
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(AuthRepository(service)),
      sessionRepositoryProvider.overrideWithValue(
        SessionRepository(SecureStore(const FlutterSecureStorage())),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.listen(loginViewModelProvider, (_, _) {});
  return container;
}

void main() {
  test('로그인하면 세션이 생긴다', () async {
    final service = _FakeAuthService();
    final container = _container(service);
    await container.read(sessionProvider.future);

    final done = container.read(loginViewModelProvider.notifier).login();
    service.response.complete(const TokenDto(accessToken: 'a'));
    await done;

    expect(
      container.read(sessionProvider).value,
      const Session(accessToken: 'a'),
    );
    expect(container.read(loginViewModelProvider).hasError, isFalse);
  });

  test('로그인 중에 다시 누르면 무시한다', () async {
    final service = _FakeAuthService();
    final container = _container(service);
    final notifier = container.read(loginViewModelProvider.notifier);

    final first = notifier.login();
    await notifier.login();
    service.response.complete(const TokenDto(accessToken: 'a'));
    await first;

    expect(service.calls, 1);
  });

  test('로그인에 실패하면 오류 상태가 되고 세션은 그대로 없다', () async {
    final service = _FakeAuthService();
    final container = _container(service);
    await container.read(sessionProvider.future);

    final done = container.read(loginViewModelProvider.notifier).login();
    service.response.completeError(Exception('network'));
    await done;

    expect(container.read(loginViewModelProvider).hasError, isTrue);
    expect(container.read(sessionProvider).value, isNull);
  });
}
