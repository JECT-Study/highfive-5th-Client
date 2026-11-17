import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../data/repositories/auth_repository.dart';

/// 로그인 저장소 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => getIt<AuthRepository>(),
);
