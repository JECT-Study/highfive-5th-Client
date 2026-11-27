import 'package:json_annotation/json_annotation.dart';

import '../../models/upload_purpose.dart';

part 'upload_url_dto.g.dart';

/// `POST /api/v1/uploads/presigned-url` 요청 본문 (docs/api/profile.md).
@JsonSerializable(createFactory: false)
class UploadUrlRequestDto {
  const UploadUrlRequestDto({
    required this.purpose,
    required this.contentType,
    required this.fileSize,
  });

  /// `USER_PROFILE` 등. [purposeOf]로 만든다.
  final String purpose;

  /// `image/jpeg` · `image/png` · `image/heic`. 저장소에 올릴 때도 같은 값을 보낸다.
  final String contentType;

  /// 바이트.
  final int fileSize;

  Map<String, dynamic> toJson() => _$UploadUrlRequestDtoToJson(this);

  static String purposeOf(UploadPurpose purpose) => switch (purpose) {
    UploadPurpose.userProfile => 'USER_PROFILE',
  };
}

/// `POST /api/v1/uploads/presigned-url` 응답의 `data`.
@JsonSerializable(createToJson: false)
class UploadUrlResponseDto {
  const UploadUrlResponseDto({
    required this.uploadUrl,
    required this.fileUrl,
    required this.expiresAt,
  });

  factory UploadUrlResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UploadUrlResponseDtoFromJson(json);

  /// 파일을 `PUT`으로 올릴 주소 (5분 유효). 서명이 들어 있으니 로그에 찍지 않는다.
  final String uploadUrl;

  /// 올린 뒤 프로필 저장 등에 보낼 주소.
  final String fileUrl;

  /// [uploadUrl] 만료 시각. 앱은 아직 쓰지 않는다 (실패하면 처음부터 다시 받는다).
  final String expiresAt;
}
