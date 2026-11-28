import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/models/next_step.dart';
import '../features/auth/models/session.dart';
import '../features/auth/presentation/view_models/session_view_model.dart';
import '../features/auth/presentation/views/login_view.dart';
import '../features/auth/presentation/views/splash_view.dart';
import '../features/auth/presentation/views/terms_detail_view.dart';
import '../features/chat/presentation/views/chat_list_view.dart';
import '../features/dev_gallery/presentation/views/widget_gallery_view.dart';
import '../features/home/presentation/views/home_view.dart';
import '../features/my_page/presentation/views/my_page_view.dart';
import '../features/performances/presentation/providers/my_concerts_providers.dart';
import '../features/performances/presentation/view_models/my_concerts_view_model.dart';
import '../features/performances/presentation/views/concert_detail_view.dart';
import '../features/performances/presentation/views/my_concerts_section.dart';
import '../features/recruitments/presentation/views/recruitment_list_view.dart';
import 'main_shell.dart';
import 'providers.dart';
import 'routes.dart';

/// 로그인 전에만 머무는 화면. 로그인 상태면 홈으로 보낸다.
const _signedOutRoutes = {AppRoutes.login, AppRoutes.signup};

/// 약관 상세(`/terms/:termId`). 약관 동의 전에만 연다.
bool _isTermsDetail(String location) =>
    location.startsWith('${AppRoutes.terms}/');

/// 세션 상태에 맞는 경로. 그대로 두면 null.
///
/// - 세션을 읽는 중 → 스플래시
/// - 로그인 안 됨(복원 실패 포함) → 로그인 전 화면만, 나머지는 로그인으로
/// - 로그인 됨 + 약관 동의 전(`nextStep` terms) → 로그인 화면에 머문다. 약관 동의 시트는 로그인 화면이 띄우고,
///   약관 상세는 그 위에 쌓인다. 나머지는 로그인으로
/// - 로그인 됨 → 스플래시·로그인 전 화면·약관 상세에 있으면 홈으로
/// 프로필·밴드 시작 단계는 그 화면이 생길 때 추가한다. 그 전까지는 홈으로 간다.
String? sessionRedirect(AsyncValue<Session?> session, String location) {
  // dev 위젯 모음은 로그인과 상관없이 연다 (dev flavor 라우터에만 등록된다).
  if (location == AppRoutes.devWidgets) return null;
  if (session.isLoading && !session.hasValue && !session.hasError) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }
  final signedIn = session.hasValue && session.value != null;
  if (!signedIn) {
    return _signedOutRoutes.contains(location) ? null : AppRoutes.login;
  }
  if (session.value!.nextStep == NextStep.terms) {
    return location == AppRoutes.login || _isTermsDetail(location)
        ? null
        : AppRoutes.login;
  }
  if (location == AppRoutes.splash ||
      _signedOutRoutes.contains(location) ||
      _isTermsDetail(location)) {
    return AppRoutes.home;
  }
  return null;
}

/// [configuration] 안에 전체 경로가 [path]인 `GoRoute`가 있는지.
/// 다른 작업이 만드는 화면(예: 공연 정보 수정)이 라우트 표에 들어온 뒤에만 그 화면으로 가는 버튼을 켜는 데 쓴다.
/// 전체 경로는 go_router가 매칭에 쓰는 `locationForRoute`로 구한다.
bool hasRoutePath(RouteConfiguration configuration, String path) {
  bool visit(Iterable<RouteBase> routes) => routes.any(
    (route) =>
        (route is GoRoute && configuration.locationForRoute(route) == path) ||
        visit(route.routes),
  );
  return visit(configuration.routes);
}

/// 주소의 공연 ID. 10진수 양의 정수만 받는다(`int.tryParse`는 `0xC` 같은 16진수도 받는다). 아니면 null.
int? _concertIdFrom(String showId) =>
    RegExp(r'^[1-9][0-9]*$').hasMatch(showId) ? int.tryParse(showId) : null;

/// 공연 페이지(`/shows/:showId`). 하단 탭 밖에 등록해 탭 바 없이 전체 화면으로 연다 (Figma 정보탭).
/// 정보 수정은 수정 화면(`AppRoutes.showEdit`)이 같은 라우트 표에 있을 때만 그 화면으로 push한다.
/// 스택에 이전 화면이 없으면(`go`로 바로 연 경우 등) 상단 버튼과 시스템 뒤로 가기 모두 홈으로 간다.
GoRoute concertShowRoute() => GoRoute(
  path: AppRoutes.show,
  builder: (context, state) {
    final showId = state.pathParameters['showId']!;
    final canEdit = hasRoutePath(
      GoRouter.of(context).configuration,
      AppRoutes.showEdit,
    );
    void goHome() => context.go(AppRoutes.home);
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goHome();
      },
      child: ConcertDetailView(
        concertId: _concertIdFrom(showId),
        onBack: () => context.canPop() ? context.pop() : goHome(),
        onEdit: canEdit
            ? () => context.push(AppRoutes.showEditOf(showId))
            : null,
      ),
    );
  },
);

/// 세션 상태는 `ref.listen`으로 구독해 `refreshListenable`에 연결한다.
/// `ref.watch`로 GoRouter를 다시 만들면 내비게이션 스택이 초기화되므로 쓰지 않는다.
final routerProvider = Provider<GoRouter>(
  (ref) {
    // flavor는 앱 실행 중 바뀌지 않으므로 read로 한 번만 읽는다.
    final isDev = ref.read(appEnvProvider).isDev;
    final session = ValueNotifier(ref.read(sessionProvider));
    ref.listen(sessionProvider, (previous, next) {
      if (next.hasValue &&
          previous?.value?.accessToken != next.value?.accessToken) {
        ref.invalidate(myConcertsViewModelProvider);
        ref.invalidate(myConcertsRepositoryProvider);
      }
      session.value = next;
    });

    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: session,
      redirect: (context, state) =>
          sessionRedirect(session.value, state.matchedLocation),
      routes: [
        if (isDev)
          GoRoute(
            path: AppRoutes.devWidgets,
            builder: (context, state) => WidgetGalleryView(
              initialFolder: state.uri.queryParameters['folder'],
            ),
          ),
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashView(),
        ),
        GoRoute(
          path: AppRoutes.login,
          // push: 약관 상세를 로그인 화면·약관 동의 시트 위에 쌓아 뒤로 가면 시트로 돌아온다.
          builder: (context, state) => LoginView(
            onViewTerm: (term) =>
                context.push(AppRoutes.termsDetailOf(term.id)),
          ),
        ),
        GoRoute(
          path: AppRoutes.termsDetail,
          // 경로는 termsDetailOf로만 만들어 숫자다. 아니면 없는 약관으로 보고 빈 화면을 보인다.
          builder: (context, state) => TermsDetailView(
            termId: int.tryParse(state.pathParameters['termId']!) ?? -1,
          ),
        ),
        // 하단 탭. 탭마다 스택을 따로 유지한다. 순서 = MainShell의 탭 순서.
        // 탭 안에서 이어지는 화면(예: /recruit/:postId)은 해당 branch의 routes 아래에 붙인다.
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomeView(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.recruit,
                  builder: (context, state) => const RecruitmentListView(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.chat,
                  builder: (context, state) => const ChatListView(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.my,
                  builder: (context, state) => MyPageView(
                    onSignOut: () =>
                        ref.read(sessionProvider.notifier).logout(),
                    activity: MyConcertsSection(
                      onOpenConcert: (concertId) async {
                        await context.push<void>(
                          AppRoutes.showOf('$concertId'),
                        );
                      },
                      // 149의 public 진입점은 extra 없이 밴드 선택부터 연다.
                      onAddConcert:
                          hasRoutePath(
                            GoRouter.of(context).configuration,
                            AppRoutes.showNew,
                          )
                          ? () async {
                              await context.push<int>(AppRoutes.showNew);
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // 고정 하위 경로(`/shows/new`)는 이보다 먼저 등록한다. 아니면 `new`가 showId로 잡힌다.
        concertShowRoute(),
      ],
    );
    ref.onDispose(() {
      router.dispose();
      session.dispose();
    });
    return router;
  },
  dependencies: [
    appEnvProvider,
    sessionProvider,
    myConcertsRepositoryProvider,
    myConcertsViewModelProvider,
  ],
);
