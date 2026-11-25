import 'package:dio/dio.dart';

import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/network/api_response.dart';
import '../dto/login_response_dto.dart';

/// 로그인 API 호출 (docs/api/auth-login.md).
/// 오류는 `AppException`으로 바꿔 던진다. 토큰은 로그에 남기지 않는다.
class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  /// [provider]는 `kakao`·`google`·`apple`, [providerToken]은 제공자 SDK가 준 토큰.
  Future<LoginResponseDto> login(
    String provider, {
    required String providerToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/login/$provider',
        data: {'token': providerToken},
      );
      return ApiResponse.fromJson(
        response.data!,
        (data) => LoginResponseDto.fromJson(data! as Map<String, dynamic>),
      ).data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  /// 서버에 저장된 리프레시 토큰을 지운다. 액세스 토큰은 `AuthInterceptor`가 붙인다.
  Future<void> logout() async {
    try {
      await _dio.post<Object?>('/api/v1/auth/logout');
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
