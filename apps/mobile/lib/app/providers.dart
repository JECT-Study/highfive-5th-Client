import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/locator.dart';
import '../features/auth/presentation/view_models/session_view_model.dart';
import '../features/performances/data/repositories/concert_management_repository.dart';
import 'env.dart';

/// 앱 전역에서 쓰는 연결 Provider. 기능별 연결 Provider는
/// `features/<feature>/presentation/providers/`에 둔다.
///
/// View·ViewModel은 getIt 대신 연결 Provider를 watch/read 한다.
/// 테스트는 `ProviderScope(overrides: [...])`로 바꿔 끼우고 전역 getIt 등록에 기대지 않는다.
final appEnvProvider = Provider<AppEnv>((ref) => getIt<AppEnv>());

/// 인증 기능을 수정하지 않고 기존 세션 수명을 구독한다. 토큰은 저장·로그하지 않는다.
final sessionConcertRepositoryProvider = Provider<ConcertManagementRepository>((
  ref,
) {
  ref.watch(sessionProvider.select((state) => state.value?.accessToken));
  final repository = getIt<ConcertManagementRepository>();
  ref.listen(sessionProvider.select((state) => state.value?.accessToken), (
    previous,
    next,
  ) {
    if (previous != next) repository.endSession();
  });
  ref.onDispose(repository.endSession);
  return repository;
});
