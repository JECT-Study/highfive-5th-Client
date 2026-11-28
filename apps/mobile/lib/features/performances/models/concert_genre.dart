/// 합동공연 연주 장르.
///
/// [code]는 Swagger `ConcertCreateRequest.genres`의 코드, [label]은 Figma
/// `공연열고 팀 모집`(2217:123040) 칩 글자다. 순서도 Figma 칩 순서와 같다.
enum ConcertGenre {
  rock('ROCK', '록'),
  indie('INDIE', '인디'),
  metal('METAL', '메탈'),
  punk('PUNK', '펑크'),
  pop('POP', '팝'),
  jazz('JAZZ', '재즈'),

  /// 서버가 직접 입력 값(`customGenre`)을 아직 받지 않아 코드만 보낸다 (Notion 명세 [합의 필요], JECT-252).
  etc('ETC', '직접입력');

  const ConcertGenre(this.code, this.label);

  final String code;
  final String label;
}
