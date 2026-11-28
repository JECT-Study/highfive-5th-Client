import 'package:json_annotation/json_annotation.dart';

import '../../models/concert_detail.dart';
import '../../models/concert_status.dart';
import '../../models/recruitment_status.dart';

part 'concert_detail_dto.g.dart';

/// 공연 GET 초안 응답의 `data`. docs/api/concert-detail.md 참조.
@JsonSerializable(createToJson: false, converters: [_IntegerConverter()])
class ConcertDetailDto {
  const ConcertDetailDto({
    required this.concertId,
    required this.title,
    required this.genres,
    required this.recruitTeamCount,
    required this.performDate,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.address,
    required this.region,
    required this.rentalFee,
    required this.posterImageUrl,
    required this.status,
    required this.hostBandId,
    required this.myBandIds,
    required this.myPermissions,
    required this.recruitment,
    required this.version,
    required this.updatedAt,
  });

  factory ConcertDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ConcertDetailDtoFromJson(json);

  final int concertId;
  final String title;
  final List<String> genres;
  final int recruitTeamCount;
  final String? performDate;
  final String? startTime;
  final String? endTime;
  final String? place;
  final String? address;
  final String? region;
  final int? rentalFee;
  final String? posterImageUrl;
  @JsonKey(unknownEnumValue: ConcertStatus.unknown)
  final ConcertStatus status;
  final int hostBandId;
  final List<int> myBandIds;
  final ConcertPermissionsDto myPermissions;
  final ConcertRecruitmentDto? recruitment;
  final int version;
  final String updatedAt;

  ConcertDetail toModel() => ConcertDetail(
    concertId: concertId,
    title: title,
    genres: List.unmodifiable(genres),
    recruitTeamCount: recruitTeamCount,
    performDate: performDate,
    startTime: startTime,
    endTime: endTime,
    place: place,
    address: address,
    region: region,
    rentalFee: rentalFee,
    posterImageUrl: posterImageUrl,
    status: status,
    hostBandId: hostBandId,
    myBandIds: List.unmodifiable(myBandIds),
    myPermissions: myPermissions.toModel(),
    recruitment: recruitment?.toModel(),
    version: version,
    updatedAt: updatedAt,
  );
}

@JsonSerializable(createToJson: false, converters: [_IntegerConverter()])
class ConcertPermissionsDto {
  const ConcertPermissionsDto({
    required this.isHostLeader,
    required this.isTeamLeader,
  });

  factory ConcertPermissionsDto.fromJson(Map<String, dynamic> json) =>
      _$ConcertPermissionsDtoFromJson(json);

  // 누락·null은 파싱 실패로 남긴다. true나 역할 추론으로 대체하지 않는다.
  final bool isHostLeader;
  final bool isTeamLeader;

  ConcertPermissions toModel() => ConcertPermissions(
    isHostLeader: isHostLeader,
    isTeamLeader: isTeamLeader,
  );
}

@JsonSerializable(createToJson: false, converters: [_IntegerConverter()])
class ConcertRecruitmentDto {
  const ConcertRecruitmentDto({
    required this.recruitPostId,
    required this.status,
    required this.deadline,
    required this.joinedTeamCount,
    required this.recruitTeamCount,
    required this.newInquiryCount,
  });

  factory ConcertRecruitmentDto.fromJson(Map<String, dynamic> json) =>
      _$ConcertRecruitmentDtoFromJson(json);

  final int recruitPostId;
  @JsonKey(unknownEnumValue: RecruitmentStatus.unknown)
  final RecruitmentStatus status;
  final String deadline;
  final int joinedTeamCount;
  final int recruitTeamCount;
  final int newInquiryCount;

  ConcertRecruitment toModel() => ConcertRecruitment(
    recruitPostId: recruitPostId,
    status: status,
    deadline: deadline,
    joinedTeamCount: joinedTeamCount,
    recruitTeamCount: recruitTeamCount,
    newInquiryCount: newInquiryCount,
  );
}

/// 기본 num.toInt()는 소수를 절삭하므로 ID·버전·금액·개수 계약에 사용하지 않는다.
class _IntegerConverter implements JsonConverter<int, Object> {
  const _IntegerConverter();

  @override
  int fromJson(Object json) => json as int;

  @override
  Object toJson(int object) => object;
}
