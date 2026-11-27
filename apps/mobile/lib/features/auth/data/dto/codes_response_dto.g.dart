// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codes_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodesResponseDto _$CodesResponseDtoFromJson(Map<String, dynamic> json) =>
    CodesResponseDto(
      genres: (json['GENRE'] as List<dynamic>)
          .map((e) => CodeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      positions: (json['POSITION'] as List<dynamic>)
          .map((e) => CodeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

CodeDto _$CodeDtoFromJson(Map<String, dynamic> json) =>
    CodeDto(code: json['code'] as String, name: json['name'] as String);
