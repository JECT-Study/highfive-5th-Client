import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/widgets/show/calendar_day_cell.dart';
import '../../../../../shared/widgets/show/calendar_week_row.dart';
import '../../../../../shared/widgets/show/deposit_check_card.dart';
import '../../../../../shared/widgets/show/image_input.dart';
import '../../../../../shared/widgets/show/location_list_item.dart';
import '../../../../../shared/widgets/show/show_header.dart';
import 'gallery_item.dart';

/// 컴포넌트 모음의 `shared/widgets/show/` 일부: 달력 칸·한 주 줄, 이미지 입력, 장소 줄, 입금 확인, 공연 머리.
class ShowScheduleTicketGallerySection extends StatefulWidget {
  const ShowScheduleTicketGallerySection({super.key});

  @override
  State<ShowScheduleTicketGallerySection> createState() =>
      _ShowScheduleTicketGallerySectionState();
}

class _ShowScheduleTicketGallerySectionState
    extends State<ShowScheduleTicketGallerySection> {
  int? _selectedDay;
  final _checked = <DepositCheckStatus>{};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryItem(
          code: 'CalendarDayCell',
          figma: '_Day (State = Default · Current · Selected · Current and Selected · Null)',
          child: Wrap(
            spacing: AppSpacing.x4,
            runSpacing: AppSpacing.x3,
            children: [
              for (final (caption, cell) in [
                ('Default', CalendarDayCell(date: '1', onTap: () {})),
                (
                  'Current',
                  CalendarDayCell(date: '1', today: true, onTap: () {}),
                ),
                (
                  'Selected',
                  CalendarDayCell(date: '1', selected: true, onTap: () {}),
                ),
                (
                  'Current and Selected',
                  CalendarDayCell(
                    date: '1',
                    today: true,
                    selected: true,
                    onTap: () {},
                  ),
                ),
                ('Null (.empty)', const CalendarDayCell.empty()),
              ])
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.x1,
                  children: [cell, GalleryCaption(caption)],
                ),
            ],
          ),
        ),
        GalleryItem(
          code: 'CalendarWeekRow',
          figma: '_Week (Null 2칸 + Current + Default 4칸, 눌러서 고르기)',
          child: CalendarWeekRow(
            days: [
              const CalendarDayCell.empty(),
              const CalendarDayCell.empty(),
              for (var day = 1; day <= 5; day++)
                CalendarDayCell(
                  date: '$day',
                  today: day == 1,
                  selected: _selectedDay == day,
                  onTap: () => setState(() => _selectedDay = day),
                ),
            ],
          ),
        ),
        GalleryItem(
          code: 'ImageInput',
          figma: 'InputImg',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('이미지를 고르면 상자를 이미지로 채우고 오른쪽 위에 지우기 버튼을 둔다'),
              ImageInput(
                title: '공연 포스터',
                placeholder: '포스터 이미지 추가',
                helperText: '모집 공고와 공연페이지의 대표 이미지로 보여요',
                changeLabel: '사진 변경',
                onTap: () {},
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'LocationListItem',
          figma: 'LocationList',
          child: LocationListItem(
            name: '홍대 놀이터',
            address: '서울 마포구 와우산로 00길',
            onTap: () {},
          ),
        ),
        GalleryItem(
          code: 'DepositCheckCard',
          figma: '입금확인 (Property 1 = 확인완료 · 미확인 · 미입금 · 취소신청)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              for (final (status, figmaName, tag, action) in [
                (DepositCheckStatus.confirmed, '확인완료', '입금 확인', '확인 취소'),
                (DepositCheckStatus.unconfirmed, '미확인', null, '입금 확인'),
                (DepositCheckStatus.unpaid, '미입금', '미입금', '티켓 취소'),
                (DepositCheckStatus.cancelRequested, '취소신청', '미입금', '티켓 취소'),
              ]) ...[
                GalleryCaption('Property 1 = $figmaName'),
                DepositCheckCard(
                  status: status,
                  name: '정우성',
                  amount: '30,000원',
                  details: const ['신청자 정우성', '4321'],
                  tagLabel: tag,
                  deadlineLabel: status == DepositCheckStatus.unconfirmed
                      ? '5시간 후 자동 취소'
                      : null,
                  actionLabel: action,
                  onAction: () {},
                  checked: _checked.contains(status),
                  onCheckedChanged: (checked) => setState(() {
                    if (checked) {
                      _checked.add(status);
                    } else {
                      _checked.remove(status);
                    }
                  }),
                ),
              ],
            ],
          ),
        ),
        GalleryItem(
          code: 'ShowHeader · ShowHeaderInfoRow',
          figma: 'Header (Property 1 = false · true)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('Property 1 = false (ShowHeader)'),
              const ShowHeader(
                title: '소음공장 합동공연',
                statusLabel: '팀 모집 전',
                dDayLabel: 'D - 30',
                genres: ['록', '인디'],
                infoTitle: '공연 정보',
                infoRows: [
                  ShowHeaderInfoRow(label: '날짜', value: '2026.10.12 (월)'),
                  ShowHeaderInfoRow(label: '시간', value: '미정', pending: true),
                  ShowHeaderInfoRow(
                    label: '장소',
                    value: '미정',
                    pending: true,
                    detail: '서울 마포구',
                  ),
                ],
              ),
              const GalleryCaption('Property 1 = true (ShowHeader.compact)'),
              ShowHeader.compact(
                title: '소음공장 합동공연',
                statusLabel: '티켓 판매 중',
                dDayLabel: 'D - 10',
                genres: const ['록', '인디'],
                editLabel: '정보 수정',
                onEdit: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
