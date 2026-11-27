import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../../../core/sdk/photo_picker.dart';
import '../../../uploads/data/repositories/upload_repository.dart';
import '../../data/repositories/profile_repository.dart';

/// 프로필 저장소 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => getIt<ProfileRepository>(),
);

/// 사진 업로드 저장소 연결 Provider (uploads 기능의 계약). 테스트는 overrides로 바꿔 끼운다.
final uploadRepositoryProvider = Provider<UploadRepository>(
  (ref) => getIt<UploadRepository>(),
);

/// 사진 선택기 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => getIt<PhotoPicker>(),
);
