import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/di/locator.dart';
import '../core/network/dio_client.dart';
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
}
