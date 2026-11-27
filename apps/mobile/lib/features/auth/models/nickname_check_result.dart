/// "중복 확인" 결과 (서버 `available`·`reason`, docs/api/profile.md).
enum NicknameCheckResult {
  /// 쓸 수 있다
  available,

  /// 2~10자가 아니다
  invalidLength,

  /// 한글·영문·숫자 외의 문자가 있다
  invalidCharacter,

  /// 다른 사람이 쓰고 있다
  duplicated,

  /// 서버가 모르는 사유로 막았다
  unavailable,
}
