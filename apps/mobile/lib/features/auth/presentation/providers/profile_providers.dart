import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../../../core/sdk/photo_picker.dart';
import '../../data/repositories/profile_repository.dart';

/// 프로필 저장소 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => getIt<ProfileRepository>(),
);

/// 사진 선택기 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => getIt<PhotoPicker>(),
);
