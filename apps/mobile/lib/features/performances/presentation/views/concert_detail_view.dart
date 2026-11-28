import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_tab_list.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../models/concert_detail.dart';
import '../providers/concert_detail_providers.dart';
import '../providers/concert_participants_providers.dart';
import '../widgets/concert_info_tab.dart';
import '../widgets/concert_page_header.dart';
import '../widgets/concert_management_feedback.dart';

/// 합동공연 페이지 안의 탭. 경로를 나누지 않고 화면 상태로 둔다 (docs/mobile-architecture.md 11절).
/// Figma의 `티켓 관리` 탭은 티켓 기능에서 값을 더한다.
enum ConcertPageTab {
  info('정보'),
  feed('피드'),
  schedule('일정');

  const ConcertPageTab(this.label);

  final String label;
}

/// 합동공연 페이지 (`/shows/:showId`, Figma `정보탭_*` 2217:122759·2217:122814).
///
/// 참여 팀 멤버만 본다. 서버는 참여자가 아니면 403 `AUTH_005`로 막고, 화면은 응답의 `myBandIds`가 비어도
/// 참여자가 아닌 것으로 본다. 없는 공연(404 `CONCERT_001`)과 참여자가 아닌 경우는 명세대로 안내한 뒤
/// 이전 화면으로 돌아가게 하고, 그 밖의 오류는 다시 시도를 보인다.
class ConcertDetailView extends ConsumerStatefulWidget {
  const ConcertDetailView({
    super.key,
    required this.concertId,
    required this.onBack,
    required this.onEdit,
    this.onDeleted,
    this.clock,
  });

  /// 주소의 공연 ID. null이면 주소가 잘못된 것으로 보고 요청 없이 없는 공연 안내를 보인다.
  final int? concertId;
  final VoidCallback onBack;
  final VoidCallback? onDeleted;

  /// 공연 정보 수정 화면으로 간다. 라우트 표에 수정 화면이 없으면 null이고, 정보 수정 버튼은 비활성이다.
  final VoidCallback? onEdit;

  /// 지금 시각(D-day 기준). 없으면 기기 시각이다. 테스트·골든에서 날짜를 정할 때만 넘긴다.
  final DateTime Function()? clock;

  static const forbiddenKey = ValueKey('concertDetail_forbidden');
  static const notFoundKey = ValueKey('concertDetail_notFound');
  static const failureKey = ValueKey('concertDetail_failure');

  @override
  ConsumerState<ConcertDetailView> createState() => _ConcertDetailViewState();
}

class _ConcertDetailViewState extends ConsumerState<ConcertDetailView> {
  var _tab = ConcertPageTab.info;

  /// 다시 시도로 보낸 요청의 결과를 기다리는 중. 자동 재시도 대기와 상태 값이 같아 화면이 따로 기억한다.
  var _retrying = false;

  @override
  Widget build(BuildContext context) {
    final concertId = widget.concertId;
    return Scaffold(
      // Figma 오른쪽 메시지 아이콘(대표자 채팅)은 열 채팅방을 알려 주는 명세가 없어 아직 두지 않는다.
      appBar: AppTopBar(
        title: '합동 공연',
        leading: AppIconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          tooltip: '뒤로',
          onPressed: widget.onBack,
        ),
      ),
      body: concertId == null
          ? _notFound()
          : ConcertManagementFeedback(
              key: ValueKey(concertId),
              concertId: concertId,
              onDeleted: widget.onDeleted ?? widget.onBack,
              onUnavailable: widget.onBack,
              child: _body(concertId),
            ),
    );
  }

  Widget _body(int concertId) {
    final detailProvider = concertDetailProvider(concertId);
    ref.listen(detailProvider, (_, next) {
      if (_retrying && (!next.isLoading || next.retrying)) {
        setState(() => _retrying = false);
      }
    });
    final detail = ref.watch(detailProvider);
    // 없는 공연·참여하지 않은 공연은 이전 값이 있어도 더 보여 주지 않는다 (삭제·빼기 뒤 다시 불러온 경우).
    if (_isForbidden(detail.error)) return _forbidden();
    if (_isNotFound(detail.error)) return _notFound();
    if (detail.hasError) {
      // 자동 재시도를 기다리는 동안과 갱신이 실패한 뒤에도 이전 값 대신 실패를 알리고 다시 시도하게 한다.
      return ErrorView(
        key: ConcertDetailView.failureKey,
        message: '공연 정보를 불러오지 못했어요. 다시 시도해 주세요.',
        actionLabel: '다시 시도',
        loading: _retrying,
        onAction: () {
          setState(() => _retrying = true);
          ref.invalidate(detailProvider);
        },
      );
    }
    final concert = detail.value;
    if (concert == null) return const LoadingView();
    if (concert.myBandIds.isEmpty) return _forbidden();
    // 참여 밴드 조회도 같은 접근 규칙(참여 팀 멤버)을 따른다. 403·404면 이전 목록이 있어도 내용을 막는다.
    final participantsError = ref
        .watch(concertParticipantsProvider(concertId))
        .error;
    if (_isForbidden(participantsError)) return _forbidden();
    if (_isNotFound(participantsError)) return _notFound();
    return _page(concert);
  }

  Widget _forbidden() => ErrorView(
    key: ConcertDetailView.forbiddenKey,
    message: '이 공연에 참여한 팀만 볼 수 있어요.',
    actionLabel: '이전 화면으로',
    onAction: widget.onBack,
  );

  Widget _notFound() => ErrorView(
    key: ConcertDetailView.notFoundKey,
    message: '공연을 찾을 수 없어요. 삭제됐거나 주소가 바뀌었을 수 있어요.',
    actionLabel: '이전 화면으로',
    onAction: widget.onBack,
  );

  Widget _page(ConcertDetail concert) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          // Figma: 상단 바와 머리 사이 10, 머리와 탭 사이 14, 좌우 20.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x2_5,
            AppSpacing.x5,
            AppSpacing.x3_5,
          ),
          sliver: SliverToBoxAdapter(
            child: ConcertPageHeader(
              detail: concert,
              onEdit: widget.onEdit,
              clock: widget.clock,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AppTabList(
            labels: [for (final tab in ConcertPageTab.values) tab.label],
            selectedIndex: _tab.index,
            onSelected: (index) =>
                setState(() => _tab = ConcertPageTab.values[index]),
          ),
        ),
        // 탭 왕복 중에도 진행 중인 재시도의 비활성 상태를 보존한다.
        SliverVisibility(
          visible: _tab == ConcertPageTab.info,
          maintainState: true,
          sliver: SliverSafeArea(
            top: false,
            sliver: SliverToBoxAdapter(child: ConcertInfoTab(detail: concert)),
          ),
        ),
        // 피드·일정 탭의 내용은 피드·일정 기능(리자 담당)이 채운다.
        ...switch (_tab) {
          ConcertPageTab.info => const <Widget>[],
          ConcertPageTab.feed => const [
            SliverSafeArea(
              top: false,
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(message: '피드는 준비 중이에요'),
              ),
            ),
          ],
          ConcertPageTab.schedule => const [
            SliverSafeArea(
              top: false,
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(message: '일정은 준비 중이에요'),
              ),
            ),
          ],
        },
      ],
    );
  }
}

/// 명세의 참여 권한 오류 그대로만 본다. 다른 403은 일반 실패(다시 시도)로 둔다.
bool _isForbidden(Object? error) =>
    error is ApiException &&
    error.statusCode == 403 &&
    error.code == 'AUTH_005';

/// 명세의 공연 없음 오류 그대로만 본다. 코드 없는 404(게이트웨이 등)는 일반 실패로 둔다.
bool _isNotFound(Object? error) =>
    error is ApiException &&
    error.statusCode == 404 &&
    error.code == 'CONCERT_001';
