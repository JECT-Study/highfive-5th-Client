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
import 'package:highfive/features/performances/data/repositories/host_band_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_creation_repository.dart';
import 'package:highfive/features/performances/data/repositories/local_concert_creation_repository.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/models/host_band.dart';
import 'package:highfive/features/performances/models/concert_genre.dart';
import 'package:highfive/features/performances/presentation/providers/concert_creation_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_creation_view.dart';
import 'package:highfive/features/performances/presentation/widgets/host_band_picker_sheet.dart';
import 'package:highfive/features/performances/presentation/widgets/perform_date_sheet.dart';
import 'package:highfive/features/recruitments/presentation/views/recruitment_list_view.dart';
import 'package:highfive/shared/widgets/app_bottom_nav_bar.dart';
import 'package:highfive/shared/widgets/app_top_bar.dart';
import 'package:highfive/shared/widgets/app_chip.dart';

import '../support/capture.dart';

const _session = Session(accessToken: 'a');

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
Future<void> _start(
  WidgetTester tester,
  Map<String, String> stored, {
  LocalConcertCreationRepository? local,
}) async {
  usePhoneSize(tester);
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
        hostBandRepositoryProvider.overrideWithValue(
          const FakeHostBandRepository(),
        ),
        concertCreationRepositoryProvider.overrideWithValue(
          ConcertCreationRepository(local: local),
        ),
        concertTodayProvider.overrideWithValue(() => DateTime(2026, 11, 28)),
      ],
      child: capturable(const HighfiveApp()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadCaptureFonts);
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
    final local = LocalConcertCreationRepository();
    await _start(tester, {SecureStore.accessTokenKey: 'a'}, local: local);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HighfiveApp)),
    );

    await container
        .read(concertCreationRepositoryProvider)
        .create(
          FakeHostBandRepository.devBands.first,
          ConcertDraft(
            title: '미리보기',
            genres: const {ConcertGenre.rock},
            recruitTeamCount: 1,
            performDate: DateTime(2026, 12, 20),
            rentalFeeUndecided: true,
            rentalFeeText: '',
          ),
        );
    expect(local.concerts, hasLength(1));

    await container.read(sessionProvider.notifier).signOut();
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(local.concerts, isEmpty);
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

  testWidgets('홈에서 공연 열고 팀 모집하기 → 주최 밴드를 고르면 공연 만들기가 열리고, 닫으면 홈이다', (
    tester,
  ) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});

    await tester.tap(find.byKey(HomeView.createConcertKey));
    await tester.pumpAndSettle();
    expect(find.byType(HostBandPickerSheet), findsOneWidget);
    await capture(tester, 'flow-1-host-selection');
    await tester.tap(find.byKey(HostBandPickerSheet.optionKey(2)));
    await tester.pump();
    await tester.tap(find.byKey(HostBandPickerSheet.nextKey));
    await tester.pumpAndSettle();

    final creation = tester.widget<ConcertCreationView>(
      find.byType(ConcertCreationView),
    );
    expect(creation.hostBand.id, 2);
    await capture(tester, 'flow-2-creation-form');

    await tester.tap(
      find.descendant(
        of: find.byType(ConcertCreationView),
        matching: find.byType(AppIconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ConcertCreationView), findsNothing);
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('밴드 선택 시트는 하단 탭까지 덮고, 닫으면 공연 만들기를 열지 않는다', (tester) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});

    await tester.tap(find.byKey(HomeView.createConcertKey));
    await tester.pumpAndSettle();
    // 하단 탭 자리는 시트가 덮는다. 눌러도 밑의 마이페이지 탭으로 바뀌지 않는다.
    await tester.tapAt(
      tester.getBottomRight(find.byType(AppBottomNavBar)) -
          const Offset(24, 24),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HostBandPickerSheet), findsOneWidget);
    expect(find.byType(MyPageView), findsNothing);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.byType(HostBandPickerSheet), findsNothing);
    expect(find.byType(ConcertCreationView), findsNothing);
    expect(find.byType(MyPageView), findsNothing);
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('주최 밴드 없이 생성 주소를 push해도 선택 시트와 생성 폼으로 이어진다', (tester) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HighfiveApp)),
    );

    container.read(routerProvider).push(AppRoutes.showNew);
    await tester.pumpAndSettle();

    expect(find.byType(HostBandPickerSheet), findsOneWidget);
    expect(find.byType(ConcertCreationView), findsNothing);
    expect(
      container.read(routerProvider).state.matchedLocation,
      AppRoutes.showNew,
    );
    await tester.tap(find.byKey(HostBandPickerSheet.optionKey(1)));
    await tester.pump();
    await tester.tap(find.byKey(HostBandPickerSheet.nextKey));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ConcertCreationView>(find.byType(ConcertCreationView))
          .hostBand
          .id,
      1,
    );
  });

  testWidgets('검증된 실제 주최 밴드를 extra로 주면 선택 없이 폼을 연다', (tester) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HighfiveApp)),
    );
    const band = HostBand.authenticated(
      id: 42,
      name: '서버에서 확인한 대표 밴드',
      genres: [ConcertGenre.rock],
      memberCount: 4,
    );

    container.read(routerProvider).push(AppRoutes.showNew, extra: band);
    await tester.pumpAndSettle();

    expect(find.byType(HostBandPickerSheet), findsNothing);
    expect(
      tester
          .widget<ConcertCreationView>(find.byType(ConcertCreationView))
          .hostBand,
      same(band),
    );
  });

  testWidgets('공용 라우트에서 임시 밴드를 고르고 만들면 원격 없이 로컬 ID를 돌려준다', (tester) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HighfiveApp)),
    );
    final result = container.read(routerProvider).push<int>(AppRoutes.showNew);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(HostBandPickerSheet.optionKey(1)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(HostBandPickerSheet.nextKey));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(ConcertCreationView.titleKey), '로컬 미리보기');
    await tester.tap(find.byType(AppChip).first);
    await tester.tap(find.byKey(ConcertCreationView.performDateKey));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(PerformDateSheet.dayKey(DateTime(2026, 11, 30))),
    );
    await tester.pump();
    await tester.tap(find.byKey(PerformDateSheet.confirmKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ConcertCreationView.submitKey));
    await tester.pumpAndSettle();

    expect(await result.timeout(const Duration(seconds: 5)), -1);
    expect(find.byType(ConcertCreationView), findsNothing);
    expect(find.byType(HomeView), findsOneWidget);
    await capture(tester, 'flow-3-local-created-return-home');
  });

  testWidgets('모집 중인 공연 찾기는 팀 모집 탭으로 간다', (tester) async {
    await _start(tester, {SecureStore.accessTokenKey: 'a'});

    await tester.tap(find.byKey(HomeView.findRecruitmentsKey));
    await tester.pumpAndSettle();

    expect(find.byType(RecruitmentListView), findsOneWidget);
  });
}
