/// 공연 수정 화면의 장르 선택값과 표시 이름.
///
/// 코드는 `PUT /api/v1/concerts/{concertId}`의 `genres` enum(Swagger 2026-11-28)과 같다.
/// 이름은 `GET /api/v1/codes?types=GENRE` 명세 예시를 따른다. 코드 API로 받을지 앱에 둘지는
/// 명세의 "결정 필요"(회의 D4)로 남아 있다. 생성 화면과 ETC 표시 맥락이 달라 별도로 두며,
/// 코드 API 사용이 정해지면 공용 코드 테이블로 합친다.
const concertGenres = <({String code, String name})>[
  (code: 'ROCK', name: '록'),
  (code: 'INDIE', name: '인디'),
  (code: 'METAL', name: '메탈'),
  (code: 'PUNK', name: '펑크'),
  (code: 'POP', name: '팝'),
  (code: 'JAZZ', name: '재즈'),
  (code: 'ETC', name: '기타'),
];

/// 목록에 없는 코드(서버에 새로 생긴 장르)는 코드를 그대로 보인다.
String concertGenreName(String code) {
  for (final genre in concertGenres) {
    if (genre.code == code) return genre.name;
  }
  return code;
}
