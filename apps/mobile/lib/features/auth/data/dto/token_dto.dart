import 'package:json_annotation/json_annotation.dart';

import '../../models/session.dart';

part 'token_dto.g.dart';

/// 로그인 응답의 토큰. 필드 이름은 BE 명세가 나오면 맞춘다.
@JsonSerializable(createToJson: false)
class TokenDto {
  const TokenDto({required this.accessToken, this.refreshToken});

  factory TokenDto.fromJson(Map<String, dynamic> json) =>
      _$TokenDtoFromJson(json);

  final String accessToken;
  final String? refreshToken;

  Session toModel() =>
      Session(accessToken: accessToken, refreshToken: refreshToken);
}
