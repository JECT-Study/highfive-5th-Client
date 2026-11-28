import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:highfive/app/concert_session_scope.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/core/di/locator.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_management_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_management_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';
import 'package:highfive/features/performances/models/concert_status.dart';
import 'package:highfive/features/performances/models/concert_management_failure.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_management_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_detail_view.dart';
import 'package:highfive/features/performances/presentation/view_models/concert_management_view_model.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/show/show_confirm_popup.dart';
import 'package:highfive/shared/widgets/show/show_team_avatar.dart';

final _host = FakeConcertRepository.sample.copyWith(
  myPermissions: const ConcertPermissions(
    isHostLeader: true,
    isTeamLeader: true,
  ),
);
final _captureKey = GlobalKey();

enum _Dismissal { confirm, barrier, systemBack }

class _Session extends SessionViewModel {
  @override
  Future<Session?> build() async => const Session(accessToken: 'fixture-a');

  void switchAccount() =>
      state = const AsyncData(Session(accessToken: 'fixture-b'));
}

class _MutableDetail implements ConcertRepository {
  ConcertDetail value = _host;

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async => value;
}

class _HeldManagement extends FakeConcertManagementRepository {
  _HeldManagement({ConcertRepository? details})
    : super(
        details ?? FakeConcertRepository(concerts: [_host]),
        FakeConcertParticipantsRepository(),
      );

  final response = Completer<void>();

  @override
  Future<void> deleteConcert(int concertId) async {
    await response.future;
    await super.deleteConcert(concertId);
  }

  @override
  Future<void> removeBand(int concertId, int bandId) async {
    await response.future;
    await super.removeBand(concertId, bandId);
  }
}

class _HeldRefreshRoster extends FakeConcertParticipantsRepository {
  var hold = false;
  final response = Completer<List<ConcertParticipant>>();

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) =>
      hold ? response.future : super.fetchParticipants(concertId);
}

class _HeldRefreshManagement extends FakeConcertManagementRepository {
  _HeldRefreshManagement(this.roster)
    : super(FakeConcertRepository(concerts: [_host]), roster);

  final _HeldRefreshRoster roster;
  var writes = 0;

  @override
  Future<void> removeBand(int concertId, int bandId) async {
    writes++;
    await super.removeBand(concertId, bandId);
    roster.hold = true;
  }
}

Future<GoRouter> _pump(
  WidgetTester tester, {
  ConcertDetail? fixture,
  bool sessionScoped = false,
  FakeConcertManagementRepository? repository,
  FakeConcertManagementRepository Function()? sessionFactory,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final store =
      repository ??
      FakeConcertManagementRepository(
        FakeConcertRepository(concerts: [fixture ?? _host]),
        FakeConcertParticipantsRepository(),
      );
  final router = GoRouter(
    initialLocation: AppRoutes.showOf('12'),
    routes: [
      GoRoute(
        path: AppRoutes.my,
        builder: (context, state) => const Scaffold(
          key: ValueKey('fixture_previous'),
          body: SizedBox.shrink(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(
          key: ValueKey('fixture_home'),
          body: SizedBox.shrink(),
        ),
      ),
      concertShowRoute(),
    ],
  );
  addTearDown(router.dispose);
  if (sessionScoped) {
    getIt.registerFactory<ConcertManagementRepository>(
      sessionFactory ??
          () => FakeConcertManagementRepository(
            FakeConcertRepository(concerts: [fixture ?? _host]),
            FakeConcertParticipantsRepository(),
          ),
    );
    addTearDown(getIt.reset);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (sessionScoped) sessionProvider.overrideWith(_Session.new),
        if (!sessionScoped) ...[
          concertRepositoryProvider.overrideWithValue(store),
          concertParticipantsRepositoryProvider.overrideWithValue(store),
          concertManagementRepositoryProvider.overrideWithValue(store),
        ],
      ],
      child: RepaintBoundary(
        key: _captureKey,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: router,
          builder: sessionScoped
              ? (context, child) => ConcertSessionScope(child: child!)
              : null,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Finder _popupAction({required bool confirm}) => find
    .descendant(
      of: find.byType(ShowConfirmPopup),
      matching: find.byType(AppButton),
    )
    .at(confirm ? 1 : 0);

Future<void> _capture(WidgetTester tester, String name) async {
  final directory = Platform.environment['JECT151_EVIDENCE_DIR'];
  if (directory == null) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$directory/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    final font = FontLoader('Pretendard')
      ..addFont(
        rootBundle.load('assets/fonts/pretendard/Pretendard-Regular.otf'),
      )
      ..addFont(rootBundle.load('assets/fonts/pretendard/Pretendard-Bold.otf'));
    await font.load();
  });

  testWidgets('삭제 직전 알 수 없는 상태로 바뀌면 판매 시작 대신 상태 확인 실패를 알린다', (tester) async {
    final details = _MutableDetail();
    final store = _HeldManagement(details: details);
    await _pump(tester, repository: store);
    await tester.ensureVisible(find.byKey(const ValueKey('concert_delete')));
    await tester.tap(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();
    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();

    details.value = _host.copyWith(status: ConcertStatus.unknown);
    store.response.complete();
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertDetailView)),
    );
    expect(
      container.read(concertManagementViewModelProvider(12)).failure,
      ConcertManagementFailure.unknownStatus,
    );
    expect(find.byType(ShowConfirmPopup), findsOneWidget);
    await _capture(tester, 'unknown-status-refused');
  });

  testWidgets('성공 후 명단 재조회가 지연되어도 이미 뺀 밴드는 다시 명령하지 않는다', (tester) async {
    final roster = _HeldRefreshRoster();
    final store = _HeldRefreshManagement(roster);
    await _pump(tester, repository: store);
    await tester.ensureVisible(
      find.byKey(const ValueKey('concert_participantsEdit')),
    );
    await tester.tap(find.byKey(const ValueKey('concert_participantsEdit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concert_remove_9001')));
    await tester.pumpAndSettle();

    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('concert_remove_9001')), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertDetailView)),
    );
    await container
        .read(concertManagementViewModelProvider(12).notifier)
        .removeBand(9001);
    expect(store.writes, 1);
    roster.response.complete(FakeConcertParticipantsRepository.sample);
    await tester.pumpAndSettle();
  });

  testWidgets('빼기 응답 전에 화면을 다시 열어도 늦은 성공은 새 명단을 갱신한다', (tester) async {
    final store = _HeldManagement();
    final router = await _pump(tester, repository: store);
    await tester.ensureVisible(
      find.byKey(const ValueKey('concert_participantsEdit')),
    );
    await tester.tap(find.byKey(const ValueKey('concert_participantsEdit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concert_remove_9001')));
    await tester.pumpAndSettle();
    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();
    router.go(AppRoutes.home);
    await tester.pumpAndSettle();
    router.go(AppRoutes.showOf('12'));
    await tester.pumpAndSettle();
    expect(find.byType(ShowTeamAvatar), findsNWidgets(2));

    store.response.complete();
    await tester.pumpAndSettle();

    expect(find.byType(ShowTeamAvatar), findsOneWidget);
    expect(find.byType(ShowConfirmPopup), findsNothing);
  });

  testWidgets('계정 전환 직후 같은 프레임의 이전 삭제 응답은 새 화면을 이동시키지 않는다', (tester) async {
    final stores = <_HeldManagement>[];
    await _pump(
      tester,
      sessionScoped: true,
      sessionFactory: () {
        final store = _HeldManagement();
        stores.add(store);
        return store;
      },
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertSessionScope)),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('concert_delete')));
    await tester.tap(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();
    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();

    (container.read(sessionProvider.notifier) as _Session).switchAccount();
    stores.last.response.complete();
    await tester.pumpAndSettle();

    expect(find.byType(ConcertDetailView), findsOneWidget);
    expect(find.byKey(const ValueKey('fixture_home')), findsNothing);
    expect(find.byType(ShowTeamAvatar), findsNWidgets(2));
  });

  testWidgets('밴드 빼기 확인창을 연 채 계정을 바꾸면 이전 확인창을 닫는다', (tester) async {
    await _pump(tester, sessionScoped: true);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertSessionScope)),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('concert_participantsEdit')),
    );
    await tester.tap(find.byKey(const ValueKey('concert_participantsEdit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concert_remove_9001')));
    await tester.pumpAndSettle();
    expect(find.byType(ShowConfirmPopup), findsOneWidget);

    (container.read(sessionProvider.notifier) as _Session).switchAccount();
    await tester.pumpAndSettle();

    expect(find.byType(ShowConfirmPopup), findsNothing);
    expect(find.byType(ShowTeamAvatar), findsNWidgets(2));
  });

  testWidgets('화면을 떠나는 프레임의 늦은 오류는 이전 화면에 팝업을 띄우지 않는다', (tester) async {
    final store = _HeldManagement();
    final router = await _pump(tester, repository: store);
    await tester.ensureVisible(find.byKey(const ValueKey('concert_delete')));
    await tester.tap(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();
    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();

    router.go(AppRoutes.home);
    store.response.completeError(const NetworkException());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fixture_home')), findsOneWidget);
    expect(find.byType(ShowConfirmPopup), findsNothing);
  });

  for (final dismissal in _Dismissal.values) {
    testWidgets('다른 화면에서 진입한 공연 삭제가 404면 $dismissal 후 홈으로 이동한다', (
      tester,
    ) async {
      final store = _HeldManagement();
      final router = await _pump(tester, repository: store);
      router.go(AppRoutes.my);
      await tester.pumpAndSettle();
      unawaited(router.push(AppRoutes.showOf('12')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('concert_delete')));
      await tester.tap(find.byKey(const ValueKey('concert_delete')));
      await tester.pumpAndSettle();
      await tester.tap(_popupAction(confirm: true));
      await tester.pumpAndSettle();

      store.response.completeError(
        const ApiException(statusCode: 404, code: 'CONCERT_001'),
      );
      await tester.pumpAndSettle();
      switch (dismissal) {
        case _Dismissal.confirm:
          await tester.tap(
            find.descendant(
              of: find.byType(ShowConfirmPopup),
              matching: find.byType(AppButton),
            ),
          );
        case _Dismissal.barrier:
          await tester.tapAt(const Offset(2, 2));
        case _Dismissal.systemBack:
          await tester.binding.handlePopRoute();
      }
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('fixture_home')), findsOneWidget);
      expect(find.byKey(const ValueKey('fixture_previous')), findsNothing);
    });
  }

  testWidgets('같은 공연의 쿼리가 바뀐 뒤 시작한 삭제도 홈으로 이동한다', (tester) async {
    final router = await _pump(tester);
    router.go(
      Uri.parse(AppRoutes.showOf('12'))
          .replace(queryParameters: {'ref': 'feed'})
          .toString(),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('concert_delete')));
    await tester.tap(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();

    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fixture_home')), findsOneWidget);
  });

  testWidgets('일반 참여자는 공연을 보지만 주최자 삭제·밴드 편집은 보이지 않는다', (tester) async {
    await _pump(tester, fixture: FakeConcertRepository.sample);

    expect(find.byType(ShowTeamAvatar), findsNWidgets(2));
    expect(find.byKey(const ValueKey('concert_delete')), findsNothing);
    expect(
      find.byKey(const ValueKey('concert_participantsEdit')),
      findsNothing,
    );
    await _capture(tester, 'ordinary-participant');
  });

  testWidgets('주최자 편집은 참여 밴드만 빼며 취소는 목록을 보존한다', (tester) async {
    await _pump(tester);
    await tester.ensureVisible(
      find.byKey(const ValueKey('concert_participantsEdit')),
    );
    await tester.tap(find.byKey(const ValueKey('concert_participantsEdit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('concert_remove_3')), findsNothing);
    expect(find.byKey(const ValueKey('concert_remove_9001')), findsOneWidget);
    await _capture(tester, 'host-band-edit');
    await tester.tapAt(
      tester.getTopRight(find.byKey(const ValueKey('concert_remove_9001'))) -
          const Offset(1, -1),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ShowConfirmPopup), findsOneWidget);
    await _capture(tester, 'remove-confirmation');
    await tester.tap(_popupAction(confirm: false));
    await tester.pumpAndSettle();

    expect(find.byType(ShowTeamAvatar), findsNWidgets(2));
  });

  testWidgets('빼기 확인 후 다른 경로에서 다시 열어도 밴드가 되살아나지 않는다', (tester) async {
    final router = await _pump(tester);
    await tester.ensureVisible(
      find.byKey(const ValueKey('concert_participantsEdit')),
    );
    await tester.tap(find.byKey(const ValueKey('concert_participantsEdit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concert_remove_9001')));
    await tester.pumpAndSettle();

    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();
    router.go(AppRoutes.home);
    await tester.pumpAndSettle();
    router.go(AppRoutes.showOf('12'));
    await tester.pumpAndSettle();

    expect(find.byType(ShowTeamAvatar), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _capture(tester, 'removed-band-reopen');
  });

  testWidgets('공연 삭제 확인 뒤 홈으로 가며 재진입해도 삭제된 공연이다', (tester) async {
    final router = await _pump(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('concert_delete')));
    await tester.tap(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();
    await _capture(tester, 'delete-confirmation');

    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fixture_home')), findsOneWidget);
    router.go(AppRoutes.showOf('12'));
    await tester.pumpAndSettle();
    expect(find.byKey(ConcertDetailView.notFoundKey), findsOneWidget);
    await _capture(tester, 'deleted-concert-reopen');
  });

  testWidgets('판매 시작 후 삭제를 확인해도 불가 안내를 보이고 공연을 유지한다', (tester) async {
    await _pump(tester, fixture: _host.copyWith(status: ConcertStatus.selling));
    await tester.ensureVisible(find.byKey(const ValueKey('concert_delete')));
    await tester.tap(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();

    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();

    final popup = tester.widget<ShowConfirmPopup>(
      find.byType(ShowConfirmPopup),
    );
    expect(popup.alert, isTrue);
    expect(popup.cancelLabel, isNull);
    expect(find.byKey(ConcertDetailView.notFoundKey), findsNothing);
    await _capture(tester, 'selling-delete-refused');
  });

  testWidgets('계정이 바뀌면 이전 계정의 fake 삭제 상태가 새 계정에 남지 않는다', (tester) async {
    await _pump(tester, sessionScoped: true);
    await _capture(tester, 'account-initial');
    expect(
      find.byKey(const ValueKey('concert_delete')),
      findsOneWidget,
      reason: ProviderScope.containerOf(
        tester.element(find.byType(ConcertDetailView)),
      ).read(concertDetailProvider(12)).error.toString(),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();
    await tester.tap(_popupAction(confirm: true));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ConcertSessionScope));
    final container = ProviderScope.containerOf(context);
    (container.read(sessionProvider.notifier) as _Session).switchAccount();
    await tester.pumpAndSettle();
    final router = GoRouter.of(
      tester.element(find.byKey(const ValueKey('fixture_home'))),
    );
    router.go(AppRoutes.showOf('12'));
    await tester.pumpAndSettle();

    expect(find.byType(ShowTeamAvatar), findsNWidgets(2));
    expect(find.byKey(ConcertDetailView.notFoundKey), findsNothing);
  });

  testWidgets('폭 320에서도 삭제 확인창이 넘치지 않는다', (tester) async {
    await _pump(tester);
    tester.view.physicalSize = const Size(320, 568);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concert_delete')));
    await tester.pumpAndSettle();

    expect(find.byType(ShowConfirmPopup), findsOneWidget);
    expect(_popupAction(confirm: false).hitTestable(), findsOneWidget);
    expect(_popupAction(confirm: true).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _capture(tester, 'delete-confirmation-320');
  });
}
