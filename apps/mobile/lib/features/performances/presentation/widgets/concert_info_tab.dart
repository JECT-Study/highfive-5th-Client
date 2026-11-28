import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/show/show_header.dart';
import '../../models/concert_detail.dart';
import 'concert_participants_preview.dart';
import 'concert_section.dart';

/// 합동공연 페이지의 정보 탭 (Figma `정보탭_*`, 2217:122814·2217:123232).
/// 지금은 공연 날짜·시간·장소와 참여 밴드 이름만 보인다.
/// 모집 현황·주소·대관비·참여 밴드 프로필은 JECT-152가, 라인업은 JECT-165가 채운다.
class ConcertInfoTab extends StatelessWidget {
  const ConcertInfoTab({super.key, required this.detail});

  final ConcertDetail detail;

  @override
  Widget build(BuildContext context) {
    final date = formatLocalDate(detail.performDate);
    final time = _timeRange(detail.startTime, detail.endTime);
    final place = detail.place;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            ],
          ),
        ),
        ConcertParticipantsPreview(concertId: detail.concertId),
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
