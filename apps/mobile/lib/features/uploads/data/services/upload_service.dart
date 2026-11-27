import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/network/api_response.dart';
import '../dto/upload_url_dto.dart';

/// 업로드 URL 발급(우리 서버)과 파일 업로드(저장소) 호출 (docs/api/profile.md).
/// 오류는 `AppException`으로 바꿔 던진다.
class UploadService {
  UploadService(this._api, this._storage);

  /// 우리 서버용. `AuthInterceptor`가 토큰을 붙인다.
  final Dio _api;

  /// 저장소용 (`createStorageDio`). 토큰·로그 없음.
  final Dio _storage;

  /// 저장소에 직접 올릴 임시 주소를 받는다.
  Future<UploadUrlResponseDto> requestUploadUrl(
    UploadUrlRequestDto request,
  ) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/v1/uploads/presigned-url',
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (data) => UploadUrlResponseDto.fromJson(data! as Map<String, dynamic>),
      ).data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  /// [uploadUrl]에 파일을 `PUT`한다. `Content-Type`은 발급 요청과 같은 값이어야 서명이 맞는다.
  Future<void> putFile(
    String uploadUrl, {
    required String path,
    required int sizeBytes,
    required String contentType,
  }) async {
    try {
      await _storage.putUri<void>(
        Uri.parse(uploadUrl),
        data: File(path).openRead(),
        options: Options(
          contentType: contentType,
          headers: {Headers.contentLengthHeader: sizeBytes},
        ),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
