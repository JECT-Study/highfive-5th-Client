import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/locator.dart';
import 'env.dart';

/// 앱 전역에서 쓰는 연결 Provider. 기능별 연결 Provider는
/// `features/<feature>/presentation/providers/`에 둔다.
///
/// View·ViewModel은 getIt 대신 연결 Provider를 watch/read 한다.
/// 테스트는 `ProviderScope(overrides: [...])`로 바꿔 끼우고 전역 getIt 등록에 기대지 않는다.
final appEnvProvider = Provider<AppEnv>((ref) => getIt<AppEnv>());
