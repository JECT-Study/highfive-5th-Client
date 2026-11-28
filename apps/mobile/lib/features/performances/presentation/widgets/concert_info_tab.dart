import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/show/show_header.dart';
import '../../models/concert_detail.dart';
import '../../models/concert_status.dart';
import '../../models/recruitment_status.dart';
import 'concert_participants_preview.dart';
import 'concert_recruitment_overview.dart';
import 'concert_section.dart';

/// 합동공연 페이지의 정보 탭 (Figma `정보탭_*`, 2217:122814·2217:123232).
/// 모집 요약·공연 정보·참여 밴드를 보인다. 순서 변경·셋리스트는 라인업 기능이 다룬다.
class ConcertInfoTab extends StatelessWidget {
  const ConcertInfoTab({super.key, required this.detail, this.onBandTap});

  final ConcertDetail detail;
  final ValueChanged<int>? onBandTap;

  // Figma: 정보 줄의 이름 칸 40 + 간격 12. 주소도 오른쪽 값과 같은 곳에서 시작한다.
  static const _valueInset = 40.0 + AppSpacing.x3;

  @override
  Widget build(BuildContext context) {
    final date = formatLocalDate(detail.performDate);
    final time = _timeRange(detail.startTime, detail.endTime);
    final place = detail.place;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (detail.recruitment case final recruitment?)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.x5),
            child: ConcertRecruitmentOverview(
              recruitment: recruitment,
              concertStatus: detail.status,
            ),
          ),
        ConcertSection(
          title: '공연 정보',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x2_5,
            children: [
              ShowHeaderInfoRow(
                label: '날짜',
                value: date ?? _undecided,
                pending: date == null,
              ),
              ShowHeaderInfoRow(
                label: '시간',
                value: time ?? _undecided,
                pending: time == null,
              ),
              ShowHeaderInfoRow(
                label: '장소',
                value: place ?? _undecided,
                pending: place == null,
              ),
              if (detail.address case final address?)
                Padding(
                  padding: const EdgeInsets.only(left: _valueInset),
                  child: Text(
                    address,
                    style: context.textStyles.caption1Regular.copyWith(
                      color: context.colors.labelAlternative,
                    ),
                  ),
                ),
              if (detail.rentalFee case final fee?)
                ShowHeaderInfoRow(
                  label: '대관비',
                  value:
                      '${fee.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (match) => '${match[1]},')}원',
                ),
            ],
          ),
        ),
        ConcertParticipantsPreview(
          concertId: detail.concertId,
          recruitTeamCount: detail.recruitTeamCount,
          recruiting:
              detail.status == ConcertStatus.recruiting &&
              detail.recruitment?.status == RecruitmentStatus.recruiting,
          onBandTap: onBandTap,
        ),
      ],
    );
  }
}

/// Figma: 정해지지 않은 값.
const _undecided = '미정';

/// 시작·종료가 모두 있으면 `19:00 – 21:00`(Figma 2217:123232), 시작만 있으면 시작 시간. 시작이 없으면 미정(null).
String? _timeRange(String? start, String? end) {
  final from = formatLocalTime(start);
  if (from == null) return null;
  final to = formatLocalTime(end);
  return to == null ? from : '$from – $to';
}
