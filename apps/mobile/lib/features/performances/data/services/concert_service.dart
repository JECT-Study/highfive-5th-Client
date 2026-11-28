import 'package:dio/dio.dart';

import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/network/api_log_interceptor.dart';
import '../dto/concert_api_failure_dto.dart';

/// POST는 멱등성·결과 조회 계약이 없으므로 자동 재전송하지 않는다.
class ConcertService {
  ConcertService(this._dio);

  final Dio _dio;

  Future<List<({String code, String name})>> fetchGenres() async {
    final response = await _dio.get<Object?>(
      '/api/v1/codes',
      queryParameters: {'types': 'GENRE'},
    );
    final body = response.data;
    if (body case {
      'code': 'COMMON_000',
      'data': {'GENRE': final List<dynamic> entries},
    }) {
      final genres = <({String code, String name})>[];
      for (final entry in entries) {
        if (entry case {'code': final String code, 'name': final String name}
            when code.isNotEmpty && name.trim().isNotEmpty) {
          if (genres.any((genre) => genre.code == code)) {
            throw const FormatException('중복된 장르 코드');
          }
          genres.add((code: code, name: name));
        } else {
          throw const FormatException('장르 코드 응답 오류');
        }
      }
      return genres;
    }
    throw const FormatException('장르 목록 응답 오류');
  }

  Future<int> create(Map<String, Object?> request) async {
    try {
      final response = await _dio.post<Object?>(
        '/api/v1/concerts',
        data: request,
        options: Options(
          extra: {
            AuthInterceptor.allowReplayKey: false,
            ApiLogInterceptor.logBodyKey: false,
          },
        ),
      );
      if (response.statusCode == 201) {
        if (response.data
            case {'code': 'COMMON_000', 'data': {'concertId': final int id}}
            when id > 0) {
          return id;
        }
      }
      throw const ConcertApiFailureDto();
    } on DioException catch (error) {
      final response = error.response;
      final body = response?.data;
      final fields = <String, String>{};
      if (body is Map && body['errors'] is List) {
        for (final entry in body['errors'] as List) {
          if (entry case {
            'field': final String field,
            'reason': final String reason,
          }) {
            fields[field] = reason;
          }
        }
      }
      throw ConcertApiFailureDto(
        statusCode: response?.statusCode,
        code: body is Map && body['code'] is String
            ? body['code'] as String
            : null,
        fields: fields,
        // 소켓 단절은 전송 후에도 발생한다. connectionError 전체를 미전송으로 보지 않는다.
        definitelyUnsent:
            response == null &&
            (error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.badCertificate),
      );
    }
  }
}
