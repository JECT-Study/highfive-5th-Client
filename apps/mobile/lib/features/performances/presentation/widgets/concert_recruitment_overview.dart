import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/show/show_progress_card.dart';
import '../../models/concert_detail.dart';
import '../../models/concert_status.dart';
import '../../models/recruitment_status.dart';

/// 공연 상세의 모집 공고 요약. 공고 기능이 연결되기 전까지 조회 값만 보인다.
/// Figma `ProgressCard`(2217:123232)를 재사용하되 도착 화면이 없는 버튼은 만들지 않는다.
class ConcertRecruitmentOverview extends StatelessWidget {
  const ConcertRecruitmentOverview({
    super.key,
    required this.recruitment,
    required this.concertStatus,
  });

  final ConcertRecruitment recruitment;
  final ConcertStatus concertStatus;

  @override
  Widget build(BuildContext context) {
    final joined = recruitment.joinedTeamCount;
    final remaining = math.max(0, recruitment.recruitTeamCount - joined);
    // API의 joinedTeamCount는 주최 팀을 제외한다.
    final confirmed = joined + 1;
    final title = switch (recruitment.status) {
      RecruitmentStatus.recruiting
          when remaining > 0 && concertStatus == ConcertStatus.recruiting =>
        '$confirmed팀 확정, $remaining팀 더 모집 중',
      RecruitmentStatus.closed => '$confirmed팀 확정, 모집 마감',
      RecruitmentStatus.recruiting ||
      RecruitmentStatus.unknown => '$confirmed팀 확정',
    };
    final deadline = formatLocalDate(recruitment.deadline);
    return ShowProgressCard(
      stage: switch (concertStatus) {
        ConcertStatus.beforeRecruit ||
        ConcertStatus.unknown => ShowProgressStage.beforeRecruit,
        ConcertStatus.recruiting => ShowProgressStage.recruiting,
        ConcertStatus.selling ||
        ConcertStatus.salePaused ||
        ConcertStatus.saleClosed => ShowProgressStage.ticketSales,
      },
      title: title,
      // 날짜 자체를 보여 주므로 앱을 켜 둔 채 자정이 지나도 오래된 D-day가 남지 않는다.
      description: deadline == null ? null : '공고 마감 $deadline',
      details: [
        if (recruitment.newInquiryCount > 0)
          '새 문의 ${recruitment.newInquiryCount}건',
      ],
    );
  }
}
