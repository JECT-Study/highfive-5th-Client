// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terms_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TermsResponseDto _$TermsResponseDtoFromJson(Map<String, dynamic> json) =>
    TermsResponseDto(
      terms: (json['terms'] as List<dynamic>)
          .map((e) => TermDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

TermDto _$TermDtoFromJson(Map<String, dynamic> json) => TermDto(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  title: json['title'] as String,
  version: json['version'] as String,
  required: json['required'] as bool,
  contentUrl: json['contentUrl'] as String?,
);
