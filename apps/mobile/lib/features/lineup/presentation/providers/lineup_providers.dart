import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../data/repositories/lineup_repository.dart';

final lineupRepositoryProvider = Provider<LineupRepository>(
  (ref) => getIt<LineupRepository>(),
);
