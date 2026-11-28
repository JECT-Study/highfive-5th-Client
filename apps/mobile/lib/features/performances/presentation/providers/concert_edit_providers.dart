import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../data/repositories/concert_edit_repository.dart';
import '../../models/concert_edit_form.dart';

final concertEditRepositoryProvider = Provider<ConcertEditRepository>(
  (ref) => getIt<ConcertEditRepository>(),
  dependencies: const [],
);

/// 서버 업무 시간대(Asia/Seoul) 기준 오늘. 테스트에서 날짜를 고정할 때 바꿔 끼운다.
final concertEditTodayProvider = Provider<DateTime Function()>(
  (ref) =>
      () => concertBusinessDate(DateTime.now()),
);
