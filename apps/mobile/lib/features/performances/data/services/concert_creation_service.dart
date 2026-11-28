import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/network/api_response.dart';
import '../dto/concert_create_dto.dart';

/// 합동공연 생성 API 호출 (docs/api/concert-create.md). 액세스 토큰은 `AuthInterceptor`가 붙인다.
/// 오류는 `AppException`으로 바꿔 던진다.
class ConcertCreationService {
  ConcertCreationService(this._dio);

  final Dio _dio;

  /// 공연을 만들고 서버가 정한 공연 ID를 받는다.
  ///
  /// - 본문을 보내기 시작한 뒤 응답 없이 끊기면(보내기·받기 시간 초과, 응답 헤더 전 연결 끊김) 서버가 이미 만들었을 수 있다.
  ///   core 매퍼는 이를 연결 실패와 같은 [NetworkException]으로 바꾸므로, 이 요청에서는 결과를 모르는
  ///   [UnknownApiException]으로 던진다. 연결 단계에서 실패해 본문을 하나도 보내지 못했으면 [NetworkException] 그대로다.
  /// - 성공 응답이 계약(201, `COMMON_000`, 양의 정수 `concertId`)과 다르면 [FormatException]을 던진다. 만들어졌는지 알 수 없다.
  /// - [abandoned]가 끝나면 요청을 취소한다. 본문을 보내지 않은 취소에는 결과 불명 잠금을 남기지 않는다.
  Future<ConcertCreateResponseDto> create(
    ConcertCreateRequestDto request, {
    Future<void>? abandoned,
  }) async {
    final cancelToken = CancelToken();
    unawaited(abandoned?.whenComplete(cancelToken.cancel));
    var bodySent = false;
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/concerts',
        data: request.toJson(),
        options: Options(followRedirects: false),
        cancelToken: cancelToken,
        onSendProgress: (sent, _) => bodySent = bodySent || sent > 0,
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel && !bodySent) {
        throw const NetworkException();
      }
      final mayHaveArrived = switch (error.type) {
        DioExceptionType.sendTimeout || DioExceptionType.receiveTimeout => true,
        DioExceptionType.connectionError => bodySent,
        _ => false,
      };
      if (mayHaveArrived) throw UnknownApiException(error.type);
      throw mapDioException(error);
    }
    final json = response.data;
    if (response.statusCode != 201 ||
        json == null ||
        json['status'] is! int ||
        json['status'] != 201 ||
        json['code'] != 'COMMON_000') {
      throw const FormatException('합동공연 생성 응답이 계약과 다르다.');
    }
    return ApiResponse.fromJson(
      json,
      (data) =>
          ConcertCreateResponseDto.fromJson(data! as Map<String, dynamic>),
    ).data;
  }
}
