// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ProfileRequestDtoToJson(ProfileRequestDto instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'genreCodes': instance.genreCodes,
      'genreCustomName': instance.genreCustomName,
      'positionCodes': instance.positionCodes,
      'positionCustomName': instance.positionCustomName,
      'profileImageUrl': instance.profileImageUrl,
    };

ProfileResponseDto _$ProfileResponseDtoFromJson(Map<String, dynamic> json) =>
    ProfileResponseDto(
      status: json['status'] as String,
      nextStep: json['nextStep'] as String,
    );
