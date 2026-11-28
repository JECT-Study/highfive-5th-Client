import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/auth/presentation/views/login_view.dart';

class _RestoringSession extends SessionViewModel {
  @override
  Future<Session?> build() async =>
      throw PlatformException(code: 'fixture-storage-error');
}

void main() {
  testWidgets('세션 복원 실패를 재시도하는 동안에도 기존 로그인 화면을 유지한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: Flavor.prod,
              apiBaseUrl: 'http://localhost',
              kakaoNativeAppKey: 'fixture',
              googleIosClientId: 'fixture',
              googleServerClientId: 'fixture',
            ),
          ),
          sessionProvider.overrideWith(_RestoringSession.new),
        ],
        child: const HighfiveApp(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HighfiveApp)),
    );

    expect(container.read(sessionProvider).isLoading, isTrue);
    expect(container.read(sessionProvider).hasError, isTrue);
    expect(find.byType(LoginView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
