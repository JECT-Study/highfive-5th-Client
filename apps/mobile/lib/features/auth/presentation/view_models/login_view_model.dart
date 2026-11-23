import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/social_provider.dart';
import '../providers/auth_providers.dart';
import 'session_view_model.dart';

/// 로그인 화면의 명령. 성공하면 세션이 바뀌고 라우터가 홈으로 보낸다.
final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, LoginState>(
      LoginViewModel.new,
    );

/// 로그인 화면 상태.
class LoginState {
  const LoginState({this.pending, this.failed = false});

  /// 지금 로그인 중인 제공자. 그 버튼만 로딩으로 보인다. null이면 로그인 중이 아니다.
  final SocialProvider? pending;

  /// 마지막 로그인이 실패했다. 화면은 이 값이 true가 될 때 오류 안내를 띄운다.
  final bool failed;
}

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  /// 로그인 중에 다시 부르면 (다른 제공자여도) 무시한다.
  Future<void> login(SocialProvider provider) async {
    if (state.pending != null) return;
    state = LoginState(pending: provider);
    final result = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).login(provider);
      await ref.read(sessionProvider.notifier).signIn(session);
    });
    if (ref.mounted) state = LoginState(failed: result.hasError);
  }
}
