import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/views/login_view.dart';
import '../features/chat/presentation/views/chat_list_view.dart';
import '../features/home/presentation/views/home_view.dart';
import '../features/my_page/presentation/views/my_page_view.dart';
import '../features/recruitments/presentation/views/recruitment_list_view.dart';
import 'main_shell.dart';
import 'routes.dart';

/// 인증 redirect를 붙일 때는 세션 상태를 `ref.listen`으로 구독해 `refreshListenable`에 연결한다.
/// `ref.watch`로 GoRouter를 다시 만들면 내비게이션 스택이 초기화되므로 쓰지 않는다.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
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
                builder: (context, state) => const MyPageView(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
