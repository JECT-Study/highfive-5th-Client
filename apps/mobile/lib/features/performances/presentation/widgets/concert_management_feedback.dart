import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/show/show_confirm_popup.dart';
import '../../models/concert_management_failure.dart';
import '../providers/concert_management_providers.dart';
import '../view_models/concert_management_view_model.dart';
import 'concert_management_popup.dart';

/// 명령 결과의 안내와 이동. 화면은 결과가 남는 요청을 직접 보내지 않는다.
class ConcertManagementFeedback extends ConsumerStatefulWidget {
  const ConcertManagementFeedback({
    super.key,
    required this.concertId,
    required this.onDeleted,
    required this.onUnavailable,
    required this.child,
  });

  final int concertId;
  final VoidCallback onDeleted;
  final VoidCallback onUnavailable;
  final Widget child;

  static Object ownerOf(BuildContext context) => context
      .findAncestorStateOfType<_ConcertManagementFeedbackState>()!
      ._captureOwner();

  @override
  ConsumerState<ConcertManagementFeedback> createState() =>
      _ConcertManagementFeedbackState();
}

class _ConcertManagementFeedbackState
    extends ConsumerState<ConcertManagementFeedback> {
  final _owner = Object();
  Uri? _location;
  Uri? _requestLocation;

  Object _captureOwner() {
    _location = GoRouter.maybeOf(context)?.state.uri;
    _requestLocation = GoRouter.maybeOf(context)
        ?.routeInformationProvider
        .value
        .uri;
    return _owner;
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    _location ??= router?.state.uri;
    ref.listen(concertManagementViewModelProvider(widget.concertId), (
      previous,
      next,
    ) async {
      final repository = ref.read(concertManagementRepositoryProvider);
      final route = ModalRoute.of(context);
      if (next.owner != _owner ||
          !repository.active ||
          route?.isCurrent != true ||
          router?.state.uri != _location ||
          router?.routeInformationProvider.value.uri != _requestLocation) {
        return;
      }
      if (next.deleted) {
        widget.onDeleted();
        return;
      }
      final failure = next.failure;
      if (failure == null) return;
      await showConcertManagementPopup(
        context,
        ref,
        ShowConfirmPopup(
          title:
              failure == ConcertManagementFailure.sellingStarted ||
                  failure == ConcertManagementFailure.unknownStatus
              ? '공연을 삭제할 수 없어요'
              : '요청을 완료하지 못했어요',
          message: switch (failure) {
            ConcertManagementFailure.concertNotFound =>
              '공연을 찾을 수 없어요. 이전 화면에서 다시 확인해 주세요.',
            ConcertManagementFailure.forbidden => '권한이 없어요. 현재 참여 권한을 확인해 주세요.',
            ConcertManagementFailure.bandNotParticipating =>
              '이미 빠진 밴드예요. 참여 밴드 목록을 다시 확인해 주세요.',
            ConcertManagementFailure.hostBand => '주최 팀은 뺄 수 없어요.',
            ConcertManagementFailure.sellingStarted =>
              '티켓 판매가 시작된 공연은 삭제할 수 없어요.',
            ConcertManagementFailure.unknownStatus =>
              '공연 상태를 확인할 수 없어요. 정보를 다시 불러온 뒤 시도해 주세요.',
            ConcertManagementFailure.network => '네트워크 상태를 확인하고 다시 시도해 주세요.',
            ConcertManagementFailure.unknown =>
              '요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요.',
          },
          alert: true,
          confirmLabel: '확인',
        ),
      );
      if (context.mounted &&
          repository.active &&
          route?.isCurrent == true &&
          router?.state.uri == _location &&
          router?.routeInformationProvider.value.uri == _requestLocation &&
          failure == ConcertManagementFailure.concertNotFound) {
        if (next.deleting) {
          widget.onDeleted();
        } else {
          widget.onUnavailable();
        }
      }
    });
    return widget.child;
  }
}
