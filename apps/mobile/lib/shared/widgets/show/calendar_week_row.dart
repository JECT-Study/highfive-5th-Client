import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Figma `_Week` (show). 달력의 한 주 줄: 날짜 칸 7개를 양 끝에 맞춰 고르게 늘어놓는다.
///
/// [days]에는 보통 `CalendarDayCell` 7개(일~토)를 넣고, 이번 달이 아닌 날은 `CalendarDayCell.empty()`로 채운다.
class CalendarWeekRow extends StatelessWidget {
  const CalendarWeekRow({
    super.key,
    required this.days,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
  });

  final List<Widget> days;

  /// Figma `_Week`의 좌우 16. 이미 좌우 여백이 있는 곳(바텀시트 등)에서는 `EdgeInsets.zero`를 넘겨 칸 폭을 넓힌다.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // Figma justify-between. 폭이 좁으면(320) 칸이 44보다 줄어들어 넘치지 않는다.
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [for (final day in days) Flexible(child: day)],
      ),
    );
  }
}
