import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../../../core/network/session_expiry.dart';
import '../../data/repositories/session_repository.dart';

/// 세션 저장소 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => getIt<SessionRepository>(),
);

/// 서버가 세션을 끝냈다는 알림 (`AuthInterceptor`가 보낸다). 테스트는 새 [SessionExpiry]로 바꿔 끼운다.
final sessionExpiryProvider = Provider<SessionExpiry>(
  (ref) => getIt<SessionExpiry>(),
);
