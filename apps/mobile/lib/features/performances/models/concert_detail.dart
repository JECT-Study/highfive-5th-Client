import 'package:freezed_annotation/freezed_annotation.dart';

import 'concert_status.dart';
import 'recruitment_status.dart';

part 'concert_detail.freezed.dart';

/// `GET /api/v1/concerts/{concertId}`의 공연 전용 계약.
/// 날짜·시간은 시간대 없는 서버 문자열을 그대로 보존한다.
@freezed
abstract class ConcertDetail with _$ConcertDetail {
  const factory ConcertDetail({
    required int concertId,
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
    required ConcertStatus status,
    required int hostBandId,
    required List<int> myBandIds,
    required ConcertPermissions myPermissions,
    required ConcertRecruitment? recruitment,

    /// 수정 요청에 그대로 돌려보낼 낙관적 잠금 버전.
    required int version,
    required String updatedAt,
  }) = _ConcertDetail;
}

/// 서버가 응답한 두 권한만 사용한다. 밴드 ID나 공연 상태로 추정하지 않는다.
@freezed
abstract class ConcertPermissions with _$ConcertPermissions {
  const factory ConcertPermissions({
    required bool isHostLeader,
    required bool isTeamLeader,
  }) = _ConcertPermissions;
}

@freezed
abstract class ConcertRecruitment with _$ConcertRecruitment {
  const factory ConcertRecruitment({
    required int recruitPostId,
    required RecruitmentStatus status,
    required String deadline,
    required int joinedTeamCount,
    required int recruitTeamCount,
    required int newInquiryCount,
  }) = _ConcertRecruitment;
}
