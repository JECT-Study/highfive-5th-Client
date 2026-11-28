import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/core/di/locator.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/auth/presentation/views/login_view.dart';
import 'package:highfive/features/home/presentation/views/home_view.dart';
import 'package:highfive/features/lineup/data/repositories/fake_lineup_repository.dart';
import 'package:highfive/features/lineup/data/repositories/lineup_repository.dart';
import 'package:highfive/features/lineup/presentation/views/lineup_view.dart';
import 'package:highfive/features/lineup/presentation/views/setlist_view.dart';
import 'package:highfive/features/lineup/presentation/widgets/lineup_slot_settings.dart';
import 'package:highfive/features/lineup/presentation/widgets/song_add_sheet.dart';

class _Session extends SessionViewModel {
  _Session(this.restored);
  final Future<Session?> restored;

  @override
  Future<Session?> build() => restored;

  @override
  Future<void> signIn(Session session) async => state = AsyncData(session);

  @override
  Future<void> signOut() async => state = const AsyncData(null);
}

Future<ProviderContainer> _start(
  WidgetTester tester, {
  Future<Session?>? restored,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  getIt.registerFactory<LineupRepository>(FakeLineupRepository.new);
  addTearDown(() => getIt.reset());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(
          const AppEnv(
            flavor: Flavor.prod,
            apiBaseUrl: 'https://example.invalid',
            kakaoNativeAppKey: '',
            googleIosClientId: '',
            googleServerClientId: '',
          ),
        ),
        sessionProvider.overrideWith(
          () => _Session(
            restored ?? Future.value(const Session(accessToken: 'a')),
          ),
        ),
      ],
      child: const HighfiveApp(),
    ),
  );
  return ProviderScope.containerOf(tester.element(find.byType(HighfiveApp)));
}

void main() {
  for (final path in [
    AppRoutes.showLineupOf(1),
    AppRoutes.showSetlistOf('1', '3'),
  ]) {
    testWidgets('cold restore retains $path', (tester) async {
      final restored = Completer<Session?>();
      final container = await _start(tester, restored: restored.future);
      final router = container.read(routerProvider);
      router.go(path);
      await tester.pump();
      restored.complete(const Session(accessToken: 'a'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, path);
    });
  }

  testWidgets(
    'required authentication and terms retain only known destination',
    (tester) async {
      final container = await _start(tester, restored: Future.value(null));
      await tester.pumpAndSettle();
      final router = container.read(routerProvider);
      final session = container.read(sessionProvider.notifier);
      router.go(AppRoutes.showSetlistOf('2', '3'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginView), findsOneWidget);
      await session.signIn(
        const Session(accessToken: 'a', nextStep: NextStep.terms),
      );
      await tester.pumpAndSettle();
      await session.signIn(const Session(accessToken: 'a'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, AppRoutes.showSetlistOf('2', '3'));
    },
  );

  for (final path in [
    AppRoutes.showSetlistOf('1', 'bad'),
    AppRoutes.showLineupOf(0),
    AppRoutes.showOf('1'),
    '//example.com/shows/1/lineup',
  ]) {
    testWidgets('authentication does not restore invalid or unknown $path', (
      tester,
    ) async {
      final container = await _start(tester, restored: Future.value(null));
      await tester.pumpAndSettle();
      final router = container.read(routerProvider);
      router.go(path);
      await tester.pumpAndSettle();
      await container
          .read(sessionProvider.notifier)
          .signIn(const Session(accessToken: 'a'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeView), findsOneWidget);
    });
  }

  testWidgets('cancelled terms never restores the previous destination', (
    tester,
  ) async {
    final container = await _start(tester, restored: Future.value(null));
    await tester.pumpAndSettle();
    final router = container.read(routerProvider);
    final session = container.read(sessionProvider.notifier);
    router.go(AppRoutes.showLineupOf(1));
    await tester.pumpAndSettle();
    await session.signIn(
      const Session(accessToken: 'a', nextStep: NextStep.terms),
    );
    await tester.pumpAndSettle();
    await session.signOut();
    await tester.pumpAndSettle();
    await session.signIn(const Session(accessToken: 'b'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets(
    'explicit signout does not recapture the visible protected page',
    (tester) async {
      final container = await _start(tester);
      await tester.pumpAndSettle();
      container.read(routerProvider).go(AppRoutes.showSetlistOf('1', '3'));
      await tester.pumpAndSettle();
      final session = container.read(sessionProvider.notifier);
      await session.signOut();
      await tester.pumpAndSettle();
      await session.signIn(const Session(accessToken: 'b'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeView), findsOneWidget);
    },
  );

  testWidgets('direct entry back goes setlist then lineup then home', (
    tester,
  ) async {
    final container = await _start(tester);
    await tester.pumpAndSettle();
    container.read(routerProvider).go(AppRoutes.showSetlistOf('2', '3'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SetlistView.backKey));
    await tester.pumpAndSettle();
    expect(find.byType(LineupView), findsOneWidget);
    expect(tester.widget<LineupView>(find.byType(LineupView)).concertId, 2);
    await tester.tap(find.byKey(LineupView.backKey));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('system back from direct entry reaches lineup then home', (
    tester,
  ) async {
    final container = await _start(tester);
    await tester.pumpAndSettle();
    container.read(routerProvider).go(AppRoutes.showSetlistOf('2', '3'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LineupView), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  for (final changeSession in [false, true]) {
    testWidgets(
      'open song sheet is removed on ${changeSession ? 'session' : 'page ID'} change',
      (tester) async {
        final container = await _start(tester);
        await tester.pumpAndSettle();
        final router = container.read(routerProvider);
        router.go(AppRoutes.showSetlistOf('1', '3'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(SetlistView.emptyAddKey));
        await tester.pumpAndSettle();
        expect(find.byType(SongAddSheet), findsOneWidget);
        await tester.enterText(find.byType(EditableText), 'old draft');
        if (changeSession) {
          await container
              .read(sessionProvider.notifier)
              .signIn(const Session(accessToken: 'b'));
        } else {
          router.go(AppRoutes.showSetlistOf('2', '3'));
        }
        await tester.pumpAndSettle();
        expect(find.byType(SongAddSheet), findsNothing);
        expect(find.byKey(SetlistView.doneKey), findsNothing);
        expect(find.byKey(SetlistView.emptyAddKey), findsOneWidget);
      },
    );

    testWidgets(
      'open slot settings is removed on ${changeSession ? 'session' : 'page ID'} change',
      (tester) async {
        final container = await _start(tester);
        await tester.pumpAndSettle();
        final router = container.read(routerProvider);
        router.go(AppRoutes.showLineupOf(1));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(LineupView.positionKey(1)));
        await tester.pumpAndSettle();
        expect(find.byType(LineupSlotSettings), findsOneWidget);
        if (changeSession) {
          await container
              .read(sessionProvider.notifier)
              .signIn(const Session(accessToken: 'b'));
        } else {
          router.go(AppRoutes.showLineupOf(2));
        }
        await tester.pumpAndSettle();
        expect(find.byType(LineupSlotSettings), findsNothing);
        expect(find.byType(LineupView), findsOneWidget);
      },
    );
  }
}
