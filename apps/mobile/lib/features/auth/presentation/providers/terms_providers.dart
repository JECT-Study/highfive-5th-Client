import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../data/repositories/terms_repository.dart';

/// 약관 저장소 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final termsRepositoryProvider = Provider<TermsRepository>(
  (ref) => getIt<TermsRepository>(),
);
