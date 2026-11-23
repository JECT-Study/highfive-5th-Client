import '../../models/session.dart';
import '../../models/social_provider.dart';
import '../services/auth_service.dart';

/// 로그인해서 세션을 받는다. 저장은 `SessionRepository`가 한다.
class AuthRepository {
  AuthRepository(this._service);

  final AuthService _service;

  Future<Session> login(SocialProvider provider) async =>
      (await _service.login(provider.name)).toModel();
}
