import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/show/show_confirm_popup.dart';
import '../providers/concert_management_providers.dart';

/// 세션이 끝나면 자신이 연 팝업만 닫는다. 기존 Navigator의 다른 경로는 건드리지 않는다.
Future<bool> showConcertManagementPopup(
  BuildContext context,
  WidgetRef ref,
  ShowConfirmPopup popup,
) async {
  final repository = ref.read(concertManagementRepositoryProvider);
  final owner = ModalRoute.of(context);
  if (!repository.active || owner?.isCurrent != true) return false;
  final navigator = Navigator.of(context);
  final router = GoRouter.maybeOf(context);
  final location = router?.routeInformationProvider.value.uri;
  final route = DialogRoute<bool>(
    context: context,
    barrierColor: context.colors.materialDimmer,
    builder: (_) => popup,
  );
  void dismiss() {
    if (route.isActive) navigator.removeRoute(route, false);
  }

  void onLocationChanged() {
    if (router?.routeInformationProvider.value.uri != location) dismiss();
  }

  final subscription = repository.sessionEnded.listen((_) {
    dismiss();
  });
  router?.routeInformationProvider.addListener(onLocationChanged);
  bool? confirmed;
  try {
    confirmed = await navigator.push(route);
  } finally {
    router?.routeInformationProvider.removeListener(onLocationChanged);
    unawaited(subscription.cancel());
  }
  return repository.active &&
      context.mounted &&
      owner?.isCurrent == true &&
      router?.routeInformationProvider.value.uri == location &&
      confirmed == true;
}
