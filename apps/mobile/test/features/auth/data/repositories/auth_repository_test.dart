import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/auth/data/dto/token_dto.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';
import 'package:highfive/features/auth/data/services/kakao_auth_service.dart';
import 'package:highfive/features/auth/models/login_cancelled.dart';
import 'package:highfive/features/auth/models/social_provider.dart';

/// 받은 제공자 값과 제공자 토큰을 기록한다.
class _FakeAuthService extends AuthService {
  final calls = <(String, String)>[];

  @override
  Future<TokenDto> login(
    String provider, {
    required String providerToken,
  }) async {
    calls.add((provider, providerToken));
    return const TokenDto(accessToken: 'a', refreshToken: 'r');
  }
}

/// [token]을 돌려준다. null이면 사용자가 취소한 것과 같다.
class _FakeKakaoAuthService extends KakaoAuthService {
  _FakeKakaoAuthService([this.token = 'kakao-token']);

  final String? token;
  int calls = 0;

  @override
  Future<String?> login() async {
    calls++;
    return token;
  }
}

void main() {
  test('카카오로 로그인하면 카카오 토큰을 서버에 보내고 받은 토큰으로 세션을 만든다', () async {
    final service = _FakeAuthService();
    final kakao = _FakeKakaoAuthService();

    final session = await AuthRepository(
      service,
      kakao,
    ).login(SocialProvider.kakao);

    expect(kakao.calls, 1);
    expect(service.calls, [('kakao', 'kakao-token')]);
    expect(session.accessToken, 'a');
    expect(session.refreshToken, 'r');
  });

  test('카카오 로그인을 취소하면 LoginCancelled를 던지고 서버에 보내지 않는다', () async {
    final service = _FakeAuthService();

    await expectLater(
      AuthRepository(
        service,
        _FakeKakaoAuthService(null),
      ).login(SocialProvider.kakao),
      throwsA(isA<LoginCancelled>()),
    );
    expect(service.calls, isEmpty);
  });

  test('Apple·Google은 카카오 SDK를 부르지 않는다', () async {
    final service = _FakeAuthService();
    final kakao = _FakeKakaoAuthService();
    final repository = AuthRepository(service, kakao);

    await repository.login(SocialProvider.apple);
    await repository.login(SocialProvider.google);

    expect(kakao.calls, 0);
    expect(service.calls.map((call) => call.$1), ['apple', 'google']);
  });
}
