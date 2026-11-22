import '../../../../core/storage/secure_store.dart';
import '../../models/session.dart';

/// 세션을 secure storage에 저장·복원·삭제한다.
class SessionRepository {
  SessionRepository(this._store);

  final SecureStore _store;

  /// 저장된 세션. access token이 없으면 로그인 안 된 상태(null).
  Future<Session?> restore() async {
    final accessToken = await _store.read(SecureStore.accessTokenKey);
    if (accessToken == null || accessToken.isEmpty) return null;
    final refreshToken = await _store.read(SecureStore.refreshTokenKey);
    return Session(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> save(Session session) async {
    await _store.write(SecureStore.accessTokenKey, session.accessToken);
    final refreshToken = session.refreshToken;
    if (refreshToken == null) {
      await _store.delete(SecureStore.refreshTokenKey);
    } else {
      await _store.write(SecureStore.refreshTokenKey, refreshToken);
    }
  }

  Future<void> clear() async {
    await _store.delete(SecureStore.accessTokenKey);
    await _store.delete(SecureStore.refreshTokenKey);
  }
}
