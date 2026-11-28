// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concert_participants_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConcertParticipantsDto _$ConcertParticipantsDtoFromJson(
  Map<String, dynamic> json,
) => ConcertParticipantsDto(
  teams: (json['teams'] as List<dynamic>)
      .map((e) => ConcertParticipantDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

ConcertParticipantDto _$ConcertParticipantDtoFromJson(
  Map<String, dynamic> json,
) => ConcertParticipantDto(
  isHost: json['isHost'] as bool,
  band: ConcertParticipantBandDto.fromJson(
    json['band'] as Map<String, dynamic>,
  ),
);

ConcertParticipantBandDto _$ConcertParticipantBandDtoFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['profileImageUrl', 'genres', 'memberCount'],
    disallowNullValues: const ['genres', 'memberCount'],
  );
  return ConcertParticipantBandDto(
    bandId: _integer(json['bandId'] as Object),
    name: json['name'] as String,
    profileImageUrl: json['profileImageUrl'] as String?,
    genres: (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
    memberCount: _integer(json['memberCount'] as Object),
  );
}
