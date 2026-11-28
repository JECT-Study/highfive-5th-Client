import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/show/show_confirm_popup.dart';
import '../../models/concert_access.dart';
import '../providers/concert_detail_providers.dart';
import '../view_models/concert_management_view_model.dart';
import 'concert_management_feedback.dart';
import 'concert_management_popup.dart';

/// 상세 화면의 삭제 진입점. 확인창 뒤에도 ViewModel이 최신 권한을 검사한다.
class ConcertDeleteButton extends ConsumerWidget {
  const ConcertDeleteButton({super.key, required this.concertId});

  final int concertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(concertDetailProvider(concertId)).asData?.value;
    if (detail == null || !ConcertAccess(detail).canManage) {
      return const SizedBox.shrink();
    }
    final state = ref.watch(concertManagementViewModelProvider(concertId));
    return AppButton(
      key: const ValueKey('concert_delete'),
      label: '공연 삭제하기',
      variant: AppButtonVariant.danger,
      loading: state.submitting,
      onPressed: state.deleted
          ? null
          : () async {
              final owner = ConcertManagementFeedback.ownerOf(context);
              final confirmed = await showConcertManagementPopup(
                context,
                ref,
                const ShowConfirmPopup(
                  title: '공연을 삭제할까요?',
                  message: '삭제하면 되돌릴 수 없어요.',
                  notice: '모집 공고, 피드, 일정, 라인업이 함께 삭제돼요.\n참여 팀 모두에게 삭제 알림이 가요.',
                  cancelLabel: '취소',
                  confirmLabel: '삭제하기',
                  destructive: true,
                ),
              );
              if (!confirmed || !context.mounted) return;
              await ref
                  .read(concertManagementViewModelProvider(concertId).notifier)
                  .deleteConcert(owner: owner);
            },
    );
  }
}
