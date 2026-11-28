import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../dto/concert_update_error_dto.dart';
import '../dto/concert_update_request_dto.dart';

/// 공연 기본 정보 수정 PUT. 앱 기본 DI에는 등록하지 않고 루프백 계약 테스트에서 호출한다.
class ConcertEditService {
  ConcertEditService(this._dio);

  final Dio _dio;

  /// 공연 정보를 통째로 바꾼다. 성공 응답의 `data`는 비어 있다(`{}`).
  /// 실패는 [ConcertUpdateErrorDto]로 던진다.
  Future<void> update(int concertId, ConcertUpdateRequestDto request) async {
    try {
      await _dio.put<Object?>(
        '/api/v1/concerts/$concertId',
        data: request.toJson(),
      );
    } on DioException catch (error) {
      final body = error.response?.data;
      final status = error.response?.statusCode;
      final unknownOutcome = status == 408 || (status != null && status >= 500);
      final failure = switch (error.type) {
        DioExceptionType.badResponse => ApiException(
          statusCode: status,
          code: unknownOutcome
              ? null
              : switch (body) {
                  {'code': final String code} => code,
                  _ => null,
                },
          message: switch (body) {
            {'message': final String message} => message,
            _ => null,
          },
        ),
        _ => mapDioException(error),
      };
      throw ConcertUpdateErrorDto(
        failure,
        fieldErrors: ConcertUpdateErrorDto.fieldErrorsOf(body),
      );
    }
  }
}
