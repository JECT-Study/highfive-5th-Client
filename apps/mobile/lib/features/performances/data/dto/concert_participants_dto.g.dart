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
) => ConcertParticipantBandDto(
  bandId: _integer(json['bandId'] as Object),
  name: json['name'] as String,
);
