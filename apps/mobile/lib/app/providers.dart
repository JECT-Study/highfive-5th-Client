import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di.dart';
import 'env.dart';

/// get_it에 등록한 앱 공통 객체를 Riverpod으로 넘기는 연결 Provider.
///
/// View·ViewModel은 getIt 대신 이 Provider들을 watch/read 한다.
/// 테스트는 `ProviderScope(overrides: [...])`로 바꿔 끼우고 전역 getIt 등록에 기대지 않는다.
final appEnvProvider = Provider<AppEnv>((ref) => getIt<AppEnv>());
