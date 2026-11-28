import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../../auth/data/repositories/session_repository.dart';
import '../../data/repositories/concert_repository.dart';
import '../../data/services/concert_service.dart';
import '../../models/concert_draft.dart';

final concertSessionProvider = Provider<Object>((ref) {
  final session = getIt<SessionRepository>();
  final subscription = session.changes.listen((_) => ref.invalidateSelf());
  ref.onDispose(subscription.cancel);
  return session.identity;
});

final concertServiceProvider = Provider<ConcertService>(
  (ref) => getIt<ConcertService>(),
);

/// 잠금과 대기 요청은 로그인 수명 안에서만 공유한다.
/// 세션 변경 시 이전 Repository와 ViewModel이 분리되어 늦은 응답이 새 세션을 건드리지 않는다.
final concertRepositoryProvider = Provider<ConcertRepository>((ref) {
  ref.watch(concertSessionProvider);
  return ConcertRepository(ref.watch(concertServiceProvider));
});

final concertGenresProvider = FutureProvider.autoDispose<List<ConcertGenre>>(
  (ref) => ref.watch(concertRepositoryProvider).fetchGenres(),
  retry: (_, _) => null,
);

final concertTodayProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);
