/// 닉네임 확인·프로필 저장에 실패한 이유. 화면은 이유별로 안내 문구와 다음 동작을 고른다.
enum ProfileFailureReason {
  /// 서버에 닿지 못했다.
  network,

  /// 저장하는 사이 다른 사람이 같은 닉네임을 가져갔다 (`USER_001`). 닉네임을 다시 고른다.
  nicknameTaken,

  /// 사진을 올리지 못했다. 용량을 안내하고 다시 시도하게 한다 (기능명세서).
  photoUploadFailed,

  /// 서버 검증에 걸렸다 (`COMMON_004`). 앱이 같은 규칙으로 막으므로 정상이면 안 온다.
  invalidInput,

  /// 필수 약관 미동의 (`USER_003`). 약관 시트로 돌아간다.
  termsRequired,

  /// 토큰의 회원이 없다 (`USER_005`). 로그아웃한다.
  userNotFound,

  /// 그 밖의 오류.
  unknown,
}

/// 닉네임 확인·프로필 저장에 실패했다.
class ProfileFailure implements Exception {
  const ProfileFailure(this.reason, [this.cause]);

  final ProfileFailureReason reason;

  /// 원래 오류. 디버그 로그에서 서버 오류 코드를 보려고 둔다.
  final Object? cause;

  @override
  String toString() => 'ProfileFailure(${reason.name}, $cause)';
}
