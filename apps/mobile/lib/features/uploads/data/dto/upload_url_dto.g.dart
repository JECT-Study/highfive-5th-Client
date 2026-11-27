// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_url_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$UploadUrlRequestDtoToJson(
  UploadUrlRequestDto instance,
) => <String, dynamic>{
  'purpose': instance.purpose,
  'contentType': instance.contentType,
  'fileSize': instance.fileSize,
};

UploadUrlResponseDto _$UploadUrlResponseDtoFromJson(
  Map<String, dynamic> json,
) => UploadUrlResponseDto(
  uploadUrl: json['uploadUrl'] as String,
  fileUrl: json['fileUrl'] as String,
  expiresAt: json['expiresAt'] as String,
);
