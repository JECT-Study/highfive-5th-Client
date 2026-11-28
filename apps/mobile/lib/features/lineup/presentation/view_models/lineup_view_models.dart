import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../models/lineup.dart';
import '../providers/lineup_providers.dart';

typedef SetlistKey = ({int concertId, int bandId});

/// 조회 데이터는 유지하면서 저장 버튼과 오류 안내를 별도로 갱신한다.
class LineupWriteState {
  const LineupWriteState({this.isSaving = false, this.error, this.message});

  final bool isSaving;
  final Object? error;
  final String? message;
}

class LineupWriteNotifier extends Notifier<LineupWriteState> {
  @override
  LineupWriteState build() {
    ref.watch(lineupRepositoryProvider);
    return const LineupWriteState();
  }

  void update(LineupWriteState value) => state = value;
}

final lineupWriteProvider = NotifierProvider.autoDispose
    .family<LineupWriteNotifier, LineupWriteState, int>(
      (_) => LineupWriteNotifier(),
    );

final setlistWriteProvider = NotifierProvider.autoDispose
    .family<LineupWriteNotifier, LineupWriteState, SetlistKey>(
      (_) => LineupWriteNotifier(),
    );

final lineupProvider = AsyncNotifierProvider.autoDispose
    .family<LineupViewModel, Lineup, int>(
      LineupViewModel.new,
      retry: (_, _) => null,
    );

class LineupViewModel extends AsyncNotifier<Lineup> {
  LineupViewModel(this.concertId);

  final int concertId;

  @override
  Future<Lineup> build() {
    ref.watch(lineupWriteProvider(concertId).notifier);
    return ref.watch(lineupRepositoryProvider).getLineup(concertId);
  }

  void retry() {
    if (!ref.read(lineupWriteProvider(concertId)).isSaving) {
      ref.invalidateSelf();
    }
  }

  Future<void> refresh() async {
    if (ref.read(lineupWriteProvider(concertId)).isSaving) return;
    ref.invalidateSelf();
    await future;
  }

  /// newIndex는 항목을 제거한 뒤의 최종 위치다. 빈 슬롯은 저장하지 않는다.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    final write = ref.read(lineupWriteProvider(concertId).notifier);
    if (current == null ||
        state.hasError ||
        state.isLoading ||
        ref.read(lineupWriteProvider(concertId)).isSaving) {
      return;
    }
    final teams = [...current.teams];
    if (oldIndex < 0 ||
        oldIndex >= teams.length ||
        newIndex < 0 ||
        newIndex >= teams.length ||
        oldIndex == newIndex) {
      return;
    }
    teams.insert(newIndex, teams.removeAt(oldIndex));
    final repository = ref.read(lineupRepositoryProvider);
    final operationRef = ref;
    write.update(const LineupWriteState(isSaving: true));
    Object? saveError;
    try {
      await repository.saveLineup(concertId, [
        for (final team in teams) team.band.bandId,
      ]);
    } catch (error) {
      saveError = error;
    }
    if (!operationRef.mounted) return;
    final conflict = saveError is ApiException && saveError.statusCode == 409;
    final message = conflict ? '라인업이 변경되었습니다. 최신 정보를 확인해 주세요.' : null;
    // 409 안내를 먼저 전달하고, 저장 잠금을 유지한 채 최신 목록을 받는다.
    write.update(
      LineupWriteState(isSaving: true, error: saveError, message: message),
    );
    if (saveError == null || conflict) {
      try {
        final latest = await repository.getLineup(concertId);
        if (!operationRef.mounted) return;
        state = AsyncData(latest);
      } catch (error, stack) {
        if (!operationRef.mounted) return;
        state = AsyncError<Lineup>(error, stack);
        saveError ??= error;
      }
    }
    if (!operationRef.mounted) return;
    write.update(LineupWriteState(error: saveError, message: message));
  }
}

final setlistProvider = AsyncNotifierProvider.autoDispose
    .family<SetlistViewModel, BandSetlist, SetlistKey>(
      SetlistViewModel.new,
      retry: (_, _) => null,
    );

class SetlistViewModel extends AsyncNotifier<BandSetlist> {
  SetlistViewModel(this.key);

  final SetlistKey key;

  @override
  Future<BandSetlist> build() {
    ref.watch(setlistWriteProvider(key).notifier);
    return ref
        .watch(lineupRepositoryProvider)
        .getSetlist(key.concertId, key.bandId);
  }

  void retry() {
    if (!ref.read(setlistWriteProvider(key)).isSaving) ref.invalidateSelf();
  }

  Future<void> refresh() async {
    if (ref.read(setlistWriteProvider(key)).isSaving) return;
    ref.invalidateSelf();
    await future;
  }

  Future<bool> save(List<LineupSong> songs) async {
    final current = state.value;
    if (current == null ||
        state.hasError ||
        state.isLoading ||
        !current.canEdit ||
        ref.read(setlistWriteProvider(key)).isSaving) {
      return false;
    }
    final submitted = List<LineupSong>.unmodifiable(songs);
    final repository = ref.read(lineupRepositoryProvider);
    final write = ref.read(setlistWriteProvider(key).notifier);
    final operationRef = ref;
    write.update(const LineupWriteState(isSaving: true));
    try {
      await repository.saveSetlist(key.concertId, key.bandId, submitted);
    } catch (error) {
      if (!operationRef.mounted) return false;
      write.update(LineupWriteState(error: error));
      return false;
    }
    if (!operationRef.mounted) return false;
    ref.invalidate(lineupProvider(key.concertId));
    // 저장은 완료됐다. 서버가 생성한 외부 링크까지 다시 조회한다.
    // 이 GET만 실패하면 이전 편집본으로 PUT을 재전송할 수 없게 한다.
    try {
      final latest = await repository.getSetlist(key.concertId, key.bandId);
      if (!operationRef.mounted) return false;
      state = AsyncData(latest);
    } catch (error, stack) {
      if (!operationRef.mounted) return false;
      state = AsyncError(error, stack);
      write.update(
        LineupWriteState(
          error: error,
          message: '저장되었습니다. 목록을 불러오지 못했습니다. 다시 불러와 주세요.',
        ),
      );
      return false;
    }
    write.update(const LineupWriteState());
    return true;
  }
}

final songSearchProvider = FutureProvider.autoDispose
    .family<List<LineupSong>, String>((ref, keyword) {
      final query = keyword.trim();
      if (query.isEmpty) return const <LineupSong>[];
      return ref.watch(lineupRepositoryProvider).searchSongs(query);
    }, retry: (_, _) => null);
