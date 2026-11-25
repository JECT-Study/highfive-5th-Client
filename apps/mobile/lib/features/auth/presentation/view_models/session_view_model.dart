import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session.dart';
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

  /// 저장된 세션을 지우고 로그인 안 된 상태로 바꾼다.
  /// 기능별 캐시·소켓 정리는 그 기능이 생길 때 여기서 같이 부른다 (mobile-architecture 4절).
  Future<void> signOut() async {
    await ref.read(sessionRepositoryProvider).clear();
    state = const AsyncData(null);
  }
}
