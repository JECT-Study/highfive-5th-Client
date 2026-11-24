import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/data/services/fake_auth_service.dart';
import 'package:highfive/features/auth/data/services/google_auth_service.dart';
import 'package:highfive/features/auth/data/services/kakao_auth_service.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/models/social_provider.dart';
import 'package:highfive/features/auth/presentation/providers/auth_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/auth/presentation/views/login_view.dart';
import 'package:highfive/features/home/presentation/views/home_view.dart';
import 'package:highfive/features/my_page/presentation/views/my_page_view.dart';

const _session = Session(accessToken: 'a');

/// 카카오 SDK 대신 바로 토큰을 돌려준다.
class _FakeKakaoAuthService extends KakaoAuthService {
  @override
  Future<String?> login() async => 'kakao-token';
}

/// Google SDK 대신 바로 토큰을 돌려준다.
class _FakeGoogleAuthService extends GoogleAuthService {
  _FakeGoogleAuthService() : super(iosClientId: '', serverClientId: '');

  @override
  Future<String?> login() async => 'google-token';
}

/// [stored]가 저장된 상태로 앱을 처음부터 띄운다 (앱 재시작과 같다).
Future<void> _start(WidgetTester tester, Map<String, String> stored) async {
  FlutterSecureStorage.setMockInitialValues(Map.of(stored));
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
        sessionRepositoryProvider.overrideWithValue(
          SessionRepository(SecureStore(const FlutterSecureStorage())),
        ),
        authRepositoryProvider.overrideWithValue(
          AuthRepository(
            FakeAuthService(),
            _FakeKakaoAuthService(),
            _FakeGoogleAuthService(),
          ),
        ),
      ],
      child: const HighfiveApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('sessionRedirect', () {
    test('세션을 읽는 중이면 스플래시로 보낸다', () {
      const loading = AsyncLoading<Session?>();
      expect(sessionRedirect(loading, AppRoutes.home), AppRoutes.splash);
      expect(sessionRedirect(loading, AppRoutes.splash), isNull);
    });

    test('로그인 안 됐으면 로그인 전 화면만 허용하고 나머지는 로그인으로 보낸다', () {
      const signedOut = AsyncData<Session?>(null);
      expect(sessionRedirect(signedOut, AppRoutes.splash), AppRoutes.login);
      expect(sessionRedirect(signedOut, AppRoutes.home), AppRoutes.login);
      expect(sessionRedirect(signedOut, AppRoutes.login), isNull);
      expect(sessionRedirect(signedOut, AppRoutes.signup), isNull);
    });

    test('dev 위젯 모음은 세션 상태와 상관없이 그대로 둔다', () {
      const states = <AsyncValue<Session?>>[
        AsyncLoading(),
        AsyncData(null),
        AsyncData(_session),
      ];
      for (final state in states) {
        expect(sessionRedirect(state, AppRoutes.devWidgets), isNull);
      }
    });

    test('세션 복원에 실패하면 로그인 안 된 것으로 본다', () {
      final failed = AsyncError<Session?>(Exception('read'), StackTrace.empty);
      expect(sessionRedirect(failed, AppRoutes.splash), AppRoutes.login);
    });

    test('로그인 됐으면 스플래시·로그인 전 화면에서 홈으로 보내고 나머지는 그대로 둔다', () {
      const signedIn = AsyncData<Session?>(_session);
      expect(sessionRedirect(signedIn, AppRoutes.splash), AppRoutes.home);
      expect(sessionRedirect(signedIn, AppRoutes.login), AppRoutes.home);
      expect(sessionRedirect(signedIn, AppRoutes.recruit), isNull);
      expect(sessionRedirect(signedIn, AppRoutes.onboardingProfile), isNull);
    });
  });

  testWidgets('저장된 세션이 있으면 앱을 다시 켰을 때 홈으로 간다', (tester) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});

    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('저장된 세션이 없으면 앱을 다시 켰을 때 로그인으로 간다', (tester) async {
    await _start(tester, {});

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('로그인 상태에서 로그아웃하면 로그인 화면으로 간다', (tester) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HighfiveApp)),
    );

    await container.read(sessionProvider.notifier).signOut();
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(
      container.read(routerProvider).state.matchedLocation,
      AppRoutes.login,
    );
  });

  testWidgets('로그인 버튼을 누르면 홈으로 가고, 다시 켜도 홈이다', (tester) async {
    await _start(tester, {});

    await tester.tap(find.byKey(LoginView.buttonKey(SocialProvider.kakao)));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);

    // 같은 저장소 상태로 앱을 새로 띄운다.
    final stored = await const FlutterSecureStorage().readAll();
    await tester.pumpWidget(const SizedBox());
    await _start(tester, stored);
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('마이페이지에서 로그아웃하면 로그인으로 가고, 다시 켜도 로그인이다', (tester) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});

    await tester.tap(find.text('마이페이지').last);
    await tester.pumpAndSettle();
    expect(find.byType(MyPageView), findsOneWidget);

    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);

    final stored = await const FlutterSecureStorage().readAll();
    await tester.pumpWidget(const SizedBox());
    await _start(tester, stored);
    expect(find.byType(LoginView), findsOneWidget);
  });
}
