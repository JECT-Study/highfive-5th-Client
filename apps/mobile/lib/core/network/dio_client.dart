import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_log_interceptor.dart';

/// 앱 공통 Dio. 인증 헤더·토큰 갱신 인터셉터는 auth 기능을 구현할 때 여기에 붙인다.
Dio createDio({required String baseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  if (kDebugMode) {
    // 본문은 토큰 값을 가려서 찍고, 헤더는 찍지 않는다.
    dio.interceptors.add(ApiLogInterceptor());
  }
  return dio;
}
