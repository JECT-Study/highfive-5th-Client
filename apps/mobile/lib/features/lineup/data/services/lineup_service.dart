import 'package:dio/dio.dart';

import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/network/api_response.dart';
import '../dto/lineup_dto.dart';

/// Notion 공연 API 계약. 현재 Swagger에는 아직 제공되지 않는 엔드포인트다.
class LineupService {
  LineupService(this._dio);

  final Dio _dio;

  Future<LineupDto> getLineup(int concertId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/concerts/$concertId/lineup',
      );
      return ApiResponse.fromJson(
        response.data!,
        (data) => LineupDto.fromJson(data! as Map<String, dynamic>),
      ).data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> saveLineup(int concertId, List<int> bandIds) async {
    try {
      await _dio.put<void>(
        '/api/v1/concerts/$concertId/lineup',
        data: {'bandIds': bandIds},
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<BandSetlistDto> getSetlist(int concertId, int bandId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/concerts/$concertId/teams/$bandId/setlist',
      );
      return ApiResponse.fromJson(
        response.data!,
        (data) => BandSetlistDto.fromJson(data! as Map<String, dynamic>),
      ).data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> saveSetlist(
    int concertId,
    int bandId,
    Map<String, Object?> request,
  ) async {
    try {
      await _dio.put<void>(
        '/api/v1/concerts/$concertId/teams/$bandId/setlist',
        data: request,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<SongSearchDto> searchSongs(String keyword) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/songs',
        queryParameters: {'keyword': keyword},
      );
      return ApiResponse.fromJson(
        response.data!,
        (data) => SongSearchDto.fromJson(data! as Map<String, dynamic>),
      ).data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
