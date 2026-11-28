import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/show/show_confirm_popup.dart';
import '../../models/concert_access.dart';
import '../../models/concert_participant.dart';
import '../providers/concert_detail_providers.dart';
import '../view_models/concert_management_view_model.dart';
import 'concert_management_feedback.dart';
import 'concert_management_popup.dart';

class ConcertParticipantRemoveButton extends ConsumerWidget {
  const ConcertParticipantRemoveButton({
    super.key,
    required this.concertId,
    required this.participant,
  });

  final int concertId;
  final ConcertParticipant participant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(concertDetailProvider(concertId)).asData?.value;
    if (detail == null ||
        participant.isHost ||
        !ConcertAccess(detail).canRemoveBand(participant.bandId)) {
      return const SizedBox.shrink();
    }
    final command = ref.watch(concertManagementViewModelProvider(concertId));
    if (command.removedBandIds.contains(participant.bandId)) {
      return const SizedBox.shrink();
    }
    return AppIconButton(
      key: ValueKey('concert_remove_${participant.bandId}'),
      // Figma: 빨간 원 안의 흰 빼기. 폰트 아이콘에 의존하지 않는 두 도형이다.
      icon: Container(
        width: AppSpacing.x5,
        height: AppSpacing.x5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.statusDestructive,
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: AppSpacing.x2,
          height: AppSpacing.x0_5,
          child: ColoredBox(color: context.colors.staticWhite),
        ),
      ),
      tooltip: '${participant.name} 빼기',
      onPressed: command.submitting || command.deleted
          ? null
          : () async {
              final owner = ConcertManagementFeedback.ownerOf(context);
              final confirmed = await showConcertManagementPopup(
                context,
                ref,
                ShowConfirmPopup(
                  title: '${participant.name}를 공연에서 뺄까요?',
                  message: '빼면 아래 내용이 함께 정리돼요.',
                  notice:
                      '라인업과 셋리스트에서 빠져요.\n대표자 채팅방에서 나가요.\n${participant.name} 대표자에게 알림이 가요.',
                  cancelLabel: '취소',
                  confirmLabel: '빼기',
                  destructive: true,
                ),
              );
              if (!confirmed || !context.mounted) return;
              await ref
                  .read(concertManagementViewModelProvider(concertId).notifier)
                  .removeBand(participant.bandId, owner: owner);
            },
    );
  }
}
