import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/uploads/data/dto/upload_url_dto.dart';
import 'package:highfive/features/uploads/data/repositories/upload_repository.dart';
import 'package:highfive/features/uploads/data/services/upload_service.dart';
import 'package:highfive/features/uploads/models/upload_failure.dart';
import 'package:highfive/features/uploads/models/upload_purpose.dart';

/// 서버·저장소 대신 정해진 결과를 돌려주고 받은 값을 기록한다.
class _FakeUploadService extends UploadService {
  _FakeUploadService({this.requestError, this.putError}) : super(Dio(), Dio());

  final AppException? requestError;
  final AppException? putError;
  UploadUrlRequestDto? request;
  String? putUrl;
  String? putContentType;

  @override
  Future<UploadUrlResponseDto> requestUploadUrl(
    UploadUrlRequestDto request,
  ) async {
    this.request = request;
    if (requestError case final error?) throw error;
    return const UploadUrlResponseDto(
      uploadUrl: 'https://bucket.test/a.jpg?sig',
      fileUrl: 'https://cdn.test/a.jpg',
      expiresAt: '2026-11-27T19:05:00',
    );
  }

  @override
  Future<void> putFile(
    String uploadUrl, {
    required String path,
    required int sizeBytes,
    required String contentType,
  }) async {
    putUrl = uploadUrl;
    putContentType = contentType;
    if (putError case final error?) throw error;
  }
}

Future<String> _upload(UploadRepository repository) => repository.uploadImage(
  purpose: UploadPurpose.userProfile,
  path: '/tmp/a.jpg',
  sizeBytes: 2048,
  contentType: 'image/png',
);

void main() {
  test('주소를 받아 그 주소로 올리고, 저장에 쓸 주소를 돌려준다', () async {
    final service = _FakeUploadService();

    final fileUrl = await _upload(UploadRepository(service));

    expect(service.request?.toJson(), {
      'purpose': 'USER_PROFILE',
      'contentType': 'image/png',
      'fileSize': 2048,
    });
    expect(service.putUrl, 'https://bucket.test/a.jpg?sig');
    expect(service.putContentType, 'image/png');
    expect(fileUrl, 'https://cdn.test/a.jpg');
  });

  test('주소 발급·업로드 오류를 실패 이유로 바꾼다', () async {
    for (final (service, expected) in [
      (
        _FakeUploadService(requestError: const NetworkException()),
        UploadFailureReason.network,
      ),
      (
        _FakeUploadService(
          requestError: const ApiException(statusCode: 400, code: 'COMMON_004'),
        ),
        UploadFailureReason.rejected,
      ),
      (
        _FakeUploadService(putError: const ApiException(statusCode: 403)),
        UploadFailureReason.unknown,
      ),
      (
        _FakeUploadService(putError: const NetworkException()),
        UploadFailureReason.network,
      ),
    ]) {
      await expectLater(
        _upload(UploadRepository(service)),
        throwsA(
          isA<UploadFailure>().having((f) => f.reason, 'reason', expected),
        ),
      );
    }
  });

  test('주소 발급이 실패하면 업로드하지 않는다', () async {
    final service = _FakeUploadService(requestError: const NetworkException());

    await expectLater(
      _upload(UploadRepository(service)),
      throwsA(isA<UploadFailure>()),
    );
    expect(service.putUrl, isNull);
  });
}
