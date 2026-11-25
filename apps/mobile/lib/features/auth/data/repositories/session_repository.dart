import '../../../../core/storage/secure_store.dart';
import '../../models/next_step.dart';
import '../../models/session.dart';

/// 세션을 secure storage에 저장·복원·삭제한다.
///
/// `nextStep`도 같이 저장한다. 서버는 로그인·약관 동의 응답에서만 알려 주므로,
/// 약관 동의 전에 앱을 다시 켜도 약관 동의 시트로 돌아가게 하려면 앱이 기억해야 한다.
class SessionRepository {
  SessionRepository(this._store);

  final SecureStore _store;

  /// 저장된 세션. access token이 없으면 로그인 안 된 상태(null).
  /// 저장된 `nextStep`이 없거나 모르는 값이면 홈으로 본다.
  Future<Session?> restore() async {
    final accessToken = await _store.read(SecureStore.accessTokenKey);
    if (accessToken == null || accessToken.isEmpty) return null;
    final refreshToken = await _store.read(SecureStore.refreshTokenKey);
    final nextStep = await _store.read(SecureStore.nextStepKey);
    return Session(
      accessToken: accessToken,
      refreshToken: refreshToken,
      nextStep: NextStep.values.asNameMap()[nextStep] ?? NextStep.home,
    );
  }

  Future<void> save(Session session) async {
    await _store.write(SecureStore.accessTokenKey, session.accessToken);
    final refreshToken = session.refreshToken;
    if (refreshToken == null) {
      await _store.delete(SecureStore.refreshTokenKey);
    } else {
      await _store.write(SecureStore.refreshTokenKey, refreshToken);
    }
    await saveNextStep(session.nextStep);
  }

  /// `nextStep`만 바꾼다. 토큰은 건드리지 않아, 그 사이 로그아웃했어도 토큰이 되살아나지 않는다.
  Future<void> saveNextStep(NextStep nextStep) =>
      _store.write(SecureStore.nextStepKey, nextStep.name);

  Future<void> clear() async {
    await _store.delete(SecureStore.accessTokenKey);
    await _store.delete(SecureStore.refreshTokenKey);
    await _store.delete(SecureStore.nextStepKey);
  }
}
