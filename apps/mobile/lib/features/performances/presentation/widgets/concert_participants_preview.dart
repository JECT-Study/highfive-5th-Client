import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/show/show_team_avatar.dart';
import '../providers/concert_participants_providers.dart';
import '../providers/concert_detail_providers.dart';
import '../../models/concert_access.dart';
import '../view_models/concert_management_view_model.dart';
import 'concert_participant_remove_button.dart';
import 'concert_section.dart';

/// 정보 탭의 참여 밴드 미리보기 (Figma `참여 밴드` Section, 2217:123297). 지금은 이름과 주최 배지만 보인다.
/// 팀 수 안내·빈자리·프로필 사진은 JECT-152가, 주최 대표자의 빼기(`편집`)는 JECT-151이 붙인다.
/// 참여 팀 멤버가 아니거나 공연이 없으면(403·404) 공연 페이지가 내용을 통째로 막는다.
class ConcertParticipantsPreview extends ConsumerStatefulWidget {
  const ConcertParticipantsPreview({super.key, required this.concertId});

  final int concertId;

  @override
  ConsumerState<ConcertParticipantsPreview> createState() =>
      _ConcertParticipantsPreviewState();
}

class _ConcertParticipantsPreviewState
    extends ConsumerState<ConcertParticipantsPreview> {
  /// 다시 시도로 보낸 요청의 결과를 기다리는 중. 자동 재시도 대기와 상태 값이 같아 화면이 따로 기억한다.
  var _retrying = false;
  var _editing = false;

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
    final detail = ref
        .watch(concertDetailProvider(widget.concertId))
        .asData
        ?.value;
    final canManage = detail != null && ConcertAccess(detail).canManage;
    final command = ref.watch(
      concertManagementViewModelProvider(widget.concertId),
    );
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
      content = Wrap(
        spacing: AppSpacing.x4,
        runSpacing: AppSpacing.x4,
        children: [
          for (final team in teams)
            if (!command.removedBandIds.contains(team.bandId))
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: canManage
                        ? const EdgeInsets.only(
                            top: AppSpacing.x3,
                            right: AppSpacing.x3,
                          )
                        : EdgeInsets.zero,
                    child: ShowTeamAvatar(
                      name: team.name,
                      hostLabel: team.isHost ? '주최' : null,
                    ),
                  ),
                  if (_editing && canManage)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: ConcertParticipantRemoveButton(
                        concertId: widget.concertId,
                        participant: team,
                      ),
                    ),
                ],
              ),
        ],
      );
    }
    return ConcertSection(
      title: '참여 밴드',
      trailing: canManage && teams != null && !participants.hasError
          ? AppButton(
              key: const ValueKey('concert_participantsEdit'),
              label: _editing ? '완료' : '편집',
              size: AppButtonSize.small,
              variant: AppButtonVariant.weak,
              onPressed: command.submitting
                  ? null
                  : () => setState(() => _editing = !_editing),
            )
          : null,
      child: content,
    );
  }
}
