import 'package:dio/dio.dart';

import '../../../../core/network/api_log_interceptor.dart';
import '../dto/concert_edit_request_dto.dart';

/// 확인된 PUT만 제공한다. 상세 GET의 응답 형태를 추정하지 않는다.
class ConcertEditService {
  ConcertEditService(this._dio);

  final Dio _dio;

  Future<void> replace(int concertId, ConcertEditRequestDto request) async {
    final response = await _dio.put<Object?>(
      '/api/v1/concerts/$concertId',
      data: request.toJson(),
      options: Options(extra: {ApiLogInterceptor.logBodyKey: false}),
    );
    if (response.statusCode == 200) {
      if (response.data case {'code': 'COMMON_000', 'data': Map()}) return;
    }
    throw const FormatException('공연 수정 성공 응답 형식 오류');
  }
}
