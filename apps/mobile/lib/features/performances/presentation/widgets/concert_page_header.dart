import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/show/show_header.dart';
import '../../models/concert_detail.dart';
import '../../models/concert_status.dart';
import '../../models/concert_genre_label.dart';

/// 합동공연 페이지 위쪽 머리 (Figma `Header` Property 1 = true, 2217:122770).
/// 공연 상세를 [ShowHeader.compact]의 값으로 옮긴다. 정보 수정 버튼은 [onEdit]이 없으면 비활성이다.
/// D-day는 앱으로 돌아올 때와 자정에 다시 센다. 화면을 켜 둔 채 날짜가 바뀌어도 어제 값이 남지 않는다.
class ConcertPageHeader extends StatefulWidget {
  const ConcertPageHeader({
    super.key,
    required this.detail,
    required this.onEdit,
    this.clock,
  });

  final ConcertDetail detail;
  final VoidCallback? onEdit;

  /// 지금 시각. 없으면 기기 시각이다. 테스트·골든에서 날짜를 정할 때만 넘긴다.
  final DateTime Function()? clock;

  @override
  State<ConcertPageHeader> createState() => _ConcertPageHeaderState();
}

class _ConcertPageHeaderState extends State<ConcertPageHeader> {
  late DateTime _today;
  late final AppLifecycleListener _lifecycle;
  Timer? _midnight;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _today = _now();
    _lifecycle = AppLifecycleListener(onResume: _refreshToday);
    _scheduleMidnight();
  }

  @override
  void dispose() {
    _midnight?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  void _refreshToday() {
    setState(() => _today = _now());
    _midnight?.cancel();
    _scheduleMidnight();
  }

  void _scheduleMidnight() {
    final now = _now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(nextMidnight.difference(now), _refreshToday);
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final posterUrl = detail.posterImageUrl;
    final daysLeft = daysUntilLocalDate(detail.performDate, _today);
    return ShowHeader.compact(
      title: detail.title,
      statusLabel: _statusLabel(detail.status),
      // Figma `D - 30`. 공연 당일·지난 공연의 표기는 시안에 없어 보이지 않는다.
      dDayLabel: daysLeft != null && daysLeft > 0 ? 'D - $daysLeft' : null,
      genres: detail.genres.map(concertGenreLabel).nonNulls.toList(),
      poster: posterUrl == null ? null : NetworkImage(posterUrl),
      editLabel: '정보 수정',
      onEdit: widget.onEdit,
    );
  }
}

/// 공연 GET 초안의 상태 설명 그대로다. 앱이 모르는 새 상태는 태그를 보이지 않는다.
String? _statusLabel(ConcertStatus status) => switch (status) {
  ConcertStatus.beforeRecruit => '팀 모집 전',
  ConcertStatus.recruiting => '팀 모집 중',
  ConcertStatus.selling => '티켓 판매 중',
  ConcertStatus.salePaused => '판매 중지',
  ConcertStatus.saleClosed => '판매 마감',
  ConcertStatus.unknown => null,
};
