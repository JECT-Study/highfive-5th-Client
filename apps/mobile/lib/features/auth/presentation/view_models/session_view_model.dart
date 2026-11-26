import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/next_step.dart';
import '../../models/session.dart';
import '../providers/auth_providers.dart';
import '../providers/session_providers.dart';

/// 로그인 세션 (앱 공통, keepAlive). 값이 null이면 로그인 안 된 상태.
///
/// 앱 시작 시 저장된 세션을 복원하고, 로그인·로그아웃 때 저장소와 같이 바꾼다.
/// 서버가 세션을 끝내면(토큰 재발급 실패, 다른 기기 로그인 등) 로그아웃한다.
/// 라우터가 이 값으로 로그인·홈 화면을 고른다(`app/router.dart`).
final sessionProvider = AsyncNotifierProvider<SessionViewModel, Session?>(
  SessionViewModel.new,
);

class SessionViewModel extends AsyncNotifier<Session?> {
  /// 로그아웃 중이면 다시 눌러도 서버에 한 번만 보낸다.
  bool _loggingOut = false;

  @override
  Future<Session?> build() {
    final subscription = ref
        .read(sessionExpiryProvider)
        .stream
        .listen((_) => signOut());
    ref.onDispose(subscription.cancel);
    return ref.read(sessionRepositoryProvider).restore();
  }

  /// 로그인 성공 후 받은 세션을 저장한다.
  Future<void> signIn(Session session) async {
    await ref.read(sessionRepositoryProvider).save(session);
    state = AsyncData(session);
  }

  /// 온보딩 한 단계를 마쳤다 (예: 약관 동의 저장). 서버가 준 다음 단계로 바꾸고 저장한다.
  /// 그 사이 로그아웃했으면 늦게 온 결과는 버린다.
  Future<void> updateNextStep(NextStep nextStep) async {
    final session = state.value;
    if (session == null) return;
    await ref.read(sessionRepositoryProvider).saveNextStep(nextStep);
    if (state.value?.accessToken != session.accessToken) return;
    state = AsyncData(session.copyWith(nextStep: nextStep));
  }

  /// 사용자가 로그아웃을 눌렀다. 서버의 리프레시 토큰을 지우고, 서버 호출이 실패해도
  /// 저장된 세션은 지운다 (명세: 앱은 응답과 상관없이 저장된 토큰을 지운다).
  Future<void> logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      await ref.read(authRepositoryProvider).logout();
    } on Exception catch (error) {
      if (kDebugMode) debugPrint('[Session] 서버 로그아웃 실패, 저장된 토큰만 지운다: $error');
    } finally {
      _loggingOut = false;
    }
    await signOut();
  }

  /// 저장된 세션을 지우고 로그인 안 된 상태로 바꾼다. 서버에는 알리지 않는다.
  /// 서버가 세션을 끝냈을 때(`SessionExpiry`)도 이것을 부른다.
  /// 기능별 캐시·소켓 정리는 그 기능이 생길 때 여기서 같이 부른다 (mobile-architecture 4절).
  Future<void> signOut() async {
    await ref.read(sessionRepositoryProvider).clear();
    state = const AsyncData(null);
  }
}
