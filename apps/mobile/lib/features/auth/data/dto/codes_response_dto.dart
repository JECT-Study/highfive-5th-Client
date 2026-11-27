import 'package:json_annotation/json_annotation.dart';

import '../../models/profile_options.dart';

part 'codes_response_dto.g.dart';

/// `GET /api/v1/codes?types=GENRE,POSITION` 응답의 `data` (docs/api/profile.md).
@JsonSerializable(createToJson: false)
class CodesResponseDto {
  const CodesResponseDto({required this.genres, required this.positions});

  factory CodesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CodesResponseDtoFromJson(json);

  @JsonKey(name: 'GENRE')
  final List<CodeDto> genres;

  @JsonKey(name: 'POSITION')
  final List<CodeDto> positions;

  ProfileOptions toModel() => (
    genres: [for (final code in genres) code.toModel()],
    positions: [for (final code in positions) code.toModel()],
  );
}

@JsonSerializable(createToJson: false)
class CodeDto {
  const CodeDto({required this.code, required this.name});

  factory CodeDto.fromJson(Map<String, dynamic> json) =>
      _$CodeDtoFromJson(json);

  /// 저장 API로 보내는 값 (예: `ROCK`).
  final String code;

  /// 화면 표시 이름 (예: `록`).
  final String name;

  ProfileOption toModel() => (code: code, label: name);
}
