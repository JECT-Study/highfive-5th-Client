import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/models/session.dart';

SessionRepository _repo([Map<String, String> stored = const {}]) {
  FlutterSecureStorage.setMockInitialValues(Map.of(stored));
  return SessionRepository(SecureStore(const FlutterSecureStorage()));
}

void main() {
  test('저장된 토큰이 없으면 복원 결과는 null이다', () async {
    expect(await _repo().restore(), isNull);
  });

  test('저장한 세션을 그대로 복원한다', () async {
    final repo = _repo();
    const session = Session(accessToken: 'a', refreshToken: 'r');

    await repo.save(session);

    expect(await repo.restore(), session);
  });

  test('refresh token 없이 저장하면 이전 refresh token을 지운다', () async {
    final repo = _repo({
      SecureStore.accessTokenKey: 'old-a',
      SecureStore.refreshTokenKey: 'old-r',
    });

    await repo.save(const Session(accessToken: 'new-a'));

    expect(await repo.restore(), const Session(accessToken: 'new-a'));
  });

  test('지우면 다음 복원은 null이다', () async {
    final repo = _repo({
      SecureStore.accessTokenKey: 'a',
      SecureStore.refreshTokenKey: 'r',
    });

    await repo.clear();

    expect(await repo.restore(), isNull);
  });

  test('nextStep도 저장하고 복원한다. 저장된 값이 없으면 홈이다', () async {
    final repo = _repo();

    await repo.save(const Session(accessToken: 'a', nextStep: NextStep.terms));
    expect((await repo.restore())!.nextStep, NextStep.terms);

    await repo.saveNextStep(NextStep.profile);
    expect((await repo.restore())!.nextStep, NextStep.profile);

    expect(
      (await _repo({SecureStore.accessTokenKey: 'a'}).restore())!.nextStep,
      NextStep.home,
    );
  });

  test('지우면 nextStep도 지운다', () async {
    final repo = _repo();
    await repo.save(const Session(accessToken: 'a', nextStep: NextStep.terms));

    await repo.clear();

    expect(
      await const FlutterSecureStorage().read(key: SecureStore.nextStepKey),
      isNull,
    );
  });
}
