import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Figma `_Day` (show). 달력의 날짜 한 칸: 보통·오늘(Current)·선택(Selected)·오늘이면서 선택·빈 칸(Null).
///
/// 오늘은 [today], 고른 날은 [selected]로 알리고 둘을 함께 줄 수 있다(Figma `Current and Selected`).
/// 어느 날을 고를지는 쓰는 쪽(ViewModel)이 정하고, 이 위젯은 눌림만 [onTap]으로 알린다.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required String this.date,
    this.today = false,
    this.selected = false,
    this.hasEvent = false,
    this.onTap,
  });

  /// Figma `Null`. 이번 달이 아닌 날의 빈 자리.
  const CalendarDayCell.empty({super.key})
    : date = null,
      today = false,
      selected = false,
      hasEvent = false,
      onTap = null;

  static const _size = 44.0; // Figma: Day 44 × 44 (누르는 영역도 44)
  static const _eventSize = 4.0;
  static const _eventTop = 32.0;

  /// 날짜 숫자. 빈 칸이면 null.
  final String? date;
  final bool today;
  final bool selected;

  /// V3 `일정있음`(1959:19911). 오늘·선택 상태와 별개로 일정 점을 보인다.
  final bool hasEvent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date = this.date;
    if (date == null) return const SizedBox.square(dimension: _size);

    final colors = context.colors;
    final textStyles = context.textStyles;
    // Figma: 고른 날은 원을 깔고 굵게, 오늘은 분홍 글자. 오늘이면서 고른 날은 진한 분홍 원에 흰 글자.
    final (circle, text) = switch ((today, selected)) {
      (true, true) => (
        colors.pink600,
        textStyles.title1Bold.copyWith(color: colors.staticWhite),
      ),
      (false, true) => (
        colors.pink50,
        textStyles.title1Bold.copyWith(color: colors.pink700),
      ),
      (true, false) => (
        null,
        textStyles.title1Regular.copyWith(color: colors.pink700),
      ),
      (false, false) => (
        null,
        textStyles.title1Regular.copyWith(color: colors.labelStrong),
      ),
    };

    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: selected,
      value: hasEvent ? '일정 있음' : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: _size,
          height: _size,
          alignment: Alignment.center,
          decoration: circle == null
              ? null
              : BoxDecoration(color: circle, shape: BoxShape.circle),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(child: Text(date, maxLines: 1, style: text)),
              if (hasEvent)
                Positioned(
                  top: _eventTop,
                  left: (_size - _eventSize) / 2 + 1,
                  child: Container(
                    key: const ValueKey('calendarDay_event'),
                    width: _eventSize,
                    height: _eventSize,
                    decoration: BoxDecoration(
                      color: today && selected
                          ? colors.staticWhite
                          : colors.labelNormal,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
