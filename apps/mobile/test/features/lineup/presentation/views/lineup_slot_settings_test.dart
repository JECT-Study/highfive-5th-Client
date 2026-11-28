import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/lineup/data/repositories/fake_lineup_repository.dart';
import 'package:highfive/features/lineup/models/lineup.dart';
import 'package:highfive/features/lineup/presentation/providers/lineup_providers.dart';
import 'package:highfive/features/lineup/presentation/view_models/lineup_view_models.dart';
import 'package:highfive/features/lineup/presentation/views/lineup_view.dart';
import 'package:highfive/features/lineup/presentation/widgets/lineup_slot_settings.dart';
import 'package:highfive/shared/theme/app_theme.dart';

class _Repository extends FakeLineupRepository {
  final writes = <List<int>>[];
  bool removed = false;
  int reads = 0;

  @override
  Future<Lineup> getLineup(int concertId) async {
    reads++;
    final lineup = await super.getLineup(concertId);
    return removed
        ? lineup.copyWith(
            teams: lineup.teams
                .where((team) => team.band.bandId != 12)
                .toList(),
          )
        : lineup;
  }

  @override
  Future<void> saveLineup(int concertId, List<int> bandIds) async {
    writes.add(List.of(bandIds));
    await super.saveLineup(concertId, bandIds);
  }
}

Future<ProviderContainer> _open(
  WidgetTester tester,
  _Repository repository,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [lineupRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        home: LineupView(concertId: 1, onOpenSetlist: (_) async {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(LineupView)));
}

Future<void> _tap(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> _select(WidgetTester tester, int target, int bandId) async {
  await _tap(tester, LineupView.positionKey(target));
  await _tap(tester, LineupSlotSettings.pickerKey);
  await _tap(tester, LineupSlotSettings.optionKey(bandId));
  await _tap(tester, LineupSlotSettings.loadKey);
}

void main() {
  testWidgets('길게 누르지 않고 카드를 스크롤하면 순서를 저장하지 않는다', (tester) async {
    final repository = _Repository();
    await _open(tester, repository);
    await tester.drag(
      find.byKey(LineupView.dragHandleKey(3)),
      const Offset(0, 160),
    );
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
  });

  testWidgets('밴드를 선택한 뒤 취소하면 순서 쓰기가 없다', (tester) async {
    final repository = _Repository();
    await _open(tester, repository);
    await _select(tester, 1, 12);
    expect(repository.writes, isEmpty);
    await _tap(tester, LineupSlotSettings.backKey);
    expect(repository.writes, isEmpty);
    expect(
      (await repository.getLineup(1)).teams.map((team) => team.band.bandId),
      [3, 7, 12],
    );
  });

  for (final move in [
    (target: 0, band: 12, order: [12, 3, 7]),
    (target: 2, band: 3, order: [7, 12, 3]),
  ]) {
    testWidgets('저장은 기존 밴드 ${move.band}를 ${move.target} 위치로 옮기고 전원을 보존한다', (
      tester,
    ) async {
      final repository = _Repository();
      await _open(tester, repository);
      await _select(tester, move.target, move.band);
      await _tap(tester, LineupSlotSettings.saveKey);
      expect(repository.writes, [move.order]);
      expect(
        (await repository.getLineup(1)).teams.map((team) => team.band.bandId),
        move.order,
      );
      expect(find.byKey(LineupView.emptySlotKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final membershipChanged in [false, true]) {
    testWidgets(
      '선택 중 ${membershipChanged ? '팀 구성' : '순서'}이 바뀌면 저장을 취소하고 다시 읽는다',
      (tester) async {
        final repository = _Repository();
        final container = await _open(tester, repository);
        await _select(tester, 1, 12);
        if (membershipChanged) {
          repository.removed = true;
        } else {
          await repository.saveLineup(1, [7, 3, 12]);
          repository.writes.clear();
        }
        await container.read(lineupProvider(1).notifier).refresh();
        await tester.pumpAndSettle();
        final reads = repository.reads;
        await _tap(tester, LineupSlotSettings.saveKey);
        expect(repository.writes, isEmpty);
        expect(repository.reads, reads + 1);
        expect(find.byType(LineupSlotSettings), findsNothing);
      },
    );
  }
}
