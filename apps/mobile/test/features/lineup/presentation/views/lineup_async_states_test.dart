import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/lineup/data/repositories/lineup_repository.dart';
import 'package:highfive/features/lineup/models/lineup.dart';
import 'package:highfive/features/lineup/presentation/providers/lineup_providers.dart';
import 'package:highfive/features/lineup/presentation/views/lineup_view.dart';
import 'package:highfive/features/lineup/presentation/views/setlist_view.dart';
import 'package:highfive/features/lineup/presentation/widgets/song_add_sheet.dart';
import 'package:highfive/features/lineup/presentation/widgets/song_row.dart';
import 'package:highfive/shared/theme/app_theme.dart';

class _ControlledRepository implements LineupRepository {
  final lineups = <Completer<Lineup>>[];
  final setlists = <Completer<BandSetlist>>[];
  final searches = <Completer<List<LineupSong>>>[];

  @override
  Future<Lineup> getLineup(int concertId) {
    final request = Completer<Lineup>();
    lineups.add(request);
    return request.future;
  }

  @override
  Future<BandSetlist> getSetlist(int concertId, int bandId) {
    final request = Completer<BandSetlist>();
    setlists.add(request);
    return request.future;
  }

  @override
  Future<List<LineupSong>> searchSongs(String keyword) {
    final request = Completer<List<LineupSong>>();
    searches.add(request);
    return request.future;
  }

  @override
  Future<void> saveLineup(int concertId, List<int> bandIds) =>
      throw UnsupportedError('This scenario must not save a lineup.');

  @override
  Future<void> saveSetlist(int concertId, int bandId, List<LineupSong> songs) =>
      throw UnsupportedError('This scenario must not save a setlist.');
}

const _band = LineupBand(
  bandId: 17,
  name: 'Recovery band',
  genres: [],
  memberCount: 3,
);
const _song = LineupSong(
  type: SongType.searched,
  songTitle: 'Recovered song',
  trackId: 'track-17',
  artist: 'Recovery artist',
);
const _team = LineupTeam(
  concertTeamId: 29,
  lineupOrder: 1,
  isHost: true,
  band: _band,
  setlistPreview: [],
  setlistTotalCount: 0,
);

Future<void> _open(
  WidgetTester tester,
  _ControlledRepository repository,
  Widget home,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [lineupRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: AppTheme.light, home: home),
    ),
  );
}

Future<void> _openSearch(
  WidgetTester tester,
  _ControlledRepository repository,
) async {
  await _open(tester, repository, const SetlistView(concertId: 5, bandId: 17));
  repository.setlists.single.complete(
    const BandSetlist(isHost: true, canEdit: true, band: _band, songs: []),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(SetlistView.emptyAddKey));
  await tester.pumpAndSettle();
  expect(find.byKey(SongAddSheet.sheetKey), findsOneWidget);
}

Future<void> _submitSearch(WidgetTester tester) async {
  await tester.showKeyboard(find.byKey(SongAddSheet.queryKey));
  await tester.testTextInput.receiveAction(TextInputAction.search);
  // Flush provider invalidation and its resulting rebuild without waiting for
  // the progress indicator (the repository request is deliberately pending).
  await tester.pump();
  await tester.pump();
}

void main() {
  for (final empty in [true, false]) {
    testWidgets(
      'lineup retries a failed load into ${empty ? 'empty' : 'data'}',
      (tester) async {
        final repository = _ControlledRepository();
        await _open(
          tester,
          repository,
          LineupView(concertId: 5, onOpenSetlist: (_) async {}),
        );
        expect(find.byKey(LineupView.loadingKey), findsOneWidget);
        expect(find.byKey(LineupView.emptyKey), findsNothing);
        expect(find.byKey(LineupView.errorKey), findsNothing);

        repository.lineups.single.completeError(
          StateError('lineup unavailable'),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(LineupView.loadingKey), findsNothing);
        expect(find.byKey(LineupView.errorKey), findsOneWidget);
        expect(find.byKey(LineupView.emptyKey), findsNothing);

        await tester.tap(find.byKey(LineupView.retryKey));
        await tester.pump();
        await tester.pump();
        expect(repository.lineups, hasLength(2));
        expect(find.byKey(LineupView.loadingKey), findsOneWidget);
        expect(find.byKey(LineupView.errorKey), findsNothing);
        repository.lineups.last.complete(
          Lineup(teams: empty ? [] : [_team], emptySlotCount: 0),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(LineupView.loadingKey), findsNothing);
        expect(find.byKey(LineupView.errorKey), findsNothing);
        expect(
          find.byKey(LineupView.emptyKey),
          empty ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(LineupView.teamKey(17)),
          empty ? findsNothing : findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'setlist retries a failed load into ${empty ? 'empty' : 'data'}',
      (tester) async {
        final repository = _ControlledRepository();
        await _open(
          tester,
          repository,
          const SetlistView(concertId: 5, bandId: 17),
        );
        expect(find.byKey(SetlistView.loadingKey), findsOneWidget);
        expect(find.byKey(SetlistView.emptyKey), findsNothing);
        expect(find.byKey(SetlistView.errorKey), findsNothing);

        repository.setlists.single.completeError(
          StateError('setlist unavailable'),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(SetlistView.loadingKey), findsNothing);
        expect(find.byKey(SetlistView.errorKey), findsOneWidget);
        expect(find.byKey(SetlistView.emptyKey), findsNothing);

        await tester.tap(find.byKey(SetlistView.retryKey));
        await tester.pump();
        await tester.pump();
        expect(repository.setlists, hasLength(2));
        expect(find.byKey(SetlistView.loadingKey), findsOneWidget);
        expect(find.byKey(SetlistView.errorKey), findsNothing);
        repository.setlists.last.complete(
          BandSetlist(
            isHost: true,
            canEdit: true,
            band: _band,
            songs: empty ? [] : [_song],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(SetlistView.loadingKey), findsNothing);
        expect(find.byKey(SetlistView.errorKey), findsNothing);
        expect(
          find.byKey(SetlistView.emptyKey),
          empty ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(SetlistView.songKey(0)),
          empty ? findsNothing : findsOneWidget,
        );
        if (!empty) {
          expect(
            tester.widget<SongRow>(find.byType(SongRow)).title,
            _song.songTitle,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'song search retries failure into ${empty ? 'empty' : 'data'}',
      (tester) async {
        final repository = _ControlledRepository();
        await _openSearch(tester, repository);
        await tester.enterText(find.byKey(SongAddSheet.queryKey), 'Recovery');
        await _submitSearch(tester);
        expect(find.byKey(SongAddSheet.loadingKey), findsOneWidget);
        expect(find.byKey(SongAddSheet.noResultKey), findsNothing);

        repository.searches.single.completeError(
          StateError('search unavailable'),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(SongAddSheet.errorKey), findsOneWidget);
        expect(find.byKey(SongAddSheet.loadingKey), findsNothing);
        expect(find.byKey(SongAddSheet.noResultKey), findsNothing);

        // The sheet retries through the keyboard search action, not a separate
        // retry button. Re-submit exactly the same query to exercise invalidation.
        await _submitSearch(tester);
        expect(repository.searches, hasLength(2));
        expect(find.byKey(SongAddSheet.loadingKey), findsOneWidget);
        expect(find.byKey(SongAddSheet.errorKey), findsNothing);
        repository.searches.last.complete(empty ? [] : [_song]);
        await tester.pumpAndSettle();

        expect(find.byKey(SongAddSheet.loadingKey), findsNothing);
        expect(find.byKey(SongAddSheet.errorKey), findsNothing);
        expect(
          find.byKey(SongAddSheet.noResultKey),
          empty ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(SongAddSheet.resultKey(0)),
          empty ? findsNothing : findsOneWidget,
        );
        if (!empty) {
          final row = tester.widget<SongRow>(
            find.byKey(SongAddSheet.resultKey(0)),
          );
          expect(row.title, _song.songTitle);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('failed search can still add the entered original to the draft', (
    tester,
  ) async {
    final repository = _ControlledRepository();
    await _openSearch(tester, repository);
    const title = 'My original song';
    await tester.enterText(find.byKey(SongAddSheet.queryKey), title);
    await _submitSearch(tester);
    repository.searches.single.completeError(StateError('search unavailable'));
    await tester.pumpAndSettle();
    expect(find.byKey(SongAddSheet.errorKey), findsOneWidget);

    await tester.ensureVisible(find.byKey(SongAddSheet.originalKey));
    await tester.tap(find.byKey(SongAddSheet.originalKey));
    await tester.pumpAndSettle();

    expect(find.byKey(SongAddSheet.sheetKey), findsNothing);
    expect(find.byKey(SetlistView.doneKey), findsOneWidget);
    expect(find.byKey(SetlistView.songKey(0)), findsOneWidget);
    expect(tester.widget<SongRow>(find.byType(SongRow)).title, title);
    expect(find.byKey(SetlistView.removeKey(0)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
