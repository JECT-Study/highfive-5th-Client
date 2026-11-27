import 'package:dio/dio.dart';

import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/network/api_response.dart';
import '../dto/nickname_availability_dto.dart';
import '../dto/profile_dto.dart';

/// 개인 프로필 API 호출 (docs/api/profile.md). 액세스 토큰은 `AuthInterceptor`가 붙인다.
/// 오류는 `AppException`으로 바꿔 던진다.
class ProfileService {
  ProfileService(this._dio);

  final Dio _dio;

  /// 닉네임을 쓸 수 있는지. Dio가 query 값을 URL 인코딩한다.
  Future<NicknameAvailabilityDto> checkNickname(String nickname) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/users/nickname-availability',
        queryParameters: {'nickname': nickname},
      );
      return ApiResponse.fromJson(
        response.data!,
        (data) =>
            NicknameAvailabilityDto.fromJson(data! as Map<String, dynamic>),
      ).data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  /// 닉네임·장르·포지션·사진을 한 번에 저장하고 다음 화면을 받는다.
  Future<ProfileResponseDto> saveProfile(ProfileRequestDto request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/v1/users/me/profile',
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (data) => ProfileResponseDto.fromJson(data! as Map<String, dynamic>),
      ).data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
