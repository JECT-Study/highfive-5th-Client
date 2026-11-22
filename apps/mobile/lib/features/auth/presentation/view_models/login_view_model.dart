import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import 'session_view_model.dart';

/// 로그인 화면의 명령. 성공하면 세션이 바뀌고 라우터가 홈으로 보낸다.
final loginViewModelProvider =
    AsyncNotifierProvider.autoDispose<LoginViewModel, void>(LoginViewModel.new);

class LoginViewModel extends AsyncNotifier<void> {
  // Future를 돌려주지 않아 처음부터 준비된 상태다. async면 첫 프레임 동안 로딩으로 보여 탭이 무시된다.
  @override
  void build() {}

  Future<void> login() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).login();
      await ref.read(sessionProvider.notifier).signIn(session);
    });
    if (ref.mounted) state = result;
  }
}
