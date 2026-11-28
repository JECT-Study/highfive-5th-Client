import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/concert_edit_repository.dart';
import '../../models/concert_edit_failure.dart';
import '../../models/concert_edit_values.dart';

/// 실제 상세 화면 또는 오프라인 하네스가 공급하는 완전한 편집 문맥.
/// ID만으로 열 수 없다. 전체 교체에 필요한 값과 재조회 책임이 모두 필요하다.
class ConcertEditEntry {
  const ConcertEditEntry({
    required this.initial,
    required this.repository,
    required this.isSessionCurrent,
    this.offline = false,
  });

  final ConcertEditSnapshot initial;
  final ConcertEditRepository repository;
  final bool Function() isSessionCurrent;
  final bool offline;
}

enum ConcertEditStatus {
  editing,
  saving,
  reloading,
  saved,
  blocked,
  needsReload,
}

class ConcertEditState {
  const ConcertEditState({
    required this.snapshot,
    this.status = ConcertEditStatus.editing,
    this.failure,
    this.fields = const {},
    this.revision = 0,
  });

  final ConcertEditSnapshot snapshot;
  final ConcertEditStatus status;
  final ConcertEditFailureKind? failure;
  final Map<String, String> fields;
  final int revision;
  bool get canEdit =>
      status == ConcertEditStatus.editing && snapshot.isParticipant;
}

final concertEditProvider = NotifierProvider.autoDispose
    .family<ConcertEditViewModel, ConcertEditState, ConcertEditEntry>(
      ConcertEditViewModel.new,
    );

class ConcertEditViewModel extends Notifier<ConcertEditState> {
  ConcertEditViewModel(this.entry);
  final ConcertEditEntry entry;

  @override
  ConcertEditState build() => ConcertEditState(snapshot: entry.initial);

  bool _sessionValid() {
    if (entry.isSessionCurrent()) return true;
    state = ConcertEditState(
      snapshot: state.snapshot,
      status: ConcertEditStatus.blocked,
      failure: ConcertEditFailureKind.authentication,
      revision: state.revision,
    );
    return false;
  }

  Future<void> submit(ConcertEditForm form, {DateTime? today}) async {
    if (!state.canEdit || !_sessionValid()) return;
    final current = state;
    final errors = form.validate(
      current.snapshot,
      today: today ?? concertBusinessDate(DateTime.now()),
    );
    if (errors.isNotEmpty) {
      state = ConcertEditState(
        snapshot: current.snapshot,
        fields: errors,
        revision: current.revision,
      );
      return;
    }
    state = ConcertEditState(
      snapshot: current.snapshot,
      status: ConcertEditStatus.saving,
      revision: current.revision,
    );
    try {
      await entry.repository.save(form.replace(current.snapshot.values));
      if (!ref.mounted || !_sessionValid()) return;
      // PUT은 새 version을 반환하지 않는다. 성공 후 같은 원본으로 다시 저장하지 않는다.
      state = ConcertEditState(
        snapshot: current.snapshot,
        status: ConcertEditStatus.saved,
        revision: current.revision,
      );
    } on ConcertEditFailure catch (error) {
      if (!ref.mounted || !_sessionValid()) return;
      state = ConcertEditState(
        snapshot: current.snapshot,
        status: switch (error.kind) {
          ConcertEditFailureKind.invalid => ConcertEditStatus.editing,
          ConcertEditFailureKind.conflict ||
          ConcertEditFailureKind.uncertain => ConcertEditStatus.needsReload,
          _ => ConcertEditStatus.blocked,
        },
        failure: error.kind,
        fields: error.fields,
        revision: current.revision,
      );
      if (error.kind == ConcertEditFailureKind.conflict) await reload();
    } catch (_) {
      if (!ref.mounted || !_sessionValid()) return;
      state = ConcertEditState(
        snapshot: current.snapshot,
        status: ConcertEditStatus.needsReload,
        failure: ConcertEditFailureKind.uncertain,
        revision: current.revision,
      );
    }
  }

  Future<void> reload() async {
    if (state.status == ConcertEditStatus.saving ||
        state.status == ConcertEditStatus.reloading ||
        !_sessionValid()) {
      return;
    }
    final current = state;
    state = ConcertEditState(
      snapshot: current.snapshot,
      status: ConcertEditStatus.reloading,
      failure: current.failure,
      revision: current.revision,
    );
    try {
      final fresh = await entry.repository.reload();
      if (!ref.mounted || !_sessionValid()) return;
      state = ConcertEditState(
        snapshot: fresh,
        failure: current.failure == ConcertEditFailureKind.conflict
            ? ConcertEditFailureKind.conflict
            : null,
        revision: current.revision + 1,
      );
    } catch (error) {
      if (!ref.mounted || !_sessionValid()) return;
      final failure = error is ConcertEditFailure
          ? error.kind
          : ConcertEditFailureKind.uncertain;
      state = ConcertEditState(
        snapshot: current.snapshot,
        status: switch (failure) {
          ConcertEditFailureKind.missing ||
          ConcertEditFailureKind.authentication ||
          ConcertEditFailureKind.forbidden => ConcertEditStatus.blocked,
          _ => ConcertEditStatus.needsReload,
        },
        failure: failure,
        revision: current.revision,
      );
    }
  }
}
