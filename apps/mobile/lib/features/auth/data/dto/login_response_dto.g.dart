// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    LoginResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: LoginUserDto.fromJson(json['user'] as Map<String, dynamic>),
      nextStep: json['nextStep'] as String,
    );

LoginUserDto _$LoginUserDtoFromJson(Map<String, dynamic> json) => LoginUserDto(
  id: (json['id'] as num).toInt(),
  status: json['status'] as String,
  nickname: json['nickname'] as String?,
);
