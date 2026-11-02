import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/views/login_view.dart';

/// 경로 문자열은 여기서만 정의한다. View는 자기 경로를 모른다.
abstract final class AppRoutes {
  static const login = '/login';
}

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
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
