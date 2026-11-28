// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concert_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ConcertCreateRequestDtoToJson(
  ConcertCreateRequestDto instance,
) => <String, dynamic>{
  'bandId': instance.bandId,
  'title': instance.title,
  'genres': instance.genres,
  'recruitTeamCount': instance.recruitTeamCount,
  'performDate': instance.performDate,
  'rentalFee': instance.rentalFee,
};

ConcertCreateResponseDto _$ConcertCreateResponseDtoFromJson(
  Map<String, dynamic> json,
) => ConcertCreateResponseDto(concertId: _positiveId(json['concertId']));
