import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_detail_view.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_page_header.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_top_bar.dart';

const _homeKey = ValueKey('test_home');
const _myKey = ValueKey('test_my');
const _editKey = ValueKey('test_edit');

/// 예시 공연 저장소에 몇 번 물었는지 센다.
class _CountingConcertRepository implements ConcertRepository {
  final _fake = FakeConcertRepository();
  var calls = 0;

  @override
  Future<ConcertDetail> fetchDetail(int concertId) {
    calls++;
    return _fake.fetchDetail(concertId);
  }
}

/// 다른 작업이 만드는 화면 자리. 경로가 맞게 열렸는지만 본다.
GoRoute _stub(String path, {Key? key, List<RouteBase> routes = const []}) =>
    GoRoute(
      path: path,
      builder: (context, state) => Scaffold(key: key),
      routes: routes,
    );

/// 하단 탭 대신 쓰는 출발 화면들과 공연 페이지.
List<RouteBase> _routes({List<RouteBase> extra = const []}) => [
  _stub(AppRoutes.home, key: _homeKey),
  _stub(AppRoutes.my, key: _myKey),
  concertShowRoute(),
  ...extra,
];

RouteConfiguration _configuration(List<RouteBase> routes) {
  final router = GoRouter(routes: routes);
  addTearDown(router.dispose);
  return router.configuration;
}

Future<GoRouter> _pumpRouter(
  WidgetTester tester, {
  required String initialLocation,
  List<RouteBase> extra = const [],
  ConcertRepository? concerts,
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: _routes(extra: extra),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        concertRepositoryProvider.overrideWithValue(
          concerts ?? FakeConcertRepository(),
        ),
        concertParticipantsRepositoryProvider.overrideWithValue(
          FakeConcertParticipantsRepository(),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Finder get _editButton => find.descendant(
  of: find.byType(ConcertPageHeader),
  matching: find.byType(AppButton),
);

Finder get _backButton => find.descendant(
  of: find.byType(AppTopBar),
  matching: find.byType(AppIconButton),
);

void main() {
  group('hasRoutePath', () {
    test('하위 GoRoute는 go_router처럼 부모 경로에 이어 붙여 찾는다', () {
      for (final child in ['edit', '/edit']) {
        final configuration = _configuration([
          _stub(AppRoutes.home),
          _stub(AppRoutes.show, routes: [_stub(child)]),
        ]);

        expect(
          hasRoutePath(configuration, AppRoutes.showEdit),
          isTrue,
          reason: child,
        );
        expect(hasRoutePath(configuration, AppRoutes.show), isTrue);
      }
    });

    test('하단 탭 branch 안의 경로도 찾는다', () {
      final configuration = _configuration([
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => shell,
          branches: [
            StatefulShellBranch(
              routes: [
                _stub(AppRoutes.recruit, routes: [_stub('new')]),
              ],
            ),
          ],
        ),
      ]);

      expect(hasRoutePath(configuration, AppRoutes.recruitNew), isTrue);
    });

    test('없는 경로와 앞부분만 같은 경로는 없다고 본다', () {
      final configuration = _configuration([_stub(AppRoutes.show)]);

      expect(hasRoutePath(configuration, AppRoutes.showEdit), isFalse);
      expect(hasRoutePath(configuration, '/shows'), isFalse);
    });
  });

  testWidgets('수정 화면이 같은 라우트 표에 있으면 정보 수정으로 그 화면에 간다', (tester) async {
    final router = await _pumpRouter(
      tester,
      initialLocation: AppRoutes.showOf('12'),
      extra: [_stub(AppRoutes.showEdit, key: _editKey)],
    );

    await tester.tap(_editButton);
    await tester.pumpAndSettle();

    expect(find.byKey(_editKey), findsOneWidget);
    expect(router.state.matchedLocation, AppRoutes.showEditOf('12'));
  });

  testWidgets('수정 화면이 라우트 표에 없으면 정보 수정 버튼은 비활성이다', (tester) async {
    await _pumpRouter(tester, initialLocation: AppRoutes.showOf('12'));

    expect(tester.widget<AppButton>(_editButton).onPressed, isNull);
  });

  testWidgets('다른 화면에서 열면 상단·시스템 뒤로 가기 모두 그 화면으로 돌아간다', (tester) async {
    final router = await _pumpRouter(tester, initialLocation: AppRoutes.my);

    for (final back in [
      () => tester.tap(_backButton),
      () => tester.binding.handlePopRoute(),
    ]) {
      unawaited(router.push(AppRoutes.showOf('12')));
      await tester.pumpAndSettle();
      expect(find.byType(ConcertDetailView), findsOneWidget);

      await back();
      await tester.pumpAndSettle();

      expect(find.byType(ConcertDetailView), findsNothing);
      expect(find.byKey(_myKey), findsOneWidget);
    }
  });

  testWidgets('스택에 이전 화면이 없으면 상단·시스템 뒤로 가기 모두 홈으로 간다', (tester) async {
    for (final back in [
      () => tester.tap(_backButton),
      () => tester.binding.handlePopRoute(),
    ]) {
      final router = await _pumpRouter(
        tester,
        initialLocation: AppRoutes.showOf('12'),
      );

      await back();
      await tester.pumpAndSettle();

      expect(find.byKey(_homeKey), findsOneWidget);
      expect(router.state.matchedLocation, AppRoutes.home);
    }
  });

  testWidgets('10진수 양의 정수가 아닌 공연 주소는 저장소에 묻지 않고 없는 공연으로 안내한다', (tester) async {
    for (final showId in ['0xC', '012', '-1', '+12', 'abc']) {
      final repository = _CountingConcertRepository();
      await _pumpRouter(
        tester,
        initialLocation: '/shows/$showId',
        concerts: repository,
      );

      expect(
        find.byKey(ConcertDetailView.notFoundKey),
        findsOneWidget,
        reason: showId,
      );
      expect(repository.calls, 0, reason: showId);
    }
  });
}
