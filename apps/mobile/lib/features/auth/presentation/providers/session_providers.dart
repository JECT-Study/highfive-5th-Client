import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../data/repositories/session_repository.dart';

/// 세션 저장소 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => getIt<SessionRepository>(),
);
