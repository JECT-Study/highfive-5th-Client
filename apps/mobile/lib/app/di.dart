import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/di/locator.dart';
import '../core/network/auth_interceptor.dart';
import '../core/network/dio_client.dart';
import '../core/network/session_expiry.dart';
import '../core/storage/secure_store.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/data/repositories/session_repository.dart';
import '../features/auth/data/services/auth_service.dart';
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
    ..registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage())
    ..registerSingleton<SharedPreferencesAsync>(SharedPreferencesAsync());
  getIt
    ..registerLazySingleton(() => SecureStore(getIt<FlutterSecureStorage>()))
    ..registerLazySingleton(SessionExpiry.new)
    // API 호출용 Dio. 토큰을 붙이고 만료되면 재발급한다.
    // 재발급·재시도는 인터셉터가 없는 Dio로 보낸다.
    ..registerLazySingleton<Dio>(
      () => createDio(baseUrl: env.apiBaseUrl)
        ..interceptors.add(
          AuthInterceptor(
            store: getIt<SecureStore>(),
            plainDio: createDio(baseUrl: env.apiBaseUrl),
            expiry: getIt<SessionExpiry>(),
          ),
        ),
    )
    ..registerLazySingleton(() => SessionRepository(getIt<SecureStore>()))
    ..registerLazySingleton(() => AuthService(getIt<Dio>()))
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
