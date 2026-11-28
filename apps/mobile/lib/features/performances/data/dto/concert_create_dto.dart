import 'package:json_annotation/json_annotation.dart';

part 'concert_create_dto.g.dart';

/// `POST /api/v1/concerts` 요청 본문 (docs/api/concert-create.md, Swagger `ConcertCreateRequest`).
///
/// 시작·종료 시간, 장소·주소·지역, 포스터는 보내지 않는다. 서버는 빠진 값을 미정(null)으로 저장한다.
@JsonSerializable(createFactory: false)
class ConcertCreateRequestDto {
  const ConcertCreateRequestDto({
    required this.bandId,
    required this.title,
    required this.genres,
    required this.recruitTeamCount,
    required this.performDate,
    required this.rentalFee,
  });

  /// 주최할 밴드. 이 밴드가 주최 팀(라인업 1번)이 된다.
  final int bandId;
  final String title;

  /// 장르 코드 (`ROCK` 등).
  final List<String> genres;

  /// 모집할 팀 수 (주최 팀 제외).
  final int recruitTeamCount;

  /// `yyyy-MM-dd`.
  final String performDate;

  /// 전체 대관비(원). 미정이면 null을 보낸다.
  final int? rentalFee;

  Map<String, dynamic> toJson() => _$ConcertCreateRequestDtoToJson(this);
}

/// `POST /api/v1/concerts` 응답의 `data`.
@JsonSerializable(createToJson: false)
class ConcertCreateResponseDto {
  const ConcertCreateResponseDto({required this.concertId});

  factory ConcertCreateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ConcertCreateResponseDtoFromJson(json);

  /// 서버가 만든 공연 ID. 양의 정수가 아니면(예: 12.5) 응답을 해석하지 못한 것으로 본다.
  @JsonKey(fromJson: _positiveId)
  final int concertId;
}

int _positiveId(Object? json) => switch (json) {
  final int id when id > 0 => id,
  _ => throw FormatException('concertId가 양의 정수가 아니다: $json'),
};
