import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../../../core/sdk/photo_picker.dart';
import '../../../uploads/data/repositories/upload_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../models/profile_options.dart';

/// 프로필 저장소 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => getIt<ProfileRepository>(),
);

/// 장르·포지션 선택지 (`GET /api/v1/codes`). 정보 화면이 열릴 때 읽는다.
/// 저장소가 캐시하므로 다시 열어도 서버에 다시 묻지 않는다. 실패하면 화면이 "다시 시도"를 보인다.
final profileOptionsProvider = FutureProvider.autoDispose<ProfileOptions>(
  (ref) => ref.read(profileRepositoryProvider).fetchOptions(),
  retry: (_, _) => null,
);

/// 사진 업로드 저장소 연결 Provider (uploads 기능의 계약). 테스트는 overrides로 바꿔 끼운다.
final uploadRepositoryProvider = Provider<UploadRepository>(
  (ref) => getIt<UploadRepository>(),
);

/// 사진 선택기 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => getIt<PhotoPicker>(),
);
