import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/views/login_view.dart';

/// 저장된 세션이 없는 상태로 앱을 띄운다.
Widget _app(Flavor flavor) {
  FlutterSecureStorage.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: flavor,
          apiBaseUrl: 'http://localhost',
          kakaoNativeAppKey: 'test',
          googleIosClientId: 'test',
          googleServerClientId: 'test',
        ),
      ),
      sessionRepositoryProvider.overrideWithValue(
        SessionRepository(SecureStore(const FlutterSecureStorage())),
      ),
    ],
    child: const HighfiveApp(),
  );
}

final _devBanner = find.byWidgetPredicate(
  (w) => w is Banner && w.message == 'DEV',
);

void main() {
  testWidgets('첫 화면은 로그인이다', (tester) async {
    await tester.pumpWidget(_app(Flavor.dev));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('dev 환경에서만 DEV 배너를 보여준다', (tester) async {
    await tester.pumpWidget(_app(Flavor.dev));
    await tester.pumpAndSettle();
    expect(_devBanner, findsOneWidget);

    await tester.pumpWidget(_app(Flavor.prod));
    await tester.pumpAndSettle();
    expect(_devBanner, findsNothing);
  });

  testWidgets('기기 글자 크기를 2배로 해도 앱 글자는 커지지 않는다', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final flavor in Flavor.values) {
      await tester.pumpWidget(_app(flavor));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(LoginView));
      expect(
        MediaQuery.textScalerOf(context),
        TextScaler.noScaling,
        reason: '$flavor',
      );
    }
  });
}
