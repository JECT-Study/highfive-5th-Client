import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/dto/token_dto.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';
import 'package:highfive/features/auth/presentation/providers/auth_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/views/login_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';

/// 응답 시점을 테스트가 정하고 호출 수를 센다.
class _FakeAuthService extends AuthService {
  final response = Completer<TokenDto>();
  int calls = 0;

  @override
  Future<TokenDto> login() {
    calls++;
    return response.future;
  }
}

const _buttonKeys = [
  LoginView.kakaoButtonKey,
  LoginView.appleButtonKey,
  LoginView.googleButtonKey,
];

Future<void> _pump(WidgetTester tester, AuthService service) async {
  FlutterSecureStorage.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(AuthRepository(service)),
        sessionRepositoryProvider.overrideWithValue(
          SessionRepository(SecureStore(const FlutterSecureStorage())),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const LoginView()),
    ),
  );
  await tester.pumpAndSettle();
}

AppButton _button(WidgetTester tester, Key key) => tester.widget<AppButton>(
  find.descendant(of: find.byKey(key), matching: find.byType(AppButton)),
);

void main() {
  testWidgets('카카오·Apple·Google 버튼을 순서대로 보여준다', (tester) async {
    await _pump(tester, _FakeAuthService());

    final tops = [
      for (final key in _buttonKeys) tester.getTopLeft(find.byKey(key)).dy,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
    for (final key in _buttonKeys) {
      expect(_button(tester, key).loading, isFalse, reason: '$key');
    }
  });

  testWidgets('작은 화면에서도 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester, _FakeAuthService());

    expect(tester.takeException(), isNull);
  });

  for (final key in _buttonKeys) {
    testWidgets('$key를 누르면 로그인을 한 번 요청하고, 응답 전에는 모든 버튼이 로딩이다', (tester) async {
      final service = _FakeAuthService();
      await _pump(tester, service);

      await tester.tap(find.byKey(key));
      await tester.pump();
      for (final other in _buttonKeys) {
        await tester.tap(find.byKey(other));
      }
      await tester.pump();

      expect(service.calls, 1);
      for (final other in _buttonKeys) {
        expect(_button(tester, other).loading, isTrue, reason: '$other');
      }

      service.response.complete(const TokenDto(accessToken: 'a'));
      await tester.pumpAndSettle();
      for (final other in _buttonKeys) {
        expect(_button(tester, other).loading, isFalse, reason: '$other');
      }
    });
  }
}
