/// 장르·포지션 칩 하나. [code]는 저장 API로 보내고 [label]은 화면에 보인다.
typedef ProfileOption = ({String code, String label});

/// 프로필 화면의 선택지 (`GET /api/v1/codes?types=GENRE,POSITION`, docs/api/profile.md).
/// 서버가 준 순서대로 보인다.
typedef ProfileOptions = ({
  List<ProfileOption> genres,
  List<ProfileOption> positions,
});
