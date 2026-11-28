import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../data/services/concert_edit_service.dart';

final concertEditServiceProvider = Provider<ConcertEditService>(
  (ref) => getIt<ConcertEditService>(),
);
