import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'calendar_day_cell.dart';

/// Figma `_Week` (show). 달력의 한 주 줄: 날짜 칸 7개를 양 끝에 맞춰 고르게 늘어놓는다.
///
/// [days]에는 보통 `CalendarDayCell` 7개(일~토)를 넣고, 이번 달이 아닌 날은 `CalendarDayCell.empty()`로 채운다.
class CalendarWeekRow extends StatelessWidget {
  const CalendarWeekRow({super.key, required this.days, this.padding});

  final List<Widget> days;

  /// 호출자가 여백을 지정하면 유지한다. 생략하면 44px 날짜 칸이 먼저 확보되도록 줄인다.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    // 누르는 영역 44를 먼저 확보하고 남는 폭에서 좌우 여백을 줄인다.
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal:
                  ((constraints.maxWidth - 7 * CalendarDayCell.size) / 2).clamp(
                    0,
                    AppSpacing.x4,
                  ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (final day in days) Flexible(child: day)],
        ),
      ),
    );
  }
}
