import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/lineup_route_scope.dart';
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
import 'package:highfive/shared/theme/app_theme.dart';

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
  TargetPlatform? platform,
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
      child: platform == null
          ? const HighfiveApp()
          : Consumer(
              builder: (context, ref, child) => MaterialApp.router(
                theme: AppTheme.light.copyWith(platform: platform),
                routerConfig: ref.watch(routerProvider),
              ),
            ),
    ),
  );
  return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
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

  for (final path in [
    AppRoutes.showLineupOf(1),
    AppRoutes.showSetlistOf('1', '3'),
  ]) {
    testWidgets('cold restore strips query and fragment from $path', (
      tester,
    ) async {
      final restored = Completer<Session?>();
      final container = await _start(tester, restored: restored.future);
      final router = container.read(routerProvider);
      router.go('$path?from=share&redirect=https%3A%2F%2Fevil.invalid#song');
      await tester.pump();
      restored.complete(const Session(accessToken: 'a'));
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), path);
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
    'https://example.com/shows/1/lineup?from=share#song',
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

  testWidgets('iOS edge gesture pops a pushed setlist in viewing mode', (
    tester,
  ) async {
    final container = await _start(tester, platform: TargetPlatform.iOS);
    await tester.pumpAndSettle();
    final router = container.read(routerProvider);
    router.go(AppRoutes.showLineupOf(1));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(LineupView.teamKey(3)));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(SetlistView))).platform,
      TargetPlatform.iOS,
    );
    expect(
      tester.widget<SetlistView>(find.byType(SetlistView)).canPopRoute,
      isTrue,
    );
    final route =
        ModalRoute.of(tester.element(find.byType(LineupRouteScope).last))!
            as PageRoute<void>;
    expect(route.isFirst, isFalse);
    expect(route.popDisposition, RoutePopDisposition.pop);
    expect(route.popGestureEnabled, isTrue);

    final gesture = await tester.startGesture(const Offset(1, 400));
    await gesture.moveBy(
      const Offset(20, 0),
      timeStamp: const Duration(milliseconds: 30),
    );
    await gesture.moveTo(
      const Offset(300, 400),
      timeStamp: const Duration(milliseconds: 300),
    );
    await tester.pump();
    expect(route.navigator!.userGestureInProgress, isTrue);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(SetlistView), findsNothing);
    expect(find.byType(LineupView), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.showLineupOf(1));
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets(
    'iOS editing blocks edge pop and back cancels draft before gesture exit',
    (tester) async {
      final container = await _start(tester, platform: TargetPlatform.iOS);
      await tester.pumpAndSettle();
      final router = container.read(routerProvider);
      router.go(AppRoutes.showLineupOf(1));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(LineupView.teamKey(3)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SetlistView.emptyAddKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'unsaved draft');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('songAdd_original')));
      await tester.pumpAndSettle();

      await tester.dragFrom(const Offset(1, 400), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.byType(SetlistView), findsOneWidget);
      expect(find.byKey(SetlistView.doneKey), findsOneWidget);
      await tester.tap(find.byKey(SetlistView.backKey));
      await tester.pumpAndSettle();
      expect(find.byKey(SetlistView.doneKey), findsNothing);
      expect(find.byKey(SetlistView.emptyAddKey), findsOneWidget);

      await tester.dragFrom(const Offset(1, 400), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.byType(SetlistView), findsNothing);
      expect(router.state.uri.path, AppRoutes.showLineupOf(1));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

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
