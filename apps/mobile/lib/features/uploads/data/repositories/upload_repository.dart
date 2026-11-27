import '../../../../core/error/app_exception.dart';
import '../../models/upload_failure.dart';
import '../../models/upload_purpose.dart';
import '../dto/upload_url_dto.dart';
import '../services/upload_service.dart';

/// 기기 안의 사진을 저장소에 올리고 저장 API에 보낼 주소를 돌려준다.
/// 개인 프로필과 밴드 프로필이 같이 쓴다. 실패는 [UploadFailure]로 바꿔 던진다.
class UploadRepository {
  UploadRepository(this._service);

  final UploadService _service;

  /// 주소 발급 → 저장소 업로드. 어느 쪽이 실패해도 다음 시도는 주소 발급부터 다시 한다.
  Future<String> uploadImage({
    required UploadPurpose purpose,
    required String path,
    required int sizeBytes,
    required String contentType,
  }) async {
    try {
      final url = await _service.requestUploadUrl(
        UploadUrlRequestDto(
          purpose: UploadUrlRequestDto.purposeOf(purpose),
          contentType: contentType,
          fileSize: sizeBytes,
        ),
      );
      await _service.putFile(
        url.uploadUrl,
        path: path,
        sizeBytes: sizeBytes,
        contentType: contentType,
      );
      return url.fileUrl;
    } on AppException catch (error) {
      throw UploadFailure(_reasonOf(error), error);
    }
  }

  static UploadFailureReason _reasonOf(AppException error) => switch (error) {
    NetworkException() => UploadFailureReason.network,
    ApiException(code: 'COMMON_004') => UploadFailureReason.rejected,
    ApiException() || UnknownApiException() => UploadFailureReason.unknown,
  };
}
