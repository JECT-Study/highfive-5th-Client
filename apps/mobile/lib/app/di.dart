import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/di/locator.dart';
import '../core/network/dio_client.dart';
import '../core/storage/secure_store.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/data/repositories/session_repository.dart';
import '../features/auth/data/services/auth_service.dart';
import '../features/auth/data/services/fake_auth_service.dart';
import '../features/auth/data/services/google_auth_service.dart';
import '../features/auth/data/services/kakao_auth_service.dart';
import 'env.dart';

/// 앱 공통 객체를 생성·연결한다. 앱 시작 시 한 번만 호출한다.
///
/// - 앱 전체가 공유하는 Service·Repository 등만 등록한다.
/// - ViewModel(Notifier)은 Riverpod이 관리하므로 등록하지 않는다.
/// - 다른 코드는 getIt을 직접 조회하지 않고 연결 Provider를 거친다.
void setupDi(AppEnv env) {
  getIt
    ..registerSingleton<AppEnv>(env)
    ..registerSingleton<Dio>(createDio(baseUrl: env.apiBaseUrl))
    ..registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage())
    ..registerSingleton<SharedPreferencesAsync>(SharedPreferencesAsync());
  getIt
    ..registerLazySingleton(() => SecureStore(getIt<FlutterSecureStorage>()))
    ..registerLazySingleton(() => SessionRepository(getIt<SecureStore>()))
    // TODO(BE): 로그인 서버가 열리면 `AuthService(getIt<Dio>())`로 바꾸고
    // fake_auth_service.dart를 지운다.
    ..registerLazySingleton<AuthService>(FakeAuthService.new)
    ..registerLazySingleton(KakaoAuthService.new)
    ..registerLazySingleton(
      () => GoogleAuthService(
        iosClientId: env.googleIosClientId,
        serverClientId: env.googleServerClientId,
      ),
    )
    ..registerLazySingleton(
      () => AuthRepository(
        getIt<AuthService>(),
        getIt<KakaoAuthService>(),
        getIt<GoogleAuthService>(),
      ),
    );
}
