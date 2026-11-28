/// 코드 목록 초안(`GET /api/v1/codes?types=GENRE`)의 표시 이름.
/// 헤더와 참여 밴드 프로필의 코드→이름 projection이다. 코드 목록 API 연결 전까지 예시 값을 쓰고,
/// 앱이 모르는 코드는 이름을 추측하지 않고 숨긴다.
String? concertGenreLabel(String code) => _genreNames[code];

const _genreNames = {
  'ROCK': '록',
  'INDIE': '인디',
  'METAL': '메탈',
  'PUNK': '펑크',
  'POP': '팝',
  'JAZZ': '재즈',
  'ETC': '기타',
};
