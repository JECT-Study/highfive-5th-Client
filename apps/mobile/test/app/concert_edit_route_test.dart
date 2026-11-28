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
import 'package:highfive/features/performances/data/repositories/fake_concert_edit_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_edit_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_edit_view.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/show/show_confirm_popup.dart';

Future<ProviderContainer> _start(
  WidgetTester tester,
  FakeConcertEditRepository repository,
) async {
  FlutterSecureStorage.setMockInitialValues({
    SecureStore.accessTokenKey: 'route-fixture',
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(
          const AppEnv(
            flavor: Flavor.prod,
            apiBaseUrl: 'http://localhost',
            kakaoNativeAppKey: 'test',
            googleIosClientId: 'test',
            googleServerClientId: 'test',
          ),
        ),
        sessionExpiryProvider.overrideWithValue(SessionExpiry()),
        sessionRepositoryProvider.overrideWithValue(
          SessionRepository(SecureStore(const FlutterSecureStorage())),
        ),
        concertRepositoryProvider.overrideWithValue(repository),
        concertEditRepositoryProvider.overrideWithValue(repository),
      ],
      child: const HighfiveApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(HighfiveApp)));
}

Finder _title() => find.descendant(
  of: find.byKey(const ValueKey('concertEdit_title')),
  matching: find.byType(TextField),
);

void main() {
  testWidgets('16진수 공연 경로는 십진수 공연으로 해석하지 않는다', (tester) async {
    final container = await _start(tester, FakeConcertEditRepository());
    container.read(routerProvider).go('/shows/0xC/edit');
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(
      find.byKey(const ValueKey('concertEdit_loadAction')),
      findsOneWidget,
    );
  });

  testWidgets('조회 실패 화면에서도 시스템 뒤로 가기는 홈으로 돌아간다', (tester) async {
    final container = await _start(tester, FakeConcertEditRepository());
    container.read(routerProvider).go('/shows/abc/edit');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('직접 진입 후 시스템 뒤로 가기도 홈으로 돌아간다', (tester) async {
    final container = await _start(tester, FakeConcertEditRepository());
    container.read(routerProvider).go(AppRoutes.showEditOf('12'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('직접 연 공연을 표시하고 닫으면 홈으로 간다', (tester) async {
    final container = await _start(tester, FakeConcertEditRepository());
    container.read(routerProvider).go(AppRoutes.showEditOf('12'));
    await tester.pumpAndSettle();
    expect(find.byType(ConcertEditView), findsOneWidget);
    expect(
      tester.widget<TextField>(_title()).controller!.text,
      FakeConcertRepository.sample.title,
    );
    await tester.tap(find.byKey(const ValueKey('concertEdit_close')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('잘못된 공연 ID를 안내한 뒤 홈으로 돌아간다', (tester) async {
    final container = await _start(tester, FakeConcertEditRepository());
    container.read(routerProvider).go('/shows/abc/edit');
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byKey(const ValueKey('concertEdit_loadAction')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('저장 뒤 true를 돌려받고 공용 상세가 갱신된다', (tester) async {
    final repository = FakeConcertEditRepository();
    final container = await _start(tester, repository);
    final result = container
        .read(routerProvider)
        .push<bool>(AppRoutes.showEditOf('12'));
    await tester.pumpAndSettle();
    await tester.enterText(_title(), '새 제목');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(
            of: find.byType(ShowConfirmPopup),
            matching: find.byType(AppButton),
          )
          .last,
    );
    await tester.pumpAndSettle();
    expect(await result, isTrue);
    expect(find.byType(HomeView), findsOneWidget);
    expect(
      (await container.read(concertDetailProvider(12).future)).title,
      '새 제목',
    );
  });
}
