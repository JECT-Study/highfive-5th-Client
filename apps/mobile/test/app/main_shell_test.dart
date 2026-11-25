import 'package:flutter/material.dart';
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
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/chat/presentation/views/chat_list_view.dart';
import 'package:highfive/features/home/presentation/views/home_view.dart';
import 'package:highfive/features/my_page/presentation/views/my_page_view.dart';
import 'package:highfive/features/recruitments/presentation/views/recruitment_list_view.dart';
import 'package:highfive/shared/theme/app_colors.dart';
import 'package:highfive/shared/widgets/app_bottom_nav_bar.dart';

/// 로그인된 상태(저장된 토큰 있음)로 앱을 띄우고 [location]으로 이동한다.
Future<void> _open(WidgetTester tester, String location) async {
  FlutterSecureStorage.setMockInitialValues({
    SecureStore.accessTokenKey: 'test-token',
  });
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
      ],
      child: const HighfiveApp(),
    ),
  );
  ProviderScope.containerOf(tester.element(find.byType(HighfiveApp)))
      .read(routerProvider)
      .go(location);
  await tester.pumpAndSettle();
}

/// 하단 탭 라벨. 화면 제목과 겹치므로 탭 바 안에서만 찾는다.
Finder _tab(String label) => find.descendant(
  of: find.byType(AppBottomNavBar),
  matching: find.text(label),
);

void main() {
  testWidgets('탭 화면에는 하단 탭 4개가 보인다', (tester) async {
    await _open(tester, AppRoutes.home);

    expect(find.byType(HomeView), findsOneWidget);
    for (final label in ['홈', '팀 모집', '메시지', '마이페이지']) {
      expect(_tab(label), findsOneWidget);
    }
  });

  testWidgets('탭을 누르면 그 탭의 첫 화면으로 바뀐다', (tester) async {
    await _open(tester, AppRoutes.home);

    final cases = {
      '팀 모집': RecruitmentListView,
      '메시지': ChatListView,
      '마이페이지': MyPageView,
      '홈': HomeView,
    };
    for (final MapEntry(key: label, value: view) in cases.entries) {
      await tester.tap(_tab(label));
      await tester.pumpAndSettle();
      expect(find.byType(view), findsOneWidget, reason: label);
    }
  });

  testWidgets('선택된 탭만 진한 글자색이다', (tester) async {
    await _open(tester, AppRoutes.chat);
    Color? colorOf(String label) =>
        tester.widget<Text>(_tab(label)).style?.color;

    final colors = AppColors.light;
    expect(colorOf('메시지'), colors.labelStrong);
    expect(colorOf('홈'), colors.interactionInactive);
    expect(colorOf('팀 모집'), colors.interactionInactive);
    expect(colorOf('마이페이지'), colors.interactionInactive);
  });

  testWidgets('다른 탭으로 가도 이전 탭 화면은 버리지 않는다', (tester) async {
    await _open(tester, AppRoutes.home);

    await tester.tap(_tab('팀 모집'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeView), findsNothing);
    expect(find.byType(HomeView, skipOffstage: false), findsOneWidget);
  });

  testWidgets('로그인 화면에는 하단 탭이 없다', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
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
        ],
        child: const HighfiveApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavBar), findsNothing);
  });
}
