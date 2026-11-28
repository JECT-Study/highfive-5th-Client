import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_component_tokens.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/show/calendar_day_cell.dart';
import '../../../../shared/widgets/show/calendar_week_row.dart';

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

String _two(int value) => value.toString().padLeft(2, '0');

String _apiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-${_two(date.day)}';

String _weekday(DateTime date) => _weekdays[date.weekday - DateTime.monday];

/// 날짜 입력칸 글자. [date]는 `yyyy-MM-dd`, 결과는 `2026.10.12 (월)`.
String concertDateLabel(String date) {
  final day = DateTime.parse(date);
  return '${day.year}.${_two(day.month)}.${_two(day.day)} (${_weekday(day)})';
}

/// 확인 팝업의 짧은 날짜. [date]는 `yyyy-MM-dd`, 결과는 `10.12(월)`.
String concertShortDateLabel(String date) {
  final day = DateTime.parse(date);
  return '${_two(day.month)}.${_two(day.day)}(${_weekday(day)})';
}

/// 공연 날짜를 고르는 달력 시트. 확인하면 고른 날짜(`yyyy-MM-dd`), 닫으면 null을 돌려준다.
///
/// 서울 기준 [today]보다 이전 날짜는 고를 수 없다. 단, 원래 날짜([originalDate])는 지났어도
/// 다시 고를 수 있다 (명세: 날짜를 바꾸지 않으면 지난 공연도 다른 정보를 고칠 수 있다).
Future<String?> showConcertDateSheet(
  BuildContext context, {
  required String? initialDate,
  required String? originalDate,
  required DateTime today,
}) {
  final width =
      MediaQuery.sizeOf(context).width -
      MediaQuery.paddingOf(context).horizontal;
  return showAppBottomSheet<String>(
    context,
    horizontalPadding:
        width >= 7 * CalendarDayCell.size + 2 * AppBottomSheetTokens.paddingX
        ? AppBottomSheetTokens.paddingX
        : AppSpacing.x1,
    // 짧은 화면에서는 달력만 스크롤하도록 시트 높이 안에 가둔다.
    builder: (_) => Flexible(
      child: _ConcertDateSheet(
        initialDate: initialDate,
        originalDate: originalDate,
        today: today,
      ),
    ),
  );
}

class _ConcertDateSheet extends StatefulWidget {
  const _ConcertDateSheet({
    required this.initialDate,
    required this.originalDate,
    required this.today,
  });

  final String? initialDate;
  final String? originalDate;
  final DateTime today;

  @override
  State<_ConcertDateSheet> createState() => _ConcertDateSheetState();
}

class _ConcertDateSheetState extends State<_ConcertDateSheet> {
  late String? _selected = widget.initialDate;
  late DateTime _month = _monthOf(
    _selected == null ? widget.today : DateTime.parse(_selected!),
  );
  bool _confirmed = false;

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  /// 고를 수 있는 가장 이른 달. 원래 날짜가 지났으면 그 달까지 돌아갈 수 있다.
  DateTime get _firstMonth {
    final today = _monthOf(widget.today);
    final original = widget.originalDate;
    if (original == null) return today;
    final originalMonth = _monthOf(DateTime.parse(original));
    return originalMonth.isBefore(today) ? originalMonth : today;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final selected = _selected;
    final firstOffset = _month.weekday - DateTime.monday;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final weeks = (firstOffset + days + 6) ~/ 7;

    Widget arrow({required bool previous}) {
      final enabled = previous
          ? _month.isAfter(_firstMonth)
          : !(_month.year == 9999 && _month.month == 12);
      return Material(
        color: colors.backgroundAlternative,
        shape: const CircleBorder(),
        child: AppIconButton(
          key: ValueKey(previous ? 'concertDate_previous' : 'concertDate_next'),
          tooltip: previous ? '이전 달' : '다음 달',
          icon: RotatedBox(
            quarterTurns: previous ? 0 : 2,
            child: const AppIcon(AppIcons.arrowBack),
          ),
          onPressed: enabled
              ? () => setState(
                  () => _month = DateTime(
                    _month.year,
                    _month.month + (previous ? -1 : 1),
                  ),
                )
              : null,
        ),
      );
    }

    return Column(
      key: const ValueKey('concertDate_sheet'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            key: const ValueKey('concertDate_scroll'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x2_5,
              children: [
                Row(
                  spacing: AppSpacing.x2_5,
                  children: [
                    Expanded(
                      child: Text(
                        '${_month.year}년 ${_month.month}월',
                        key: const ValueKey('concertDate_month'),
                        style: textStyles.title1Bold.copyWith(
                          color: colors.labelNormal,
                        ),
                      ),
                    ),
                    arrow(previous: true),
                    arrow(previous: false),
                  ],
                ),
                CalendarWeekRow(
                  days: [
                    for (final weekday in _weekdays)
                      // 빈 날짜 칸과 같은 폭에 요일을 가운데 둬 아래 날짜 칸과 줄을 맞춘다.
                      SizedBox(
                        height: AppSpacing.x5,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const CalendarDayCell.empty(),
                            Text(
                              weekday,
                              style: textStyles.body1Regular.copyWith(
                                color: colors.labelAssistive,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Column(
                  spacing: AppSpacing.x2,
                  children: [
                    for (var week = 0; week < weeks; week++)
                      CalendarWeekRow(
                        days: [
                          for (var column = 0; column < 7; column++)
                            if (week * 7 + column - firstOffset + 1
                                case final day when day >= 1 && day <= days)
                              _day(
                                context,
                                DateTime(_month.year, _month.month, day),
                              )
                            else
                              const CalendarDayCell.empty(),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x5),
        AppButton(
          key: const ValueKey('concertDate_confirm'),
          label: selected == null
              ? '날짜를 골라 주세요'
              : '${concertShortDateLabel(selected)} 선택',
          onPressed: selected == null
              ? null
              : () {
                  // 연타로 시트 아래 화면까지 닫지 않게 한 번만 돌려준다.
                  if (_confirmed) return;
                  _confirmed = true;
                  Navigator.of(context).pop(selected);
                },
        ),
      ],
    );
  }

  Widget _day(BuildContext context, DateTime date) {
    final apiDate = _apiDate(date);
    final enabled =
        !date.isBefore(widget.today) || apiDate == widget.originalDate;
    final cell = Semantics(
      label: '${date.year}년 ${date.month}월 ${date.day}일 ${_weekday(date)}요일',
      child: CalendarDayCell(
        key: ValueKey('concertDate_$apiDate'),
        date: '${date.day}',
        today: date == widget.today,
        selected: _selected == apiDate,
        onTap: enabled ? () => setState(() => _selected = apiDate) : null,
      ),
    );
    if (enabled) return cell;
    // 공통 날짜 칸에는 고를 수 없는 모양이 없어, 이 칸에서만 기본 글자색을 비활성 색으로 바꾼다.
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        extensions: [
          ...theme.extensions.values,
          context.colors.copyWith(labelStrong: context.colors.labelDisable),
        ],
      ),
      child: cell,
    );
  }
}
