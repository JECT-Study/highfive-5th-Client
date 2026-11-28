import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/concert_edit_preview.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/views/login_view.dart';
import 'package:highfive/features/performances/models/concert_edit_context.dart';
import 'package:highfive/features/performances/presentation/views/concert_edit_view.dart';
import 'package:highfive/shared/widgets/app_button.dart';

import '../features/performances/edit_fixture.dart';

void main() {
  Future<ProviderContainer> start(WidgetTester tester, Flavor flavor) async {
    FlutterSecureStorage.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            AppEnv(
              flavor: flavor,
              apiBaseUrl: 'https://api.test',
              kakaoNativeAppKey: '',
              googleIosClientId: '',
              googleServerClientId: '',
            ),
          ),
          sessionExpiryProvider.overrideWithValue(SessionExpiry()),
          sessionRepositoryProvider.overrideWithValue(
            SessionRepository(SecureStore(const FlutterSecureStorage())),
          ),
        ],
        child: const HighfiveApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(HighfiveApp)));
  }

  testWidgets('dev는 정상 로그인으로 시작하고 DEV 메뉴로 ID 없는 오프라인 폼을 연다', (tester) async {
    await start(tester, Flavor.dev);
    expect(find.byType(LoginView), findsOneWidget);
    await tester.longPress(find.byKey(const ValueKey('app_devGalleryEntry')));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .byWidgetPredicate((w) => w is AppButton && w.onPressed != null)
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(ConcertEditPreview), findsOneWidget);
    expect(find.byType(ConcertEditView), findsOneWidget);
    // 네트워크·편집 Service를 등록하지 않았어도 저장과 재조회가 동작한다.
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('prod 라우터에는 로그인 우회 미리보기 경로가 없다', (tester) async {
    final container = await start(tester, Flavor.prod);
    container.read(routerProvider).go(AppRoutes.devConcertEdit);
    await tester.pumpAndSettle();
    expect(find.byType(ConcertEditPreview), findsNothing);
    expect(find.byType(ConcertEditView), findsNothing);
  });

  testWidgets('ID만 있는 수정 경로에는 쓰기 가능한 폼을 만들지 않는다', (tester) async {
    final container = await start(tester, Flavor.dev);
    // 실제 세션을 조작하지 않고 라우터 함수의 접근 정책도 확인한다.
    expect(
      sessionRedirect(
        const AsyncData<Session?>(null),
        AppRoutes.showEditOf('48'),
      ),
      AppRoutes.login,
    );
    container.read(routerProvider).go(AppRoutes.showEditOf('48'));
    await tester.pumpAndSettle();
    expect(find.byType(ConcertEditView), findsNothing);
  });

  test('상세 호출 문맥은 양의 실제 공연 식별자를 요구한다', () {
    expect(
      () => ConcertEditContext(
        concertId: 0,
        snapshot: editSnapshot(),
        reload: () async => editSnapshot(),
      ),
      throwsArgumentError,
    );
  });
}
