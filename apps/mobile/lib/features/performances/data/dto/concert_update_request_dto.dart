import 'package:json_annotation/json_annotation.dart';

import '../../models/concert_update.dart';

part 'concert_update_request_dto.g.dart';

/// `PUT /api/v1/concerts/{concertId}` 요청 본문 (Swagger `ConcertUpdateRequest`).
/// 전체 교체라 보내지 않은 선택 값은 서버에서 null이 된다. 그래서 null도 키를 빼지 않고 보낸다.
@JsonSerializable(createFactory: false, includeIfNull: true)
class ConcertUpdateRequestDto {
  const ConcertUpdateRequestDto({
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
    required this.version,
  });

  factory ConcertUpdateRequestDto.fromModel(ConcertUpdate update) =>
      ConcertUpdateRequestDto(
        title: update.title,
        genres: update.genres,
        recruitTeamCount: update.recruitTeamCount,
        performDate: update.performDate,
        startTime: update.startTime,
        endTime: update.endTime,
        place: update.place,
        address: update.address,
        region: update.region,
        rentalFee: update.rentalFee,
        posterImageUrl: update.posterImageUrl,
        version: update.version,
      );

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
  final int version;

  Map<String, dynamic> toJson() => _$ConcertUpdateRequestDtoToJson(this);
}
