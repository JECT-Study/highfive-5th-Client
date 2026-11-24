import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/dto/token_dto.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';
import 'package:highfive/features/auth/data/services/google_auth_service.dart';
import 'package:highfive/features/auth/data/services/kakao_auth_service.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/models/social_provider.dart';
import 'package:highfive/features/auth/presentation/providers/auth_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/login_view_model.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';

/// 응답 시점을 테스트가 정하고 받은 제공자를 기록한다.
class _FakeAuthService extends AuthService {
  final response = Completer<TokenDto>();
  final providers = <String>[];

  @override
  Future<TokenDto> login(String provider, {required String providerToken}) {
    providers.add(provider);
    return response.future;
  }
}

/// 카카오 SDK 대신 [token]을 돌려준다. null이면 사용자가 취소한 것과 같다.
class _FakeKakaoAuthService extends KakaoAuthService {
  _FakeKakaoAuthService([this.token = 'kakao-token']);

  final String? token;

  @override
  Future<String?> login() async => token;
}

/// Google SDK 대신 [token]을 돌려준다. null이면 사용자가 취소한 것과 같다.
class _FakeGoogleAuthService extends GoogleAuthService {
  _FakeGoogleAuthService([this.token = 'google-token'])
    : super(iosClientId: '', serverClientId: '');

  final String? token;

  @override
  Future<String?> login() async => token;
}

ProviderContainer _container(AuthService service, [KakaoAuthService? kakao]) {
  FlutterSecureStorage.setMockInitialValues({});
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        AuthRepository(
          service,
          kakao ?? _FakeKakaoAuthService(),
          _FakeGoogleAuthService(),
        ),
      ),
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
  test('로그인 중에는 누른 제공자가 pending이다', () async {
    final service = _FakeAuthService();
    final container = _container(service);

    final done = container
        .read(loginViewModelProvider.notifier)
        .login(SocialProvider.apple);

    expect(
      container.read(loginViewModelProvider).pending,
      SocialProvider.apple,
    );
    expect(service.providers, ['apple']);
    service.response.complete(const TokenDto(accessToken: 'a'));
    await done;
  });

  test('로그인하면 세션이 생기고 pending·failed가 풀린다', () async {
    final service = _FakeAuthService();
    final container = _container(service);
    await container.read(sessionProvider.future);

    final done = container
        .read(loginViewModelProvider.notifier)
        .login(SocialProvider.kakao);
    service.response.complete(const TokenDto(accessToken: 'a'));
    await done;

    expect(
      container.read(sessionProvider).value,
      const Session(accessToken: 'a'),
    );
    final state = container.read(loginViewModelProvider);
    expect(state.pending, isNull);
    expect(state.failed, isFalse);
  });

  test('로그인 중에 다시 누르면 다른 제공자여도 무시한다', () async {
    final service = _FakeAuthService();
    final container = _container(service);
    final notifier = container.read(loginViewModelProvider.notifier);

    final first = notifier.login(SocialProvider.kakao);
    await notifier.login(SocialProvider.kakao);
    await notifier.login(SocialProvider.google);
    service.response.complete(const TokenDto(accessToken: 'a'));
    await first;

    expect(service.providers, ['kakao']);
  });

  test('사용자가 취소하면 failed가 아니고 세션도 없다', () async {
    final service = _FakeAuthService();
    final container = _container(service, _FakeKakaoAuthService(null));
    await container.read(sessionProvider.future);

    await container
        .read(loginViewModelProvider.notifier)
        .login(SocialProvider.kakao);

    final state = container.read(loginViewModelProvider);
    expect(state.failed, isFalse);
    expect(state.pending, isNull);
    expect(service.providers, isEmpty);
    expect(container.read(sessionProvider).value, isNull);
  });

  test('로그인에 실패하면 failed가 되고 세션은 그대로 없다', () async {
    final service = _FakeAuthService();
    final container = _container(service);
    await container.read(sessionProvider.future);

    final done = container
        .read(loginViewModelProvider.notifier)
        .login(SocialProvider.google);
    service.response.completeError(Exception('network'));
    await done;

    final state = container.read(loginViewModelProvider);
    expect(state.failed, isTrue);
    expect(state.pending, isNull);
    expect(container.read(sessionProvider).value, isNull);
  });
}
