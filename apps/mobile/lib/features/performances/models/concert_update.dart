import 'package:freezed_annotation/freezed_annotation.dart';

import 'concert_detail.dart';

part 'concert_update.freezed.dart';

/// `PUT /api/v1/concerts/{concertId}`로 보내는 전체 교체 값.
///
/// 보내지 않은 선택 값은 서버에서 미정(null)이 되므로 화면에 없는 값([region],
/// [posterImageUrl])도 상세의 값을 그대로 담는다. [version]은 수정 화면을 열 때 받은 상세의 값이다.
/// 날짜·시간은 상세와 같은 시간대 없는 문자열(`2026-12-20`, `19:00:00`)이다.
@freezed
abstract class ConcertUpdate with _$ConcertUpdate {
  const ConcertUpdate._();

  const factory ConcertUpdate({
    required String title,
    required List<String> genres,
    required int recruitTeamCount,
    required String? performDate,
    required String? startTime,
    required String? endTime,
    required String? place,
    required String? address,
    required String? region,
    required int? rentalFee,
    required String? posterImageUrl,
    required int version,
  }) = _ConcertUpdate;

  /// 상세를 바꾸지 않고 그대로 보낼 때의 값. 바뀐 항목과 저장 결과를 가려내는 기준이다.
  factory ConcertUpdate.fromDetail(ConcertDetail detail) => ConcertUpdate(
    title: detail.title,
    genres: detail.genres,
    recruitTeamCount: detail.recruitTeamCount,
    performDate: detail.performDate,
    startTime: detail.startTime,
    endTime: detail.endTime,
    place: detail.place,
    address: detail.address,
    region: detail.region,
    rentalFee: detail.rentalFee,
    posterImageUrl: detail.posterImageUrl,
    version: detail.version,
  );

  /// [version]을 빼고 같은 내용인지. 서버는 장르 중복을 하나로 합치고 시간을 `19:00`처럼
  /// 초 없이 돌려줄 수 있어, 장르는 집합으로·시간은 초까지 채워 비교한다.
  bool sameContentAs(ConcertUpdate other) =>
      title == other.title &&
      sameGenres(genres, other.genres) &&
      recruitTeamCount == other.recruitTeamCount &&
      performDate == other.performDate &&
      sameConcertTime(startTime, other.startTime) &&
      sameConcertTime(endTime, other.endTime) &&
      place == other.place &&
      address == other.address &&
      region == other.region &&
      rentalFee == other.rentalFee &&
      posterImageUrl == other.posterImageUrl;
}

/// 순서·중복과 상관없이 같은 장르 코드들인지.
bool sameGenres(List<String> a, List<String> b) {
  final left = a.toSet();
  final right = b.toSet();
  return left.length == right.length && left.containsAll(right);
}

/// `19:00`과 `19:00:00`은 같은 시각이다. 서버 LocalTime 문자열의 생략된 초를 채워 비교한다.
bool sameConcertTime(String? a, String? b) =>
    _withSeconds(a) == _withSeconds(b);

String? _withSeconds(String? time) =>
    time != null && time.length == 5 ? '$time:00' : time;
