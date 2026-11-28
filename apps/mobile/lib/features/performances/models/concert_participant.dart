import 'package:freezed_annotation/freezed_annotation.dart';

part 'concert_participant.freezed.dart';

/// 공연에 참여 중인 밴드 한 팀. 라인업 조회 초안(`GET /api/v1/concerts/{concertId}/lineup`)의
/// `teams[]`에서 참여 밴드 미리보기에 쓰는 값만 옮긴다. 공연 순서·셋리스트는 라인업 기능(JECT-165)이 다룬다.
@freezed
abstract class ConcertParticipant with _$ConcertParticipant {
  const factory ConcertParticipant({
    required int bandId,
    required String name,

    /// 주최 팀인지 (`teams[].isHost`). 대표자 권한(`ConcertPermissions`)과는 다르다.
    required bool isHost,
    String? profileImageUrl,
    @Default(<String>[]) List<String> genres,

    /// 이전의 최소 참여자 projection에는 없는 값. 모르면 0명으로 바꾸지 않고 숨긴다.
    int? memberCount,
  }) = _ConcertParticipant;
}
