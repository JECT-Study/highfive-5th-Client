/// 약관 목록을 받거나 동의를 저장하지 못한 이유. 화면은 이유별로 안내 문구를 고른다.
enum TermsFailureReason {
  /// 서버에 닿지 못했다.
  network,

  /// 보낸 약관이 최신이 아니다 (`COMMON_004`). 목록을 다시 받아야 한다.
  termsChanged,

  /// 그 밖의 오류 (`USER_003` 필수 약관 미동의 포함. 앱이 버튼을 막으므로 정상이면 안 온다).
  unknown,
}

/// 약관 목록·동의 저장에 실패했다.
class TermsFailure implements Exception {
  const TermsFailure(this.reason, [this.cause]);

  final TermsFailureReason reason;

  /// 원래 오류. 디버그 로그에서 서버 오류 코드를 보려고 둔다.
  final Object? cause;

  @override
  String toString() => 'TermsFailure(${reason.name}, $cause)';
}
