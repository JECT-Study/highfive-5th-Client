import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/uploads/data/dto/upload_url_dto.dart';
import 'package:highfive/features/uploads/data/services/upload_service.dart';

/// 네트워크 대신 정해진 응답을 돌려주고 받은 요청·본문 크기를 기록한다.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, [this.body]);

  final int statusCode;
  final Map<String, Object?>? body;
  RequestOptions? request;
  int sentBytes = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        sentBytes += chunk.length;
      }
    }
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_FakeAdapter adapter, {String baseUrl = ''}) =>
    Dio(BaseOptions(baseUrl: baseUrl))..httpClientAdapter = adapter;

void main() {
  test('업로드 URL 발급: 용도·형식·크기를 보내고 주소를 읽는다', () async {
    final api = _FakeAdapter(200, {
      'status': 200,
      'code': 'COMMON_000',
      'message': '요청이 성공했습니다.',
      'data': {
        'uploadUrl':
            'https://bucket.test/users/12/profile/a.jpg?X-Amz-Signature=s',
        'fileUrl': 'https://cdn.test/users/12/profile/a.jpg',
        'expiresAt': '2026-11-27T19:05:00',
      },
    });
    final service = UploadService(
      _dio(api, baseUrl: 'https://api.test'),
      _dio(_FakeAdapter(200)),
    );

    final response = await service.requestUploadUrl(
      const UploadUrlRequestDto(
        purpose: 'USER_PROFILE',
        contentType: 'image/jpeg',
        fileSize: 1048576,
      ),
    );

    expect(api.request?.method, 'POST');
    expect(api.request?.path, '/api/v1/uploads/presigned-url');
    expect(api.request?.data, {
      'purpose': 'USER_PROFILE',
      'contentType': 'image/jpeg',
      'fileSize': 1048576,
    });
    expect(response.fileUrl, 'https://cdn.test/users/12/profile/a.jpg');
  });

  test('저장소 업로드: 받은 주소로 파일을 PUT하고 같은 Content-Type을 보낸다, 토큰은 없다', () async {
    final directory = await Directory.systemTemp.createTemp('upload_test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/a.jpg')..writeAsBytesSync([1, 2, 3]);
    final storage = _FakeAdapter(200);
    final service = UploadService(_dio(_FakeAdapter(200)), _dio(storage));

    await service.putFile(
      'https://bucket.test/users/12/profile/a.jpg?X-Amz-Signature=s',
      path: file.path,
      sizeBytes: 3,
      contentType: 'image/jpeg',
    );

    expect(storage.request?.method, 'PUT');
    expect(
      storage.request?.uri.toString(),
      'https://bucket.test/users/12/profile/a.jpg?X-Amz-Signature=s',
    );
    expect(storage.request?.contentType, 'image/jpeg');
    expect(storage.request?.headers.containsKey('Authorization'), isFalse);
    expect(storage.sentBytes, 3);
  });

  test('저장소가 거부하면(예: 주소 만료 403) ApiException으로 던진다', () async {
    final directory = await Directory.systemTemp.createTemp('upload_test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/a.jpg')..writeAsBytesSync([1]);
    final service = UploadService(
      _dio(_FakeAdapter(200)),
      _dio(_FakeAdapter(403)),
    );

    await expectLater(
      service.putFile(
        'https://bucket.test/a.jpg',
        path: file.path,
        sizeBytes: 1,
        contentType: 'image/jpeg',
      ),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403),
      ),
    );
  });
}
