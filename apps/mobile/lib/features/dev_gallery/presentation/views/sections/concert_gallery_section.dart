import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/theme/app_typography.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_chip.dart';
import '../../../../../shared/widgets/app_dialog.dart';
import '../../../../../shared/widgets/app_icon.dart';
import '../../../../../shared/widgets/app_notice.dart';
import '../../../../../shared/widgets/app_stepper.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/qr/qr_list_card.dart';
import '../../../../../shared/widgets/show/calendar_day_cell.dart';
import '../../../../../shared/widgets/show/show_progress_card.dart';
import '../../../../../shared/widgets/show/show_stat_summary.dart';
import 'gallery_item.dart';

/// COMPONENT V3 기준의 실제 입력·선택·다이얼로그 예시. 테마는 각 미리보기 안에서만 바뀐다.
class ConcertGallerySection extends StatelessWidget {
  const ConcertGallerySection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: AppSpacing.x8,
    children: [
      for (final dark in [false, true])
        Theme(
          data: dark ? AppTheme.concertDark : AppTheme.light,
          child: _ConcertPreview(
            key: ValueKey(
              dark ? 'concert_gallery_dark' : 'concert_gallery_light',
            ),
            dark: dark,
          ),
        ),
    ],
  );
}

class _ConcertPreview extends StatefulWidget {
  const _ConcertPreview({super.key, required this.dark});

  final bool dark;

  @override
  State<_ConcertPreview> createState() => _ConcertPreviewState();
}

class _ConcertPreviewState extends State<_ConcertPreview> {
  final _venue = TextEditingController(text: '홍대 놀이터');
  final _search = TextEditingController(text: '소음공장');
  int _genre = 0;
  int _date = 12;
  int _teams = 3;
  String? _result;

  static const _summary = [
    (label: '신청 금액', value: '30,000원 (2매)'),
    (label: '입금자명', value: '정우성'),
    (label: '취소 요청', value: '10.16'),
  ];

  @override
  void dispose() {
    _venue.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _openDialog() async {
    final result = await showAppDialog(
      context,
      title: '공연 정보를 변경할까요?',
      message: '변경 내용을 확인해 주세요.',
      confirmLabel: '변경하기',
      cancelLabel: '취소',
      notice: AppNotice(
        message: '참여 팀에게 변경 내용을 알려요.',
        textStyle: context.textStyles.caption1Regular.copyWith(
          height: 1.2,
          color: context.colors.labelAlternative,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
      ),
      content: const QrListCard.summary(rows: _summary),
    );
    if (mounted) {
      setState(() => _result = result == true ? '확인 결과 반환' : '취소 결과 반환');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.backgroundNormal,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.dark ? '공연 다크 · 명시적 범위' : '기존 라이트',
              style: context.textStyles.title1Bold.copyWith(
                color: colors.labelNormal,
              ),
            ),
            const SizedBox(height: AppSpacing.x6),
            GalleryItem(
              code: 'AppTextField · 보조행',
              figma: 'Input / Fill/서브텍스트 · 1959:20282',
              web: 'TextField subtext',
              child: AppTextField(
                controller: _venue,
                subtext: '서울 마포구 와우산로',
                suffix: const RotatedBox(
                  quarterTurns: 2,
                  child: AppIcon(AppIcons.chevronLeft, size: 16),
                ),
              ),
            ),
            GalleryItem(
              code: 'AppTextField · 2Fill',
              figma: 'Input / 2Fill · 1701:13048',
              web: 'TextField variant=search + prefix/suffix',
              child: AppTextField(
                controller: _search,
                variant: AppTextFieldVariant.search,
                prefix: const AppIcon(AppIcons.search),
                suffix: Semantics(
                  button: true,
                  label: '검색어 지우기',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _search.clear,
                    child: const AppIcon(AppIcons.deleteFill, size: 20),
                  ),
                ),
              ),
            ),
            GalleryItem(
              code: 'AppChip · AppStepper',
              figma: '공연 장르·모집 팀 수 · 2217:123929',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.x3,
                children: [
                  Wrap(
                    spacing: AppSpacing.x2,
                    runSpacing: AppSpacing.x2,
                    children: [
                      for (final (i, genre) in ['록', '인디', '메탈', '펑크'].indexed)
                        AppChip(
                          label: genre,
                          selected: _genre == i,
                          onTap: () => setState(() => _genre = i),
                        ),
                    ],
                  ),
                  AppStepper(
                    valueLabel: '$_teams팀',
                    onDecrement: _teams == 1
                        ? null
                        : () => setState(() => _teams--),
                    onIncrement: _teams == 5
                        ? null
                        : () => setState(() => _teams++),
                  ),
                ],
              ),
            ),
            GalleryItem(
              code: 'CalendarDayCell · 일정',
              figma: '_Day / 일정있음 · 1959:19911',
              child: Wrap(
                children: [
                  for (var date = 12; date <= 16; date++)
                    CalendarDayCell(
                      date: '$date',
                      today: date == 12,
                      selected: _date == date,
                      hasEvent: date.isEven,
                      onTap: () => setState(() => _date = date),
                    ),
                ],
              ),
            ),
            const GalleryItem(
              code: 'QrListCard.summary',
              figma: 'SummaryBox · 2014:19752',
              web: 'SummaryBox',
              child: QrListCard.summary(rows: _summary),
            ),
            GalleryItem(
              code: 'AppDialog · Notice/내용 슬롯',
              figma: 'Dialog · 1681:12975',
              web: 'Dialog notice/content',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.x2,
                children: [
                  AppButton(label: '내용 슬롯 다이얼로그 열기', onPressed: _openDialog),
                  if (_result != null) GalleryCaption(_result!),
                ],
              ),
            ),
            for (final closed in [false, true])
              GalleryItem(
                code: closed ? 'ProgressCard · 판매 마감' : 'ProgressCard · 판매 중',
                figma: closed ? '2014:20680' : '2014:20681',
                child: ShowProgressCard(
                  stage: ShowProgressStage.ticketSales,
                  title: closed ? '티켓 판매가 마감됐어요' : '티켓을 판매하고 있어요',
                  stepLabel: '티켓 판매',
                  stepTrailingLabel: '2/3단계',
                  details: const ['신청 34명', '입금 확인 28명'],
                  info: const ShowStatSummary(
                    items: [
                      (label: '신청', value: '34명'),
                      (label: '입금 확인', value: '28명'),
                      (label: '남은 자리', value: '30석'),
                    ],
                  ),
                  actions: [
                    (
                      label: closed ? '판매 결과 확인' : '판매 안내 확인',
                      onPressed: _openDialog,
                      icon: null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
