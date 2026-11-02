import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    // 헤더에는 토큰이 섞이므로 남기지 않는다. 디버그 실행에서만 켠다.
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
      ),
    );
  }
  return dio;
}
