import 'package:freezed_annotation/freezed_annotation.dart';

import 'concert_status.dart';

part 'my_concert.freezed.dart';

/// 마이페이지 '내 공연'·'공연 이력'에 보이는 공연 하나. 내 밴드가 주최하거나 참여하는 공연이다.
///
/// 명세 없음: 내 공연 목록 API가 아직 없다(Swagger·Notion 모두 없음). 카드가 쓰는 값만 두고,
/// 이름과 모양은 공연 페이지 조회(`GET /api/v1/concerts/{concertId}`) 응답을 따른다고 추정했다.
/// 날짜·시간은 공연 상세처럼 시간대 없는 서버 문자열을 그대로 둔다.
@freezed
abstract class MyConcert with _$MyConcert {
  const factory MyConcert({
    /// 명세 없음: 공연 ID. 카드를 누르면 이 공연의 페이지를 연다.
    required int concertId,

    /// 명세 없음: 공연 제목.
    required String title,

    /// 명세 없음: 공연 상태. 공연 페이지 조회와 같은 코드로 추정한다.
    required ConcertStatus status,

    /// 명세 없음: 공연 날짜(서버 `LocalDate`, 예: `2026-12-20`). null이면 미정.
    required String? performDate,

    /// 명세 없음: 시작 시각(서버 `LocalTime`, 예: `19:00:00`). null이면 미정.
    required String? startTime,

    /// 명세 없음: 카드에 보일 지역(예: `서울 마포구`). 주소가 없으면 공연장, 둘 다 없으면 null.
    required String? area,

    /// 명세 없음: 내 밴드가 이 공연의 주최 팀인지. 대표자 권한과는 따로 본다.
    required bool isHost,

    /// 명세 없음: 포스터 이미지 URL. null이면 회색 자리를 그린다.
    required String? posterImageUrl,
  }) = _MyConcert;
}
