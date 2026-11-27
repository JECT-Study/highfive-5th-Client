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

/// 파일 저장소(S3)에 presigned URL로 직접 올리는 Dio. 주소에 서명이 들어 있으므로
/// 토큰 인터셉터를 붙이지 않고(명세: Authorization 헤더 없음) 로그도 찍지 않는다.
Dio createStorageDio() => Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 20),
  ),
);
