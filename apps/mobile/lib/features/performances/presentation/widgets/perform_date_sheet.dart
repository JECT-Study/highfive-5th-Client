import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/show/calendar_day_cell.dart';
import '../../../../shared/widgets/show/calendar_week_row.dart';

/// 공연 날짜를 고르는 시트를 띄운다. 고른 날짜(시각 없음)를 돌려주고, 그냥 닫으면 null.
///
/// 명세 없음: 생성 화면 Figma에 날짜 선택 시안이 없어 공통 바텀시트와 달력 컴포넌트(`_Week`·`_Day`)로 만들었다.
/// 앱에 한국어 Material 지역화가 없어 `showDatePicker`는 영어로 보이므로 쓰지 않는다.
/// 오늘보다 이전인 [initialDate]는(예: 자정이 지난 뒤 다시 열기) 고르지 않은 것으로 연다.
Future<DateTime?> showPerformDateSheet(
  BuildContext context, {
  required DateTime today,
  DateTime? initialDate,
}) => showAppBottomSheet<DateTime>(
  context,
  horizontalPadding: AppSpacing.x1,
  scrollable: true,
  builder: (_) => PerformDateSheet(today: today, initialDate: initialDate),
);

/// 공연 날짜 달력. 오늘보다 이전 날짜는 누를 수 없고, 이번 달보다 앞 달로는 가지 않는다.
class PerformDateSheet extends StatefulWidget {
  const PerformDateSheet({super.key, required this.today, this.initialDate});

  final DateTime today;
  final DateTime? initialDate;

  static const previousMonthKey = ValueKey('performDate_previousMonth');
  static const nextMonthKey = ValueKey('performDate_nextMonth');
  static const confirmKey = ValueKey('performDate_confirm');
  static ValueKey<String> dayKey(DateTime date) =>
      ValueKey('performDate_day_${date.year}-${date.month}-${date.day}');

  @override
  State<PerformDateSheet> createState() => _PerformDateSheetState();
}

class _PerformDateSheetState extends State<PerformDateSheet> {
  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  static const _dayCellSize = 44.0; // Figma `_Day`: 44 × 44, 요일 칸도 같은 폭

  late final DateTime _today = _dateOnly(widget.today);
  late DateTime? _selected = switch (widget.initialDate) {
    final date? when !_dateOnly(date).isBefore(_today) => _dateOnly(date),
    _ => null,
  };
  late DateTime _month = _monthOf(_selected ?? _today);

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _monthOf(DateTime value) => DateTime(value.year, value.month);

  bool get _canGoBack => _month.isAfter(_monthOf(_today));

  void _moveMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  /// 일요일부터 시작하는 주 단위 칸. 이번 달이 아닌 자리는 null.
  List<List<DateTime?>> _weeks() {
    final leading = _month.weekday % DateTime.daysPerWeek; // 일요일 = 0
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final cells = <DateTime?>[
      for (var i = 0; i < leading; i++) null,
      for (var day = 1; day <= days; day++)
        DateTime(_month.year, _month.month, day),
    ];
    while (cells.length % DateTime.daysPerWeek != 0) {
      cells.add(null);
    }
    return [
      for (var i = 0; i < cells.length; i += DateTime.daysPerWeek)
        cells.sublist(i, i + DateTime.daysPerWeek),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final selected = _selected;

    Widget monthButton(
      Key key,
      IconData icon,
      String tooltip, {
      required int delta,
      required bool enabled,
    }) => IconButton(
      key: key,
      onPressed: enabled ? () => _moveMonth(delta) : null,
      tooltip: tooltip,
      icon: Icon(icon),
      color: colors.labelNormal,
      disabledColor: colors.labelAssistive,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x4,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.x4),
          child: AppModalHeader(title: '공연 날짜'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
          child: Row(
            children: [
              monthButton(
                PerformDateSheet.previousMonthKey,
                Icons.chevron_left,
                '이전 달',
                delta: -1,
                enabled: _canGoBack,
              ),
              Expanded(
                child: Text(
                  '${_month.year}년 ${_month.month}월',
                  textAlign: TextAlign.center,
                  style: textStyles.title2Bold.copyWith(
                    color: colors.labelNormal,
                  ),
                ),
              ),
              monthButton(
                PerformDateSheet.nextMonthKey,
                Icons.chevron_right,
                '다음 달',
                delta: 1,
                enabled: true,
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 달력은 좌우 4만 남긴다. 폭 320에서도 7 × 44 터치 영역을 확보한다.
            CalendarWeekRow(
              padding: EdgeInsets.zero,
              days: [
                for (final weekday in _weekdays)
                  SizedBox(
                    width: _dayCellSize,
                    child: Text(
                      weekday,
                      textAlign: TextAlign.center,
                      style: textStyles.caption1Regular.copyWith(
                        color: colors.labelAlternative,
                      ),
                    ),
                  ),
              ],
            ),
            for (final week in _weeks())
              CalendarWeekRow(
                padding: EdgeInsets.zero,
                days: [
                  for (final date in week)
                    if (date == null)
                      const CalendarDayCell.empty()
                    else
                      CalendarDayCell(
                        key: PerformDateSheet.dayKey(date),
                        date: '${date.day}',
                        today: date == _today,
                        selected: date == selected,
                        onTap: date.isBefore(_today)
                            ? null
                            : () => setState(() => _selected = date),
                      ),
                ],
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
          child: SizedBox(
            width: double.infinity,
            child: AppButton(
              key: PerformDateSheet.confirmKey,
              label: '선택 완료',
              onPressed: selected == null
                  ? null
                  : () => Navigator.of(context).pop(selected),
            ),
          ),
        ),
      ],
    );
  }
}
