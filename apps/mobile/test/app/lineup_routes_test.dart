import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/core/di/locator.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/home/presentation/views/home_view.dart';
import 'package:highfive/features/lineup/data/repositories/fake_lineup_repository.dart';
import 'package:highfive/features/lineup/data/repositories/lineup_repository.dart';
import 'package:highfive/features/lineup/presentation/providers/lineup_providers.dart';
import 'package:highfive/features/lineup/presentation/views/lineup_view.dart';
import 'package:highfive/features/lineup/presentation/views/setlist_view.dart';

/// 네이티브 로그인 없이 실제 라우터와 세션 단위 저장소 연결을 실행한다.
class _Session extends SessionViewModel {
  @override
  Future<Session?> build() async => const Session(accessToken: 'fixture-a');

  @override
  Future<void> signIn(Session session) async => state = AsyncData(session);
}

const _boundary = ValueKey('lineup_capture');

Future<ProviderContainer> _open(WidgetTester tester, String path) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  const env = AppEnv(
    flavor: Flavor.prod,
    apiBaseUrl: 'https://example.invalid',
    kakaoNativeAppKey: '',
    googleIosClientId: '',
    googleServerClientId: '',
  );
  getIt.registerFactory<LineupRepository>(FakeLineupRepository.new);
  addTearDown(() => getIt.reset());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(env),
        sessionProvider.overrideWith(_Session.new),
      ],
      child: const RepaintBoundary(key: _boundary, child: HighfiveApp()),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(HighfiveApp)),
  );
  container.read(routerProvider).go(path);
  await tester.pumpAndSettle();
  return container;
}

/// LINEUP_CAPTURE_DIR를 주면 같은 상호작용에서 PR용 실제 렌더를 남긴다.
Future<void> _capture(WidgetTester tester, String name) async {
  final path = Platform.environment['LINEUP_CAPTURE_DIR'];
  if (path == null) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundary),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$path/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (Platform.environment.containsKey('LINEUP_CAPTURE_DIR')) {
      final loader = FontLoader('Pretendard');
      for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        loader.addFont(
          rootBundle.load('assets/fonts/pretendard/Pretendard-$weight.otf'),
        );
      }
      await loader.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });

  testWidgets('잘못된 공연·밴드 딥링크는 홈으로 돌아간다', (tester) async {
    final container = await _open(tester, AppRoutes.showSetlistOf('1', 'bad'));
    expect(find.byType(HomeView), findsOneWidget);
    container.read(routerProvider).go(AppRoutes.showLineupOf(0));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('계정이 바뀌면 이전 공연 순서가 다음 세션에 남지 않는다', (tester) async {
    final container = await _open(tester, AppRoutes.showLineupOf(1));
    expect(find.byType(LineupView), findsOneWidget);
    final previous = container.read(lineupRepositoryProvider);
    final initial = (await previous.getLineup(1)).teams
        .map((team) => team.band.bandId)
        .toList();
    await previous.saveLineup(1, initial.reversed.toList());
    await container
        .read(sessionProvider.notifier)
        .signIn(const Session(accessToken: 'fixture-b'));
    await tester.pumpAndSettle();
    final next = container.read(lineupRepositoryProvider);
    expect((await next.getLineup(1)).teams.map((t) => t.band.bandId), initial);
  });

  testWidgets('다른 공연으로 바로 이동하면 이전 화면의 미저장 초안을 버린다', (tester) async {
    final container = await _open(tester, AppRoutes.showSetlistOf('1', '3'));
    await tester.tap(find.byKey(SetlistView.emptyAddKey));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), '이 공연만의 초안');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('songAdd_original')));
    await tester.pumpAndSettle();
    expect(find.byKey(SetlistView.doneKey), findsOneWidget);
    container.read(routerProvider).go(AppRoutes.showSetlistOf('2', '3'));
    await tester.pumpAndSettle();
    expect(find.byKey(SetlistView.emptyAddKey), findsOneWidget);
    expect(find.byKey(SetlistView.doneKey), findsNothing);
  });

  testWidgets('라인업 순서를 옮기고 두 종류의 곡을 저장한 뒤 다시 연다', (tester) async {
    final container = await _open(tester, AppRoutes.showLineupOf(1));
    Finder key(String id) => find.byKey(ValueKey(id));
    Future<void> tap(String id) async {
      await tester.ensureVisible(key(id));
      await tester.tap(key(id));
      await tester.pumpAndSettle();
    }

    final repo = container.read(lineupRepositoryProvider);
    await tap('lineup_position_1');
    await _capture(tester, 'position');
    await tap('lineupSlot_picker');
    await tap('lineupSlot_option_3');
    await _capture(tester, 'picker');
    await tap('lineupSlot_load');
    await _capture(tester, 'selection');
    await tap('lineupSlot_back');
    expect((await repo.getLineup(1)).teams.first.band.bandId, 3);
    final handle = key('lineup_dragHandle_3');
    final distance =
        tester.getCenter(key('lineup_dragHandle_7')).dy -
        tester.getCenter(handle).dy;
    final drag = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(kLongPressTimeout);
    for (var step = 0; step < 10; step++) {
      await drag.moveBy(Offset(0, (distance + 12) / 10));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    await drag.up();
    await tester.pumpAndSettle();
    expect((await repo.getLineup(1)).teams.first.band.bandId, 7);
    await _capture(tester, 'lineup');
    await tap('lineup_team_3');
    expect(find.byType(SetlistView), findsOneWidget);
    await _capture(tester, 'empty');
    await tap('setlist_emptyAdd');
    final field = find.descendant(
      of: key('songAdd_query'),
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, 'Oasis');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await _capture(tester, 'search');
    await tap('songAdd_resultAdd_0');
    final again = tester.getSemantics(key('songAdd_resultAdd_0'));
    expect(again.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
    again.owner!.performAction(again.id, ui.SemanticsAction.tap);
    await tester.pumpAndSettle();
    await tester.enterText(field, '새벽의 노래');
    tester.view.physicalSize = const Size(320, 680);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(key('songAdd_original'));
    await tester.pumpAndSettle();
    expect(
      tester.getBottomRight(key('songAdd_original')).dy,
      lessThanOrEqualTo(420),
    );
    await tap('songAdd_original');
    tester.view.resetViewInsets();
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect((await repo.getSetlist(1, 3)).songs, isEmpty);
    await tap('setlist_done');
    expect((await repo.getSetlist(1, 3)).songs.map((s) => s.songTitle), [
      'Wonderwall',
      'Wonderwall',
      '새벽의 노래',
    ]);
    await tap('setlist_back');
    await tap('lineup_team_3');
    expect(key('setlist_song_1'), findsOneWidget);
    await _capture(tester, 'setlist');
    await tap('setlist_edit');
    await tap('setlist_remove_0');
    await tap('setlist_back');
    expect(key('setlist_song_1'), findsOneWidget);
    await tap('setlist_edit');
    final last = key('setlist_dragHandle_2');
    for (final control in [last, key('setlist_remove_2')]) {
      final size = tester.getSize(control);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    }
    final toFirst =
        tester.getCenter(key('setlist_dragHandle_0')).dy -
        tester.getCenter(last).dy;
    final songDrag = await tester.startGesture(tester.getCenter(last));
    await tester.pump();
    for (var step = 0; step < 10; step++) {
      await songDrag.moveBy(Offset(0, (toFirst - 12) / 10));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    await songDrag.up();
    await tester.pumpAndSettle();
    await tap('setlist_remove_2');
    await tap('setlist_done');
    expect((await repo.getSetlist(1, 3)).songs.map((s) => s.songTitle), [
      '새벽의 노래',
      'Wonderwall',
    ]);
    await tap('setlist_back');
    await tap('lineup_team_7');
    expect(key('setlist_edit'), findsNothing);
    expect((await repo.getSetlist(2, 3)).songs, isEmpty);
  });
}
