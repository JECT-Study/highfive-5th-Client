import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/app_band_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_tag.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../models/concert_status.dart';
import '../../models/my_concert.dart';
import '../providers/my_concerts_providers.dart';
import '../view_models/my_concerts_view_model.dart';

/// 마이페이지 '내 활동' 탭의 '내 공연'(진행 중)과 '공연 이력'(지난 공연). Figma 2216:138534, 2216:138491.
///
/// 경로가 아니라 마이페이지의 한 부분이라 라우터가 `MyPageView`의 슬롯에 넣는다.
/// 이 섹션은 경로를 모르고, 이동은 [onOpenConcert]·[onAddConcert]로 넘긴다.
class MyConcertsSection extends ConsumerStatefulWidget {
  const MyConcertsSection({
    super.key,
    required this.onOpenConcert,
    this.onAddConcert,
  });

  /// 공연(진행 중 카드·이력 줄)을 누르면 그 공연 페이지를 연다. 페이지에서 돌아오면 목록을 다시 읽는다.
  final Future<void> Function(int concertId) onOpenConcert;

  /// '+ 공연 추가하기'. null이면 버튼이 비활성이다 (공연 만들기 화면이 앱에 아직 없을 때).
  final Future<void> Function()? onAddConcert;

  static const loadingKey = ValueKey('myConcerts_loading');
  static const failureKey = ValueKey('myConcerts_failure');
  static const emptyHistoryKey = ValueKey('myConcerts_emptyHistory');
  static ValueKey<String> cardKey(int concertId) =>
      ValueKey('myConcerts_card_$concertId');
  static ValueKey<String> historyKey(int concertId) =>
      ValueKey('myConcerts_history_$concertId');

  @override
  ConsumerState<MyConcertsSection> createState() => _MyConcertsSectionState();
}

class _MyConcertsSectionState extends ConsumerState<MyConcertsSection> {
  late final AppLifecycleListener _lifecycle;
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    _scheduleMidnight();
  }

  @override
  void dispose() {
    _midnight?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = ref.read(myConcertsClockProvider)();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now), _refresh);
  }

  void _refresh() {
    ref.read(myConcertsViewModelProvider.notifier).refresh();
    _scheduleMidnight();
  }

  Future<void> _open(Future<void> Function() navigate) async {
    await navigate();
    // 상세 수정·새 공연 생성 뒤에도 목록을 다시 읽는다. 사라진 화면의 ref는 쓰지 않는다.
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final concerts = ref.watch(myConcertsViewModelProvider);
    final add = widget.onAddConcert;
    return concerts.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.x8),
        child: LoadingView(key: MyConcertsSection.loadingKey),
      ),
      error: (_, _) => ErrorView(
        key: MyConcertsSection.failureKey,
        message: '내 공연을 불러오지 못했어요. 다시 시도해 주세요.',
        actionLabel: '다시 시도',
        onAction: _refresh,
        loading: concerts.isLoading,
      ),
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x6,
        children: [
          _Section(
            title: '내 공연',
            children: [
              if (state.current.isEmpty)
                const AppBandEmptyCard(
                  title: '아직 참여 중인 공연이 없어요',
                  description: '공연을 만들어 함께할 팀을 모집해 보세요.',
                )
              else
                for (final concert in state.current)
                  _ConcertCard(
                    key: MyConcertsSection.cardKey(concert.concertId),
                    concert: concert,
                    daysLeft: state.daysUntil(concert),
                    onTap: () =>
                        _open(() => widget.onOpenConcert(concert.concertId)),
                  ),
              AppButton(
                label: '+ 공연 추가하기',
                variant: AppButtonVariant.weak,
                onPressed: add == null ? null : () => _open(add),
              ),
            ],
          ),
          _Section(
            title: '공연 이력',
            children: [
              if (state.past.isEmpty)
                const EmptyView.inline(
                  message: '아직 공연 이력이 없어요.',
                  key: MyConcertsSection.emptyHistoryKey,
                )
              else
                for (final concert in state.past)
                  _HistoryRow(
                    key: MyConcertsSection.historyKey(concert.concertId),
                    concert: concert,
                    onTap: () =>
                        _open(() => widget.onOpenConcert(concert.concertId)),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 제목과 그 아래 내용. Figma 섹션 제목(18 Bold)과 내용 사이·내용끼리 12.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x3,
      children: [
        Text(
          title,
          style: context.textStyles.title1Bold.copyWith(
            color: context.colors.labelNormal,
          ),
        ),
        ...children,
      ],
    );
  }
}

/// 진행 중 공연 하나 (Figma `BandCard`). 공연 값을 카드의 글자·태그로 풀어 넣는다.
class _ConcertCard extends StatelessWidget {
  const _ConcertCard({
    super.key,
    required this.concert,
    required this.daysLeft,
    required this.onTap,
  });

  final MyConcert concert;
  final int? daysLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _statusTag(concert.status);
    final days = daysLeft;
    return AppBandCard(
      title: concert.title,
      date: formatLocalMonthDay(concert.performDate) ?? '날짜 미정',
      time: formatLocalTime(concert.startTime),
      place: concert.area ?? '장소가 확정되면 열 수 있어요',
      tags: [
        ?status,
        if (concert.isHost) (label: '주최', style: AppTagStyle.neutral),
        // Figma `D - 20`. 공연 당일 표기는 시안에 없어 공연 페이지 헤더처럼 보이지 않는다.
        if (days != null && days > 0)
          (label: 'D - $days', style: AppTagStyle.neutral),
      ],
      poster: switch (concert.posterImageUrl) {
        final url? => NetworkImage(url),
        null => null,
      },
      onTap: onTap,
    );
  }

  /// Figma BandCard의 상태 태그는 '티켓 판매 중'(Fill)과 '티켓 전'(Outline)뿐이다.
  /// 판매 중지·마감·모르는 상태는 시안에 없어 태그를 달지 않는다.
  static AppBandCardTag? _statusTag(ConcertStatus status) => switch (status) {
    ConcertStatus.selling => (label: '티켓 판매 중', style: AppTagStyle.filled),
    ConcertStatus.beforeRecruit ||
    ConcertStatus.recruiting => (label: '티켓 전', style: AppTagStyle.outlined),
    ConcertStatus.salePaused ||
    ConcertStatus.saleClosed ||
    ConcertStatus.unknown => null,
  };
}

/// 지난 공연 한 줄 (Figma `공연 이력`의 Container): 제목과 날짜.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({super.key, required this.concert, required this.onTap});

  final MyConcert concert;
  final VoidCallback onTap;

  static const _minTouchHeight = 44.0; // 탭 영역 최소 44 (pr-checklist A8)

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textStyles.caption1Medium.copyWith(
      color: colors.labelNormal,
    );
    final date = formatLocalDateDotted(concert.performDate);
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        // 다크 시안에서 카드와 같은 면이라 라이트에서도 BandCard처럼 테두리로 그린다.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: colors.lineStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minTouchHeight),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.x3),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: AppSpacing.x3,
                runSpacing: AppSpacing.x1,
                children: [
                  Text(
                    concert.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                  if (date != null) Text(date, style: style),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
