import 'package:json_annotation/json_annotation.dart';

import '../../models/session.dart';

part 'login_response_dto.g.dart';

/// `POST /api/v1/auth/login/{provider}` 응답의 `data` (docs/api/auth-login.md).
@JsonSerializable(createToJson: false)
class LoginResponseDto {
  const LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.nextStep,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  final String accessToken;
  final String refreshToken;
  final LoginUserDto user;

  /// `TERMS` / `PROFILE` / `BAND_START` / `HOME`. 해당 화면이 생기면 모델로 옮겨 이동에 쓴다.
  final String nextStep;

  Session toModel() =>
      Session(accessToken: accessToken, refreshToken: refreshToken);
}

@JsonSerializable(createToJson: false)
class LoginUserDto {
  const LoginUserDto({required this.id, required this.status, this.nickname});

  factory LoginUserDto.fromJson(Map<String, dynamic> json) =>
      _$LoginUserDtoFromJson(json);

  final int id;

  /// `PENDING`(약관·프로필 미완료) / `ACTIVE`.
  final String status;

  /// 프로필 생성 전에는 null.
  final String? nickname;
}
