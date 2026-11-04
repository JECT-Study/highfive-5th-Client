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
    // 헤더와 본문에는 토큰·개인정보가 섞이므로 기본으로 남기지 않는다.
    // 본문이 필요하면 로컬에서만 잠시 켜고 커밋하지 않는다.
    dio.interceptors.add(
      LogInterceptor(requestHeader: false, responseHeader: false),
    );
  }
  return dio;
}
