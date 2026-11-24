/// 로그인 실패 이유. 화면은 이유별로 안내 문구를 고른다.
enum LoginFailureReason {
  /// 서버가 소셜 토큰을 받아들이지 않았다 (`AUTH_006`).
  socialAuthFailed,

  /// 탈퇴한 계정이다 (`USER_004`).
  withdrawn,

  /// 서버에 닿지 못했다.
  network,

  /// 그 밖의 오류 (개발 오류·서버 오류·SDK 오류).
  unknown,
}

/// 로그인에 실패했다. 사용자가 취소한 것은 `LoginCancelled`다.
class LoginFailure implements Exception {
  const LoginFailure(this.reason, [this.cause]);

  final LoginFailureReason reason;

  /// 원래 오류. 디버그 로그에서 서버 오류 코드를 보려고 둔다.
  final Object? cause;

  @override
  String toString() => 'LoginFailure(${reason.name}, $cause)';
}
