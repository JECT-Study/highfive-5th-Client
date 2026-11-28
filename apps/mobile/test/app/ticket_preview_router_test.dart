import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/ticketing/presentation/views/ticket_page_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';

class _SignedOutSession extends SessionViewModel {
  _SignedOutSession(this.value);

  final Session? value;

  @override
  Future<Session?> build() async => value;
}

void main() {
  for (final flavor in Flavor.values) {
    for (final signedIn in [false, true]) {
      testWidgets('${flavor.name}의 로그인 $signedIn 상태에서 dev 티켓 진입을 구분한다', (
        tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            appEnvProvider.overrideWithValue(AppEnv.forFlavorName(flavor.name)),
            sessionProvider.overrideWith(
              () => _SignedOutSession(
                signedIn ? const Session(accessToken: 'synthetic-token') : null,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(sessionProvider.future);
        final router = container.read(routerProvider);
        router.go(AppRoutes.devTicketPage);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (flavor == Flavor.dev) {
          expect(find.byType(TicketPageView), findsOneWidget);
          expect(find.byKey(TicketPageView.createKey), findsOneWidget);
        } else {
          expect(find.byType(TicketPageView), findsNothing);
          expect(find.byKey(TicketPageView.createKey), findsNothing);
        }
        // dev의 예외가 기존 홈·약관 인증 조건을 바꾸지 않는다.
        expect(
          sessionRedirect(const AsyncData(null), AppRoutes.home),
          AppRoutes.login,
        );
      });
    }
  }
}
