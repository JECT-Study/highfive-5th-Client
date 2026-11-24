import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/auth/data/dto/login_response_dto.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';
import 'package:highfive/features/auth/data/services/google_auth_service.dart';
import 'package:highfive/features/auth/data/services/kakao_auth_service.dart';
import 'package:highfive/features/auth/models/login_cancelled.dart';
import 'package:highfive/features/auth/models/login_failure.dart';
import 'package:highfive/features/auth/models/social_provider.dart';

/// 받은 제공자 값과 제공자 토큰을 기록한다. [error]가 있으면 그 오류를 던진다.
class _FakeAuthService extends AuthService {
  _FakeAuthService([this.error]) : super(Dio());

  final AppException? error;
  final calls = <(String, String)>[];

  @override
  Future<LoginResponseDto> login(
    String provider, {
    required String providerToken,
  }) async {
    calls.add((provider, providerToken));
    if (error case final error?) throw error;
    return const LoginResponseDto(
      accessToken: 'a',
      refreshToken: 'r',
      user: LoginUserDto(id: 1, status: 'ACTIVE'),
      nextStep: 'HOME',
    );
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

/// [token]을 돌려준다. null이면 사용자가 취소한 것과 같다.
class _FakeGoogleAuthService extends GoogleAuthService {
  _FakeGoogleAuthService([this.token = 'google-token'])
    : super(iosClientId: '', serverClientId: '');

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
      _FakeGoogleAuthService(),
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
        _FakeGoogleAuthService(),
      ).login(SocialProvider.kakao),
      throwsA(isA<LoginCancelled>()),
    );
    expect(service.calls, isEmpty);
  });

  test('Google로 로그인하면 Google ID 토큰을 서버에 보내고 카카오는 부르지 않는다', () async {
    final service = _FakeAuthService();
    final kakao = _FakeKakaoAuthService();
    final google = _FakeGoogleAuthService();

    await AuthRepository(service, kakao, google).login(SocialProvider.google);

    expect(google.calls, 1);
    expect(kakao.calls, 0);
    expect(service.calls, [('google', 'google-token')]);
  });

  test('Google 로그인을 취소하면 LoginCancelled를 던지고 서버에 보내지 않는다', () async {
    final service = _FakeAuthService();

    await expectLater(
      AuthRepository(
        service,
        _FakeKakaoAuthService(),
        _FakeGoogleAuthService(null),
      ).login(SocialProvider.google),
      throwsA(isA<LoginCancelled>()),
    );
    expect(service.calls, isEmpty);
  });

  test('Apple은 아직 SDK 없이 임시 로그인한다', () async {
    final service = _FakeAuthService();
    final kakao = _FakeKakaoAuthService();
    final google = _FakeGoogleAuthService();

    await AuthRepository(service, kakao, google).login(SocialProvider.apple);

    expect(kakao.calls, 0);
    expect(google.calls, 0);
    expect(service.calls, [('apple', '')]);
  });

  test('서버 오류는 이유별 LoginFailure로 바꾼다', () async {
    final cases = {
      const ApiException(statusCode: 401, code: 'AUTH_006'):
          LoginFailureReason.socialAuthFailed,
      const ApiException(statusCode: 403, code: 'USER_004'):
          LoginFailureReason.withdrawn,
      const NetworkException(): LoginFailureReason.network,
      const ApiException(statusCode: 400, code: 'AUTH_007'):
          LoginFailureReason.unknown,
      const ApiException(statusCode: 500): LoginFailureReason.unknown,
    };
    for (final MapEntry(key: error, value: reason) in cases.entries) {
      final repository = AuthRepository(
        _FakeAuthService(error),
        _FakeKakaoAuthService(),
        _FakeGoogleAuthService(),
      );

      await expectLater(
        repository.login(SocialProvider.kakao),
        throwsA(isA<LoginFailure>().having((f) => f.reason, 'reason', reason)),
        reason: '$error',
      );
    }
  });
}
