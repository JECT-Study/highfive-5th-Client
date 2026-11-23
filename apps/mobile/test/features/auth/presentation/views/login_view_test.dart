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
import 'package:highfive/features/auth/models/social_provider.dart';
import 'package:highfive/features/auth/presentation/providers/auth_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/views/login_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_dialog.dart';

/// 응답 시점을 테스트가 정하고 받은 제공자 값을 기록한다.
class _FakeAuthService extends AuthService {
  final response = Completer<TokenDto>();
  final providers = <String>[];

  @override
  Future<TokenDto> login(String provider) {
    providers.add(provider);
    return response.future;
  }
}

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

Finder _buttonFinder(SocialProvider provider) =>
    find.byKey(LoginView.buttonKey(provider));

AppButton _button(WidgetTester tester, SocialProvider provider) =>
    tester.widget<AppButton>(
      find.descendant(
        of: _buttonFinder(provider),
        matching: find.byType(AppButton),
      ),
    );

void main() {
  testWidgets('카카오·Apple·Google 버튼을 순서대로 보여준다', (tester) async {
    await _pump(tester, _FakeAuthService());

    final tops = [
      for (final provider in SocialProvider.values)
        tester.getTopLeft(_buttonFinder(provider)).dy,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
    for (final provider in SocialProvider.values) {
      expect(_button(tester, provider).loading, isFalse, reason: '$provider');
    }
  });

  testWidgets('충분히 긴 화면에서는 로고가 시안처럼 위에서 119에 있다', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester, _FakeAuthService());

    expect(tester.getTopLeft(find.byKey(LoginView.introKey)).dy, 119);
  });

  testWidgets('짧은 화면에서는 로고 위 여백이 줄고 소개 ↔ 버튼 사이는 32 이상이다', (tester) async {
    tester.view.physicalSize = const Size(375, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester, _FakeAuthService());

    final introTop = tester.getTopLeft(find.byKey(LoginView.introKey)).dy;
    final gap =
        tester.getTopLeft(_buttonFinder(SocialProvider.kakao)).dy -
        tester.getBottomLeft(find.byKey(LoginView.introKey)).dy;
    expect(introTop, lessThan(119));
    expect(gap, greaterThanOrEqualTo(32));
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 화면에서도 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester, _FakeAuthService());

    expect(tester.takeException(), isNull);
  });

  for (final provider in SocialProvider.values) {
    testWidgets('$provider 버튼을 누르면 그 제공자로 한 번만 요청하고 그 버튼만 로딩이다', (
      tester,
    ) async {
      final service = _FakeAuthService();
      await _pump(tester, service);

      await tester.tap(_buttonFinder(provider));
      await tester.pump();
      for (final other in SocialProvider.values) {
        await tester.tap(_buttonFinder(other));
      }
      await tester.pump();

      expect(service.providers, [provider.name]);
      for (final other in SocialProvider.values) {
        expect(
          _button(tester, other).loading,
          other == provider,
          reason: '$other',
        );
      }

      service.response.complete(const TokenDto(accessToken: 'a'));
      await tester.pumpAndSettle();
      expect(_button(tester, provider).loading, isFalse);
    });
  }

  testWidgets('로그인에 실패하면 오류 안내를 띄우고 버튼 로딩이 풀린다', (tester) async {
    final service = _FakeAuthService();
    await _pump(tester, service);

    await tester.tap(_buttonFinder(SocialProvider.kakao));
    await tester.pump();
    service.response.completeError(Exception('network'));
    await tester.pumpAndSettle();

    expect(find.byType(AppDialog), findsOneWidget);
    expect(_button(tester, SocialProvider.kakao).loading, isFalse);
  });
}
