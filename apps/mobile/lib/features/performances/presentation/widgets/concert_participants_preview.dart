import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/show/show_team_avatar.dart';
import '../providers/concert_participants_providers.dart';
import 'concert_section.dart';

/// 정보 탭의 참여 밴드 미리보기 (Figma `참여 밴드` Section, 2217:123297). 지금은 이름과 주최 배지만 보인다.
/// 팀 수·빈자리·프로필 진입을 제공한다. 주최 대표자의 빼기(`편집`)는 JECT-151이 붙인다.
/// 참여 팀 멤버가 아니거나 공연이 없으면(403·404) 공연 페이지가 내용을 통째로 막는다.
class ConcertParticipantsPreview extends ConsumerStatefulWidget {
  const ConcertParticipantsPreview({
    super.key,
    required this.concertId,
    this.recruitTeamCount,
    this.onBandTap,
    this.recruiting = false,
  });

  final int concertId;
  final int? recruitTeamCount;
  final ValueChanged<int>? onBandTap;
  final bool recruiting;

  @override
  ConsumerState<ConcertParticipantsPreview> createState() =>
      _ConcertParticipantsPreviewState();
}

class _ConcertParticipantsPreviewState
    extends ConsumerState<ConcertParticipantsPreview> {
  // 요약 수는 정확히 유지하되, 큰 목표 수로 수만 개의 자리 위젯을 한 번에 만들지 않는다.
  static const _maxVisibleOpenSlots = 5;

  /// 다시 시도로 보낸 요청의 결과를 기다리는 중. 자동 재시도 대기와 상태 값이 같아 화면이 따로 기억한다.
  var _retrying = false;

  @override
  Widget build(BuildContext context) {
    final provider = concertParticipantsProvider(widget.concertId);
    ref.listen(provider, (_, next) {
      if (_retrying && (!next.isLoading || next.retrying)) {
        setState(() => _retrying = false);
      }
    });
    final participants = ref.watch(provider);
    final teams = participants.value;
    String? summary;
    final Widget content;
    if (participants.hasError) {
      // 자동 재시도를 기다리는 동안과 갱신이 실패한 뒤에도 이전 목록 대신 실패를 알리고 다시 시도하게 한다.
      content = ErrorView(
        message: '참여 밴드를 불러오지 못했어요. 다시 시도해 주세요.',
        actionLabel: '다시 시도',
        loading: _retrying,
        onAction: () {
          setState(() => _retrying = true);
          ref.invalidate(provider);
        },
      );
    } else if (teams == null) {
      content = const LoadingView();
    } else if (teams.isEmpty) {
      content = const EmptyView(message: '아직 참여한 밴드가 없어요');
    } else {
      final recruitCount = widget.recruitTeamCount;
      final openSlots = recruitCount == null
          ? 0
          : math.max(
              0,
              recruitCount - teams.where((team) => !team.isHost).length,
            );
      if (recruitCount != null) {
        // 총 팀 수는 주최 팀을 포함한 목표 수다. 현재 roster로 계산해 빼기 후 남은 자리도 갱신한다.
        final total = teams.length + openSlots;
        summary = openSlots == 0
            ? '총 $total팀'
            : widget.recruiting
            ? '총 $total팀 · $openSlots팀 더 들어와야 해요'
            : '총 $total팀 · 빈 자리 $openSlots팀';
      }
      final onBandTap = widget.onBandTap;
      content = Wrap(
        spacing: AppSpacing.x4,
        runSpacing: AppSpacing.x4,
        children: [
          for (final team in teams)
            Semantics(
              button: onBandTap != null,
              label: '${team.name} 밴드 프로필',
              child: InkWell(
                onTap: onBandTap == null ? null : () => onBandTap(team.bandId),
                child: ShowTeamAvatar(
                  name: team.name,
                  hostLabel: team.isHost ? '주최' : null,
                  image: switch (team.profileImageUrl) {
                    final url? => NetworkImage(url),
                    null => null,
                  },
                ),
              ),
            ),
          for (var i = 0; i < math.min(openSlots, _maxVisibleOpenSlots); i++)
            ShowTeamAvatar(
              name: widget.recruiting ? '모집 중' : '빈 자리',
              recruiting: true,
            ),
        ],
      );
    }
    return ConcertSection(title: '참여 밴드', summary: summary, child: content);
  }
}
