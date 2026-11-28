import 'package:json_annotation/json_annotation.dart';

import '../../models/concert_participant.dart';

part 'concert_participants_dto.g.dart';

/// 라인업 조회 초안(`GET /api/v1/concerts/{concertId}/lineup`) 응답 `data`에서 참여 밴드 미리보기에 쓰는 값만 읽는다.
/// 공연 순서·셋리스트·빈자리 수는 라인업 기능(JECT-165)이 읽으므로 받지 않는다. docs/api/concert-participants.md 참조.
@JsonSerializable(createToJson: false)
class ConcertParticipantsDto {
  const ConcertParticipantsDto({required this.teams});

  factory ConcertParticipantsDto.fromJson(Map<String, dynamic> json) =>
      _$ConcertParticipantsDtoFromJson(json);

  /// 공연 순서대로 온다.
  final List<ConcertParticipantDto> teams;

  List<ConcertParticipant> toModel() =>
      List.unmodifiable([for (final team in teams) team.toModel()]);
}

@JsonSerializable(createToJson: false)
class ConcertParticipantDto {
  const ConcertParticipantDto({required this.isHost, required this.band});

  factory ConcertParticipantDto.fromJson(Map<String, dynamic> json) =>
      _$ConcertParticipantDtoFromJson(json);

  // 누락·null은 파싱 실패로 남긴다. 주최 여부를 false로 채우지 않는다.
  final bool isHost;
  final ConcertParticipantBandDto band;

  ConcertParticipant toModel() => ConcertParticipant(
    bandId: band.bandId,
    name: band.name,
    isHost: isHost,
    profileImageUrl: band.profileImageUrl,
    genres: List.unmodifiable(band.genres),
    memberCount: band.memberCount,
  );
}

@JsonSerializable(createToJson: false)
class ConcertParticipantBandDto {
  const ConcertParticipantBandDto({
    required this.bandId,
    required this.name,
    required this.profileImageUrl,
    required this.genres,
    required this.memberCount,
  });

  factory ConcertParticipantBandDto.fromJson(Map<String, dynamic> json) =>
      _$ConcertParticipantBandDtoFromJson(json);

  // 기본 생성기의 num.toInt()는 소수 ID를 잘라 버린다. 공연 상세 DTO처럼 JSON 정수만 받는다.
  @JsonKey(fromJson: _integer)
  final int bandId;
  final String name;

  @JsonKey(required: true)
  final String? profileImageUrl;
  @JsonKey(required: true, disallowNullValue: true)
  final List<String> genres;
  @JsonKey(required: true, disallowNullValue: true, fromJson: _integer)
  final int memberCount;
}

int _integer(Object json) => json as int;
