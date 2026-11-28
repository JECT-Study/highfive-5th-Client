// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concert_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConcertDetailDto _$ConcertDetailDtoFromJson(
  Map<String, dynamic> json,
) => ConcertDetailDto(
  concertId: const _IntegerConverter().fromJson(json['concertId'] as Object),
  title: json['title'] as String,
  genres: (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
  recruitTeamCount: const _IntegerConverter().fromJson(
    json['recruitTeamCount'] as Object,
  ),
  performDate: json['performDate'] as String?,
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  place: json['place'] as String?,
  address: json['address'] as String?,
  region: json['region'] as String?,
  rentalFee: _$JsonConverterFromJson<Object, int>(
    json['rentalFee'],
    const _IntegerConverter().fromJson,
  ),
  posterImageUrl: json['posterImageUrl'] as String?,
  status: $enumDecode(
    _$ConcertStatusEnumMap,
    json['status'],
    unknownValue: ConcertStatus.unknown,
  ),
  hostBandId: const _IntegerConverter().fromJson(json['hostBandId'] as Object),
  myBandIds: (json['myBandIds'] as List<dynamic>)
      .map((e) => const _IntegerConverter().fromJson(e as Object))
      .toList(),
  myPermissions: ConcertPermissionsDto.fromJson(
    json['myPermissions'] as Map<String, dynamic>,
  ),
  recruitment: json['recruitment'] == null
      ? null
      : ConcertRecruitmentDto.fromJson(
          json['recruitment'] as Map<String, dynamic>,
        ),
  version: const _IntegerConverter().fromJson(json['version'] as Object),
  updatedAt: json['updatedAt'] as String,
);

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$ConcertStatusEnumMap = {
  ConcertStatus.beforeRecruit: 'BEFORE_RECRUIT',
  ConcertStatus.recruiting: 'RECRUITING',
  ConcertStatus.selling: 'SELLING',
  ConcertStatus.salePaused: 'SALE_PAUSED',
  ConcertStatus.saleClosed: 'SALE_CLOSED',
  ConcertStatus.unknown: 'unknown',
};

ConcertPermissionsDto _$ConcertPermissionsDtoFromJson(
  Map<String, dynamic> json,
) => ConcertPermissionsDto(
  isHostLeader: json['isHostLeader'] as bool,
  isTeamLeader: json['isTeamLeader'] as bool,
);

ConcertRecruitmentDto _$ConcertRecruitmentDtoFromJson(
  Map<String, dynamic> json,
) => ConcertRecruitmentDto(
  recruitPostId: const _IntegerConverter().fromJson(
    json['recruitPostId'] as Object,
  ),
  status: $enumDecode(
    _$RecruitmentStatusEnumMap,
    json['status'],
    unknownValue: RecruitmentStatus.unknown,
  ),
  deadline: json['deadline'] as String,
  joinedTeamCount: const _IntegerConverter().fromJson(
    json['joinedTeamCount'] as Object,
  ),
  recruitTeamCount: const _IntegerConverter().fromJson(
    json['recruitTeamCount'] as Object,
  ),
  newInquiryCount: const _IntegerConverter().fromJson(
    json['newInquiryCount'] as Object,
  ),
);

const _$RecruitmentStatusEnumMap = {
  RecruitmentStatus.recruiting: 'RECRUITING',
  RecruitmentStatus.closed: 'CLOSED',
  RecruitmentStatus.unknown: 'unknown',
};
