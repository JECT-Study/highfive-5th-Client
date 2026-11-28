import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_component_tokens.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/show/calendar_day_cell.dart';
import '../../../../shared/widgets/show/calendar_week_row.dart';

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

String _apiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _weekday(DateTime date) => _weekdays[date.weekday - DateTime.monday];

/// 원본 API 문자열은 건드리지 않고 표시만 바꾼다.
class ConcertDateInput extends StatelessWidget {
  const ConcertDateInput({super.key, required this.value, required this.onTap});

  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date = value == null ? null : DateTime.parse(value!);
    final label = date == null
        ? '날짜 미정'
        : '${_apiDate(date).replaceAll('-', '.')} (${_weekday(date)})';
    final colors = context.colors;
    return Semantics(
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      label: '공연 날짜',
      value: label,
      child: ExcludeSemantics(
        child: Material(
          color: colors.inverseBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: AppInputTokens.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3_5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: context.textStyles.body1Regular.copyWith(
                          color: colors.inverseLabel,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: AppSpacing.x6,
                      color: colors.labelAlternative,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// null 반환은 닫기, (date: null)은 사용자가 확인한 미정이다.
/// initialMonth는 '미정'으로 바꾸려는 경우에도 기존 공연 월을 유지한다.
Future<({String? date})?> showConcertDateSheet(
  BuildContext context, {
  required String? initialDate,
  required String? originalDate,
  required DateTime today,
  DateTime? initialMonth,
}) => showModalBottomSheet<({String? date})>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colors.backgroundNormal,
  barrierColor: context.colors.materialDimmer,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
  ),
  builder: (context) => _ConcertDateSheet(
    initialDate: initialDate,
    initialMonth: initialMonth,
    today: today,
    originalDate: originalDate,
  ),
);

class _ConcertDateSheet extends StatefulWidget {
  const _ConcertDateSheet({
    required this.initialDate,
    required this.initialMonth,
    required this.today,
    required this.originalDate,
  });

  final String? initialDate;
  final DateTime? initialMonth;
  final DateTime today;
  final String? originalDate;

  @override
  State<_ConcertDateSheet> createState() => _ConcertDateSheetState();
}

class _ConcertDateSheetState extends State<_ConcertDateSheet> {
  late DateTime? _selected = widget.initialDate == null
      ? null
      : DateTime.parse(widget.initialDate!);
  late DateTime _month = DateTime(
    (_selected ?? widget.initialMonth ?? widget.today).year,
    (_selected ?? widget.initialMonth ?? widget.today).month,
  );
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final firstOffset = _month.weekday - DateTime.monday;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final rows = (firstOffset + days + 6) ~/ 7;
    final today = DateTime(
      widget.today.year,
      widget.today.month,
      widget.today.day,
    );
    final selected = _selected;
    final label = selected == null
        ? '미정으로 설정'
        : '${selected.month.toString().padLeft(2, '0')}.'
              '${selected.day.toString().padLeft(2, '0')} (${_weekday(selected)}) 선택';

    Widget arrow(bool previous) => Material(
      color: colors.backgroundAlternative,
      shape: const CircleBorder(),
      child: AppIconButton(
        key: ValueKey(previous ? 'concertDate_previous' : 'concertDate_next'),
        tooltip: previous ? '이전 달' : '다음 달',
        icon: RotatedBox(
          quarterTurns: previous ? 0 : 2,
          child: const AppIcon(AppIcons.arrowBack),
        ),
        onPressed:
            (previous && _month.year == 1 && _month.month == 1) ||
                (!previous && _month.year == 9999 && _month.month == 12)
            ? null
            : () => setState(() {
                _month = DateTime(
                  _month.year,
                  _month.month + (previous ? -1 : 1),
                );
              }),
      ),
    );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.x5),
      child: Padding(
        key: const ValueKey('concertDate_sheet'),
        padding: const EdgeInsets.only(top: AppSpacing.x3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppSpacing.x5 * 2,
                height: AppSpacing.x1,
                decoration: BoxDecoration(
                  color: colors.lineStrong,
                  borderRadius: BorderRadius.circular(AppSpacing.x0_5),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x5),
            Flexible(
              child: SingleChildScrollView(
                key: const ValueKey('concertDate_scroll'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_month.year}년 ${_month.month}월',
                              key: const ValueKey('concertDate_month'),
                              style: context.textStyles.title1Bold,
                            ),
                          ),
                          arrow(true),
                          const SizedBox(width: AppSpacing.x2_5),
                          arrow(false),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2_5),
                    CalendarWeekRow(
                      days: [
                        for (final weekday in _weekdays)
                          SizedBox(
                            width: AppSpacing.x8 + AppSpacing.x3,
                            height: AppSpacing.x5,
                            child: Center(
                              child: Text(
                                weekday,
                                style: context.textStyles.body1Regular.copyWith(
                                  color: colors.labelAssistive,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // 기존 공통 날짜 칸을 이 밝은 시트 안에서만 회색 선택 상태로 쓴다.
                    Theme(
                      data: Theme.of(context).copyWith(
                        extensions: [
                          ...Theme.of(context).extensions.values,
                          colors.copyWith(
                            pink50: colors.fillStrong,
                            pink700: colors.labelAlternative,
                          ),
                        ],
                      ),
                      child: Column(
                        spacing: AppSpacing.x2,
                        children: [
                          for (var week = 0; week < rows; week++)
                            CalendarWeekRow(
                              days: [
                                for (var column = 0; column < 7; column++)
                                  if (week * 7 + column - firstOffset + 1
                                      case final day
                                      when day >= 1 && day <= days)
                                    Builder(
                                      builder: (context) {
                                        final date = DateTime(
                                          _month.year,
                                          _month.month,
                                          day,
                                        );
                                        final apiDate = _apiDate(date);
                                        final enabled =
                                            !date.isBefore(today) ||
                                            apiDate == widget.originalDate;
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            extensions: [
                                              ...Theme.of(context)
                                                  .extensions
                                                  .values,
                                              Theme.of(context)
                                                  .extension<AppColors>()!
                                                  .copyWith(
                                                    labelStrong: enabled
                                                        ? colors.labelStrong
                                                        : colors.labelDisable,
                                                  ),
                                            ],
                                          ),
                                          child: Semantics(
                                            label:
                                                '${date.year}년 ${date.month}월 $day일 ${_weekday(date)}요일',
                                            child: CalendarDayCell(
                                              key: ValueKey(
                                                'concertDate_$apiDate',
                                              ),
                                              date: '$day',
                                              selected:
                                                  selected != null &&
                                                  _apiDate(selected) == apiDate,
                                              onTap: enabled
                                                  ? () => setState(
                                                      () => _selected = date,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  else
                                    const CalendarDayCell.empty(),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5,
                AppSpacing.x5,
                AppSpacing.x5,
                0,
              ),
              child: AppButton(
                key: const ValueKey('concertDate_confirm'),
                label: label,
                onPressed: () {
                  if (_confirmed) return;
                  _confirmed = true;
                  Navigator.of(
                    context,
                  ).pop((date: selected == null ? null : _apiDate(selected)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
