import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/login_cancelled.dart';
import '../../models/login_failure.dart';
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
  const LoginState({this.pending, this.failure});

  /// 지금 로그인 중인 제공자. 그 버튼만 로딩으로 보인다. null이면 로그인 중이 아니다.
  final SocialProvider? pending;

  /// 마지막 로그인이 실패한 이유. 화면은 이 값이 생길 때 이유에 맞는 안내를 띄운다.
  /// 사용자가 취소한 것은 실패가 아니다 (null).
  final LoginFailureReason? failure;
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
    // 디버그 빌드에서만 오류 종류·메시지를 찍는다 (토큰은 오류에 담지 않는다).
    if (kDebugMode && result.hasError && result.error is! LoginCancelled) {
      debugPrint('[Login] ${provider.name} 실패: ${result.error}');
    }
    if (!ref.mounted) return;
    state = LoginState(failure: _failureOf(result.error));
  }

  /// SDK 오류처럼 이유를 모르는 실패는 [LoginFailureReason.unknown].
  static LoginFailureReason? _failureOf(Object? error) => switch (error) {
    null || LoginCancelled() => null,
    LoginFailure(:final reason) => reason,
    _ => LoginFailureReason.unknown,
  };
}
