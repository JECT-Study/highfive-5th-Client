import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../data/repositories/concert_management_repository.dart';

final concertManagementRepositoryProvider =
    Provider<ConcertManagementRepository>(
      (ref) => getIt<ConcertManagementRepository>(),
      dependencies: const [],
    );
