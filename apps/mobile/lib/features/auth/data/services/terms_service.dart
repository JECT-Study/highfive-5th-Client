import 'package:dio/dio.dart';

import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/network/api_response.dart';
import '../dto/term_agreements_dto.dart';
import '../dto/terms_response_dto.dart';

/// 약관 API 호출 (docs/api/terms.md). 액세스 토큰은 `AuthInterceptor`가 붙인다.
/// 오류는 `AppException`으로 바꿔 던진다.
class TermsService {
  TermsService(this._dio);

  final Dio _dio;

  /// 지금 시행 중인 최신 약관 목록.
  Future<TermsResponseDto> fetchTerms() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/terms');
      return ApiResponse.fromJson(
        response.data!,
        (data) => TermsResponseDto.fromJson(data! as Map<String, dynamic>),
      ).data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  /// 약관마다 동의·거부를 저장하고 다음 화면을 받는다.
  Future<TermAgreementsResponseDto> saveAgreements(
    TermAgreementsRequestDto request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/users/me/term-agreements',
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (data) =>
            TermAgreementsResponseDto.fromJson(data! as Map<String, dynamic>),
      ).data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
