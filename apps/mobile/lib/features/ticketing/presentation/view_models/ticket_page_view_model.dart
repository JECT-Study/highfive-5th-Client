import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ticket_application_page.dart';
import '../../models/ticket_role.dart';
import '../providers/ticket_page_providers.dart';

final ticketPageViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<TicketPageViewModel, TicketPageState, TicketPageScope>(
      TicketPageViewModel.new,
      retry: (_, _) => null,
    );

class TicketPageViewModel extends AsyncNotifier<TicketPageState> {
  TicketPageViewModel(this.scope);

  final TicketPageScope scope;
  static const requestTimeout = Duration(seconds: 8);
  Object _generation = Object();
  bool _checking = false;
  void Function()? _releaseCommand;

  @override
  Future<TicketPageState> build() async {
    _generation = Object();
    _checking = false;
    final repository = ref.watch(ticketPageRepositoryProvider);
    final generation = _generation;
    TicketApplicationPage? latestPage;
    var loaded = false;
    final subscription = repository.watch(scope).listen((page) {
      if (!ref.mounted || generation != _generation) return;
      latestPage = page;
      if (loaded) {
        state = AsyncData(TicketPageState(page: page));
        _releaseCommand?.call();
        _releaseCommand = null;
      }
    });
    ref.onDispose(subscription.cancel);
    final page = await repository.find(scope).timeout(requestTimeout);
    loaded = true;
    return TicketPageState(page: latestPage ?? page);
  }

  void retryLoad() {
    if (state.value?.creating == true ||
        state.value?.failure == TicketPageFailureReason.outcomeUnknown) {
      return;
    }
    ref.invalidateSelf();
  }

  Future<void> create() async {
    final current = state.value;
    if (scope.role != ticketPageRequiredRole ||
        current == null ||
        !current.canCreate) {
      return;
    }
    final generation = _generation;
    final repository = ref.read(ticketPageRepositoryProvider);
    _releaseCommand = ref.keepAlive().close;
    state = const AsyncData(TicketPageState(creating: true));
    try {
      final page = await repository.create(scope).timeout(requestTimeout);
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(TicketPageState(page: page));
    } on TimeoutException {
      if (!ref.mounted || generation != _generation) return;
      if (state.value?.page != null) return;
      state = const AsyncData(
        TicketPageState(failure: TicketPageFailureReason.outcomeUnknown),
      );
      await checkOutcome();
    } on Object catch (error) {
      if (!ref.mounted || generation != _generation) return;
      if (state.value?.page != null) return;
      state = AsyncData(
        TicketPageState(
          failure: switch (error) {
            TicketPageFailure(:final reason) => reason,
            _ => TicketPageFailureReason.unavailable,
          },
        ),
      );
    } finally {
      if (ref.mounted &&
          generation == _generation &&
          state.value?.failure != TicketPageFailureReason.outcomeUnknown) {
        _releaseCommand?.call();
        _releaseCommand = null;
      }
    }
  }

  /// 시간 초과는 실패 확정이 아니므로 같은 생성 명령을 다시 보내지 않는다.
  Future<void> checkOutcome() async {
    if (_checking ||
        state.value?.failure != TicketPageFailureReason.outcomeUnknown) {
      return;
    }
    _checking = true;
    final generation = _generation;
    final repository = ref.read(ticketPageRepositoryProvider);
    try {
      final page = await repository.find(scope).timeout(requestTimeout);
      if (!ref.mounted || generation != _generation) return;
      if (page != null) {
        state = AsyncData(TicketPageState(page: page));
        _releaseCommand?.call();
        _releaseCommand = null;
      }
    } on Object {
      // 조회 실패에도 생성 결과는 미확정이다. 재생성 대신 재조회만 허용한다.
    } finally {
      if (ref.mounted && generation == _generation) _checking = false;
    }
  }
}
