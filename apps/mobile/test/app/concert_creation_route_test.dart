import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/home/presentation/views/home_view.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/presentation/providers/concert_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_creation_view.dart';
import 'package:highfive/shared/widgets/app_button.dart';

import '../features/performances/concert_test_server.dart';

final _ownerProvider = Provider<Object>((ref) => Object());

Future<ProviderContainer> _start(
  WidgetTester tester,
  ConcertTestServer server,
) async {
  FlutterSecureStorage.setMockInitialValues({
    SecureStore.accessTokenKey: 'test-access',
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(
          const AppEnv(
            flavor: Flavor.prod,
            apiBaseUrl: 'https://concert.test',
            kakaoNativeAppKey: 'test',
            googleIosClientId: 'test',
            googleServerClientId: 'test',
          ),
        ),
        sessionRepositoryProvider.overrideWithValue(
          SessionRepository(SecureStore(const FlutterSecureStorage())),
        ),
        sessionExpiryProvider.overrideWithValue(SessionExpiry()),
        concertSessionProvider.overrideWith((ref) => ref.watch(_ownerProvider)),
        concertServiceProvider.overrideWithValue(server.repositoryService()),
      ],
      child: const HighfiveApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(HighfiveApp)));
}

Future<void> _submit(WidgetTester tester) async {
  await tester.enterText(
    find.descendant(
      of: find.byKey(const ValueKey('concert_title')),
      matching: find.byType(TextField),
    ),
    '라우트 검증 공연',
  );
  await tester.tap(find.byKey(const ValueKey('concert_genre_SERVER_GENRE')));
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('concert_submit')),
    300,
    scrollable: find
        .descendant(
          of: find.byKey(const ValueKey('concert_form')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.tap(find.byKey(const ValueKey('concert_submit')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('쿼리의 밴드 ID로는 폼을 열거나 코드 API를 호출하지 않는다', (tester) async {
    final server = ConcertTestServer();
    final c = await _start(tester, server);

    unawaited(c.read(routerProvider).push('${AppRoutes.showNew}?bandId=41'));
    await tester.pumpAndSettle();

    expect(find.byType(ConcertCreationView), findsNothing);
    expect(server.requests, isEmpty);
  });

  testWidgets('검증된 밴드 문맥으로 연 폼은 확인된 공연 ID를 호출 화면에 반환한다', (tester) async {
    final server = ConcertTestServer();
    final c = await _start(tester, server);
    final result = c
        .read(routerProvider)
        .push<int>(AppRoutes.showNew, extra: HostBand(id: 41, name: '테스트 밴드'));
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(await result, 72);
    expect(find.byType(HomeView), findsOneWidget);
    expect(server.posts, 1);
  });

  testWidgets('단독 진입의 성공 화면도 재제출 없이 이전 화면으로 돌아갈 수 있다', (tester) async {
    final server = ConcertTestServer();
    final c = await _start(tester, server);
    c
        .read(routerProvider)
        .go(AppRoutes.showNew, extra: HostBand(id: 41, name: '테스트 밴드'));
    await tester.pumpAndSettle();
    await _submit(tester);

    expect(
      tester
          .widget<AppButton>(find.byKey(const ValueKey('concert_submit')))
          .onPressed,
      isNull,
    );
    final back = find.byKey(const ValueKey('concert_forbidden_back'));
    await tester.scrollUntilVisible(
      back,
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('concert_form')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
    expect(server.posts, 1);
  });

  testWidgets('계정 수명이 바뀌면 이전 밴드 폼을 닫고 늦은 생성 응답은 전달하지 않는다', (tester) async {
    final server = ConcertTestServer()..release = Completer<void>();
    final c = await _start(tester, server);
    final result = c
        .read(routerProvider)
        .push<int>(AppRoutes.showNew, extra: HostBand(id: 41, name: '테스트 밴드'));
    await tester.pumpAndSettle();
    await _submit(tester);
    await server.posted.future;

    c.invalidate(_ownerProvider);
    await tester.pumpAndSettle();
    server.release!.complete();
    await tester.pumpAndSettle();

    expect(await result, isNull);
    expect(find.byType(HomeView), findsOneWidget);
    expect(server.posts, 1);
  });
}
