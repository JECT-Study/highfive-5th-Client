import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/features/auth/presentation/views/login_view.dart';

Widget _app(Flavor flavor) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(flavor: flavor, apiBaseUrl: 'http://localhost'),
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
}
