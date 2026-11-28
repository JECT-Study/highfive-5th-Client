import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:dio/dio.dart';
import 'package:highfive/features/auth/data/dto/login_response_dto.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';
import 'package:highfive/features/auth/data/services/google_auth_service.dart';
import 'package:highfive/features/auth/data/services/kakao_auth_service.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/models/social_provider.dart';
import 'package:highfive/features/auth/presentation/providers/auth_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/auth/presentation/views/login_view.dart';
import 'package:highfive/features/home/presentation/views/home_view.dart';
import 'package:highfive/features/my_page/presentation/views/my_page_view.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_my_concerts_repository.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/providers/my_concerts_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_detail_view.dart';
import 'package:highfive/features/performances/presentation/views/my_concerts_section.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_page_header.dart';
import 'package:highfive/shared/widgets/app_bottom_nav_bar.dart';
import 'package:highfive/shared/widgets/app_button.dart';

const _session = Session(accessToken: 'a');

final _concerts = FakeConcertRepository(
  concerts: FakeMyConcertsRepository.samples,
);

/// 서버 대신 바로 로그인 응답을 돌려준다.
class _FakeAuthService extends AuthService {
  _FakeAuthService() : super(Dio());

  @override
  Future<LoginResponseDto> login(
    String provider, {
    required String providerToken,
  }) async => const LoginResponseDto(
    accessToken: 'a',
    refreshToken: 'r',
    user: LoginUserDto(id: 1, status: 'ACTIVE'),
    nextStep: 'HOME',
  );

  @override
  Future<void> logout() async {}
}

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
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
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
        sessionExpiryProvider.overrideWithValue(SessionExpiry()),
        sessionRepositoryProvider.overrideWithValue(
          SessionRepository(SecureStore(const FlutterSecureStorage())),
        ),
        authRepositoryProvider.overrideWithValue(
          AuthRepository(
            _FakeAuthService(),
            _FakeKakaoAuthService(),
            _FakeGoogleAuthService(),
          ),
        ),
        concertRepositoryProvider.overrideWithValue(_concerts),
        concertParticipantsRepositoryProvider.overrideWithValue(
          FakeConcertParticipantsRepository(
            participants: FakeMyConcertsRepository.participantSamples,
          ),
        ),
        myConcertsRepositoryProvider.overrideWithValue(
          FakeMyConcertsRepository(_concerts),
        ),
        myConcertsClockProvider.overrideWithValue(
          () => DateTime(2026, 11, 28, 12),
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
      expect(
        sessionRedirect(signedIn, AppRoutes.termsDetailOf(1)),
        AppRoutes.home,
      );
    });

    test('약관 동의 전이면 로그인 화면과 약관 상세만 허용하고 나머지는 로그인으로 보낸다', () {
      const needsTerms = AsyncData<Session?>(
        Session(accessToken: 'a', nextStep: NextStep.terms),
      );
      expect(sessionRedirect(needsTerms, AppRoutes.login), isNull);
      expect(sessionRedirect(needsTerms, AppRoutes.termsDetailOf(1)), isNull);
      expect(sessionRedirect(needsTerms, AppRoutes.home), AppRoutes.login);
      expect(sessionRedirect(needsTerms, AppRoutes.splash), AppRoutes.login);
    });

    test('로그인 안 됐으면 약관 상세도 로그인으로 보낸다', () {
      const signedOut = AsyncData<Session?>(null);
      expect(
        sessionRedirect(signedOut, AppRoutes.termsDetailOf(1)),
        AppRoutes.login,
      );
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

  testWidgets(
    '로그인 상태에서 공연 경로를 열면 하단 탭 없이 공연 페이지를 보이고, 수정 화면이 등록됐을 때만 정보 수정을 켠다',
    (tester) async {
      await _start(tester, {SecureStore.accessTokenKey: 'a'});
      final router = ProviderScope.containerOf(
        tester.element(find.byType(HighfiveApp)),
      ).read(routerProvider);

      unawaited(router.push(AppRoutes.showOf('12')));
      await tester.pumpAndSettle();

      expect(find.byType(ConcertDetailView), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsNothing);
      final edit = tester.widget<AppButton>(
        find.descendant(
          of: find.byType(ConcertPageHeader),
          matching: find.byType(AppButton),
        ),
      );
      expect(
        edit.onPressed != null,
        !router.configuration
            .findMatch(Uri.parse(AppRoutes.showEditOf('12')))
            .isError,
      );
    },
  );

  testWidgets('마이페이지의 각 공연을 누르면 그 상세가 열리고 돌아오면 목록이 보인다', (tester) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});
    final router = ProviderScope.containerOf(
      tester.element(find.byType(HighfiveApp)),
    ).read(routerProvider);
    router.go(AppRoutes.my);
    await tester.pumpAndSettle();

    for (final concert in FakeMyConcertsRepository.samples) {
      final card = find.byKey(MyConcertsSection.cardKey(concert.concertId));
      final item = card.evaluate().isNotEmpty
          ? card
          : find.byKey(MyConcertsSection.historyKey(concert.concertId));
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pumpAndSettle();

      expect(
        router.state.matchedLocation,
        AppRoutes.showOf('${concert.concertId}'),
      );
      expect(
        find.descendant(
          of: find.byType(ConcertDetailView),
          matching: find.text(concert.title),
        ),
        findsWidgets,
      );

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(MyPageView), findsOneWidget);
    }
  });
}
