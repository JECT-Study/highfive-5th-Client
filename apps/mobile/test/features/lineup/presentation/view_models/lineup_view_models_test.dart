import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/lineup/data/repositories/lineup_repository.dart';
import 'package:highfive/features/lineup/models/lineup.dart';
import 'package:highfive/features/lineup/presentation/providers/lineup_providers.dart';
import 'package:highfive/features/lineup/presentation/view_models/lineup_view_models.dart';

const _band = LineupBand(
  bandId: 10,
  name: 'A',
  profileImageUrl: null,
  genres: [],
  memberCount: 3,
);
const _song = LineupSong(
  type: SongType.original,
  trackId: null,
  songTitle: 'Original',
  artist: 'A',
  durationSeconds: null,
  albumImageUrl: null,
  externalUrl: null,
);

Lineup _lineup(List<int> ids) => Lineup(
  teams: [
    for (final id in ids)
      LineupTeam(
        concertTeamId: id + 100,
        lineupOrder: ids.indexOf(id) + 1,
        isHost: id == 10,
        band: LineupBand(
          bandId: id,
          name: '$id',
          profileImageUrl: null,
          genres: const [],
          memberCount: 3,
        ),
        setlistPreview: const [],
        setlistTotalCount: 0,
      ),
  ],
  emptySlotCount: 2,
);

class _Repository implements LineupRepository {
  Lineup lineup = _lineup([10, 20, 30]);
  BandSetlist setlist = const BandSetlist(
    isHost: true,
    canEdit: true,
    band: _band,
    songs: [],
  );
  Object? loadError;
  Object? saveError;
  Completer<void>? saveGate;
  Completer<Lineup>? loadGate;
  int lineupLoads = 0;
  int setlistLoads = 0;
  final orders = <(int, List<int>)>[];
  final setlists = <(int, int, List<LineupSong>)>[];
  final searches = <String>[];

  @override
  Future<Lineup> getLineup(int concertId) async {
    lineupLoads++;
    if (loadError case final error?) throw error;
    return loadGate?.future ?? lineup;
  }

  @override
  Future<void> saveLineup(int concertId, List<int> bandIds) async {
    orders.add((concertId, bandIds));
    if (saveError case final error?) throw error;
    await saveGate?.future;
  }

  @override
  Future<BandSetlist> getSetlist(int concertId, int bandId) async {
    setlistLoads++;
    if (loadError case final error?) throw error;
    return setlist;
  }

  @override
  Future<void> saveSetlist(
    int concertId,
    int bandId,
    List<LineupSong> songs,
  ) async {
    setlists.add((concertId, bandId, songs));
    if (saveError case final error?) throw error;
    await saveGate?.future;
  }

  @override
  Future<List<LineupSong>> searchSongs(String keyword) async {
    searches.add(keyword);
    if (loadError case final error?) throw error;
    return [_song];
  }
}

ProviderContainer _container(_Repository repository) {
  final container = ProviderContainer(
    overrides: [lineupRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  const key = (concertId: 1, bandId: 10);

  test('lineup load failure can retry and refresh', () async {
    final repository = _Repository()..loadError = const NetworkException();
    final container = _container(repository);
    container.listen(lineupProvider(1), (_, _) {});
    await expectLater(
      container.read(lineupProvider(1).future),
      throwsA(isA<NetworkException>()),
    );
    repository.loadError = null;
    container.read(lineupProvider(1).notifier).retry();
    expect(await container.read(lineupProvider(1).future), repository.lineup);
    repository.lineup = _lineup([30, 10, 20]);
    await container.read(lineupProvider(1).notifier).refresh();
    expect(container.read(lineupProvider(1)).value, repository.lineup);
    expect(repository.lineupLoads, 3);
  });

  test(
    'final reorder indices send all joined bands and refresh once',
    () async {
      final repository = _Repository()..saveGate = Completer<void>();
      final container = _container(repository);
      container.listen(lineupProvider(1), (_, _) {});
      await container.read(lineupProvider(1).future);
      final notifier = container.read(lineupProvider(1).notifier);
      final pending = notifier.reorder(0, 2);
      expect(container.read(lineupWriteProvider(1)).isSaving, isTrue);
      await notifier.reorder(1, 0);
      await notifier.refresh();
      repository.lineup = _lineup([20, 30, 10]);
      repository.saveGate!.complete();
      await pending;
      expect(repository.orders, hasLength(1));
      expect(repository.orders.single.$1, 1);
      expect(repository.orders.single.$2, [20, 30, 10]);
      expect(repository.lineupLoads, 2);
      expect(container.read(lineupProvider(1)).value, repository.lineup);
      expect(container.read(lineupWriteProvider(1)).isSaving, isFalse);
      await notifier.reorder(-1, 0);
      await notifier.reorder(0, 3);
      await notifier.reorder(1, 1);
      expect(repository.orders, hasLength(1));
    },
  );

  test(
    'reorder failure retains data, releases lock and permits retry',
    () async {
      final repository = _Repository()..saveError = const NetworkException();
      final container = _container(repository);
      container.listen(lineupProvider(1), (_, _) {});
      final initial = await container.read(lineupProvider(1).future);
      final notifier = container.read(lineupProvider(1).notifier);
      await notifier.reorder(2, 0);
      expect(container.read(lineupProvider(1)).value, initial);
      expect(
        container.read(lineupWriteProvider(1)).error,
        isA<NetworkException>(),
      );
      expect(repository.lineupLoads, 1);
      repository.saveError = null;
      await notifier.reorder(2, 0);
      expect(repository.orders.last.$2, [30, 10, 20]);
      expect(container.read(lineupWriteProvider(1)).error, isNull);
    },
  );

  test('409 message precedes refresh and survives refresh failure', () async {
    final repository = _Repository()
      ..saveError = const ApiException(statusCode: 409);
    final container = _container(repository);
    container.listen(lineupProvider(1), (_, _) {});
    final initial = await container.read(lineupProvider(1).future);
    repository.loadGate = Completer<Lineup>();
    final pending = container.read(lineupProvider(1).notifier).reorder(0, 1);
    // The load gate starts only after the conflict has been reported.
    final announced = Completer<void>();
    container.listen(lineupWriteProvider(1), (_, next) {
      if (next.message != null && !announced.isCompleted) announced.complete();
    });
    await announced.future;
    expect(container.read(lineupWriteProvider(1)).isSaving, isTrue);
    repository.loadGate!.completeError(const NetworkException());
    await pending;
    expect(container.read(lineupProvider(1)).hasError, isTrue);
    expect(container.read(lineupProvider(1)).value, initial);
    expect(container.read(lineupWriteProvider(1)).message, isNotEmpty);
    expect(container.read(lineupWriteProvider(1)).isSaving, isFalse);
    repository.loadGate = null;
    container.read(lineupProvider(1).notifier).retry();
    await container.read(lineupProvider(1).future);
  });

  test('setlist load failure retries and canEdit blocks writes', () async {
    final repository = _Repository()..loadError = const NetworkException();
    final container = _container(repository);
    container.listen(setlistProvider(key), (_, _) {});
    await expectLater(
      container.read(setlistProvider(key).future),
      throwsA(isA<NetworkException>()),
    );
    repository
      ..loadError = null
      ..setlist = const BandSetlist(
        isHost: false,
        canEdit: false,
        band: _band,
        songs: [],
      );
    container.read(setlistProvider(key).notifier).retry();
    await container.read(setlistProvider(key).future);
    expect(
      await container.read(setlistProvider(key).notifier).save([_song]),
      isFalse,
    );
    expect(repository.setlists, isEmpty);
  });

  test(
    'setlist save failure retains data and retry submits one snapshot',
    () async {
      final repository = _Repository()..saveError = const NetworkException();
      final container = _container(repository);
      container.listen(setlistProvider(key), (_, _) {});
      final previous = await container.read(setlistProvider(key).future);
      final notifier = container.read(setlistProvider(key).notifier);
      expect(await notifier.save([_song]), isFalse);
      expect(container.read(setlistProvider(key)).value, previous);
      expect(
        container.read(setlistWriteProvider(key)).error,
        isA<NetworkException>(),
      );
      repository
        ..saveError = null
        ..saveGate = Completer<void>();
      final draft = [_song];
      final pending = notifier.save(draft);
      draft.clear();
      expect(await notifier.save([]), isFalse);
      expect(container.read(setlistWriteProvider(key)).isSaving, isTrue);
      repository.setlist = repository.setlist.copyWith(
        songs: [_song.copyWith(externalUrl: 'https://music.example/track')],
      );
      repository.saveGate!.complete();
      expect(await pending, isTrue);
      expect(repository.setlists, hasLength(2));
      expect(repository.setlists.last.$1, 1);
      expect(repository.setlists.last.$2, 10);
      expect(repository.setlists.last.$3, [_song]);
      expect(
        container.read(setlistProvider(key)).value!.songs.single.externalUrl,
        'https://music.example/track',
      );
      expect(container.read(setlistWriteProvider(key)).error, isNull);
    },
  );

  test(
    'setlist save refreshes lineup preview and isolates family keys',
    () async {
      final repository = _Repository();
      final container = _container(repository);
      const other = (concertId: 2, bandId: 10);
      container.listen(lineupProvider(1), (_, _) {});
      container.listen(lineupProvider(2), (_, _) {});
      container.listen(setlistProvider(key), (_, _) {});
      container.listen(setlistProvider(other), (_, _) {});
      await Future.wait([
        container.read(lineupProvider(1).future),
        container.read(lineupProvider(2).future),
        container.read(setlistProvider(key).future),
        container.read(setlistProvider(other).future),
      ]);
      repository.saveGate = Completer<void>();
      final pending = container.read(setlistProvider(key).notifier).save([
        _song,
      ]);
      expect(container.read(setlistWriteProvider(other)).isSaving, isFalse);
      repository.saveGate!.complete();
      expect(await pending, isTrue);
      await container.read(lineupProvider(1).future);
      expect(repository.lineupLoads, 3);
      expect(container.read(setlistProvider(other)).value!.songs, isEmpty);
      await container.read(setlistProvider(other).notifier).refresh();
      expect(repository.setlistLoads, 4);
    },
  );

  test(
    'successful PUT then failed GET requires reload without resending',
    () async {
      final repository = _Repository()..saveGate = Completer<void>();
      final container = _container(repository);
      container.listen(setlistProvider(key), (_, _) {});
      await container.read(setlistProvider(key).future);
      final notifier = container.read(setlistProvider(key).notifier);
      final pending = notifier.save([_song]);
      repository.loadError = const NetworkException();
      repository.saveGate!.complete();
      expect(await pending, isFalse);
      expect(container.read(setlistProvider(key)).hasError, isTrue);
      expect(
        container.read(setlistProvider(key)).unwrapPrevious().value,
        isNull,
      );
      expect(container.read(setlistWriteProvider(key)).message, isNotEmpty);
      expect(await notifier.save([_song]), isFalse);
      expect(repository.setlists, hasLength(1));
      repository
        ..loadError = null
        ..setlist = repository.setlist.copyWith(songs: [_song]);
      notifier.retry();
      expect((await container.read(setlistProvider(key).future)).songs, [
        _song,
      ]);
      expect(repository.setlists, hasLength(1));
    },
  );

  test('disposed writes do not refresh or publish late results', () async {
    final repository = _Repository()..saveGate = Completer<void>();
    final container = ProviderContainer(
      overrides: [lineupRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(lineupProvider(1), (_, _) {});
    container.listen(setlistProvider(key), (_, _) {});
    await container.read(lineupProvider(1).future);
    await container.read(setlistProvider(key).future);
    final lineupWrite = container
        .read(lineupProvider(1).notifier)
        .reorder(0, 1);
    final setlistWrite = container.read(setlistProvider(key).notifier).save([
      _song,
    ]);
    container.dispose();
    repository.saveGate!.complete();
    await lineupWrite;
    expect(await setlistWrite, isFalse);
    expect(repository.lineupLoads, 1);
  });

  test(
    'repository replacement discards old write response and resets lock',
    () async {
      final old = _Repository()..saveGate = Completer<void>();
      final container = _container(old);
      container.listen(lineupProvider(1), (_, _) {});
      container.listen(setlistProvider(key), (_, _) {});
      await container.read(lineupProvider(1).future);
      await container.read(setlistProvider(key).future);
      final pending = container.read(lineupProvider(1).notifier).reorder(0, 1);
      final setlistPending = container.read(setlistProvider(key).notifier).save(
        [_song],
      );
      final replacement = _Repository()..lineup = _lineup([30, 20, 10]);
      container.updateOverrides([
        lineupRepositoryProvider.overrideWithValue(replacement),
      ]);
      await container.read(lineupProvider(1).future);
      await container.read(setlistProvider(key).future);
      expect(container.read(lineupWriteProvider(1)).isSaving, isFalse);
      expect(container.read(setlistWriteProvider(key)).isSaving, isFalse);
      old.saveGate!.complete();
      await pending;
      expect(await setlistPending, isFalse);
      expect(container.read(lineupProvider(1)).value, replacement.lineup);
      expect(container.read(setlistProvider(key)).value!.songs, isEmpty);
      expect(old.lineupLoads, 1);
    },
  );

  test(
    'search trims input, isolates keywords and retries failed lookup',
    () async {
      final repository = _Repository();
      final container = _container(repository);
      container.listen(songSearchProvider('  '), (_, _) {});
      expect(await container.read(songSearchProvider('  ').future), isEmpty);
      expect(repository.searches, isEmpty);
      container.listen(songSearchProvider(' A '), (_, _) {});
      container.listen(songSearchProvider('B'), (_, _) {});
      expect(await container.read(songSearchProvider(' A ').future), [_song]);
      expect(await container.read(songSearchProvider('B').future), [_song]);
      expect(repository.searches, ['A', 'B']);
      repository.loadError = const NetworkException();
      container.invalidate(songSearchProvider('B'));
      await expectLater(
        container.read(songSearchProvider('B').future),
        throwsA(isA<NetworkException>()),
      );
      expect(container.read(songSearchProvider(' A ')).value, [_song]);
      repository.loadError = null;
      container.invalidate(songSearchProvider('B'));
      expect(await container.read(songSearchProvider('B').future), [_song]);
    },
  );
}
