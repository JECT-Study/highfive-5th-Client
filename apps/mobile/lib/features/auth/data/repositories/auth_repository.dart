import '../../models/login_cancelled.dart';
import '../../models/session.dart';
import '../../models/social_provider.dart';
import '../services/auth_service.dart';
import '../services/kakao_auth_service.dart';

/// 로그인해서 세션을 받는다. 저장은 `SessionRepository`가 한다.
///
/// 제공자 SDK로 로그인해 받은 토큰을 서버에 보내 우리 세션으로 바꾼다.
/// 사용자가 SDK 화면에서 취소하면 [LoginCancelled]를 던진다.
class AuthRepository {
  AuthRepository(this._service, this._kakao);

  final AuthService _service;
  final KakaoAuthService _kakao;

  Future<Session> login(SocialProvider provider) async {
    final providerToken = switch (provider) {
      SocialProvider.kakao => await _kakao.login(),
      // SDK 연동 전이라 토큰 없이 임시 로그인한다.
      SocialProvider.apple || SocialProvider.google => '',
    };
    if (providerToken == null) throw const LoginCancelled();
    final token = await _service.login(
      provider.name,
      providerToken: providerToken,
    );
    return token.toModel();
  }
}
