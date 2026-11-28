import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/concert_draft.dart';
import '../../models/concert_failure.dart';
import '../providers/concert_providers.dart';

class ConcertCreationState {
  const ConcertCreationState({
    this.submitting = false,
    this.concertId,
    this.fields = const {},
    this.failure,
  });

  final bool submitting;
  final int? concertId;
  final Map<String, String> fields;
  final ConcertFailureKind? failure;

  bool get locked =>
      submitting ||
      concertId != null ||
      failure == ConcertFailureKind.uncertain ||
      failure == ConcertFailureKind.forbidden;
}

final concertCreationProvider = NotifierProvider.autoDispose
    .family<ConcertCreationViewModel, ConcertCreationState, HostBand>(
      ConcertCreationViewModel.new,
    );

class ConcertCreationViewModel extends Notifier<ConcertCreationState> {
  ConcertCreationViewModel(this.hostBand);

  final HostBand hostBand;

  @override
  ConcertCreationState build() => ConcertCreationState(
    failure: ref.watch(concertRepositoryProvider).hasUncertainCreation(hostBand)
        ? ConcertFailureKind.uncertain
        : null,
  );

  Future<void> submit(ConcertDraft draft) async {
    if (state.locked) return;
    final genres = ref.read(concertGenresProvider).asData?.value;
    if (genres == null || genres.isEmpty) return;
    final fields = draft.validate(
      today: ref.read(concertTodayProvider)(),
      availableGenres: genres,
    );
    if (fields.isNotEmpty) {
      state = ConcertCreationState(fields: fields);
      return;
    }
    state = const ConcertCreationState(submitting: true);
    // Notifier는 재빌드될 수 있으므로 현재 작업의 수명을 따로 캡처한다.
    var active = true;
    ref.onDispose(() => active = false);
    try {
      final id = await ref
          .read(concertRepositoryProvider)
          .create(hostBand, draft);
      if (active && ref.mounted) {
        state = ConcertCreationState(concertId: id);
      }
    } on ConcertFailure catch (failure) {
      if (active && ref.mounted) {
        state = ConcertCreationState(
          fields: failure.fields,
          failure: failure.kind,
        );
      }
    }
  }
}
