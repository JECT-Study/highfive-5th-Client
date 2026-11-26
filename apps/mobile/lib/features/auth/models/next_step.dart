/// 로그인 직후 앱이 갈 화면 (서버 `nextStep`). 위에서부터 순서대로 거친다.
enum NextStep {
  /// 약관 동의
  terms,

  /// 개인 프로필 만들기
  profile,

  /// 밴드 시작
  bandStart,

  /// 홈
  home,
}
