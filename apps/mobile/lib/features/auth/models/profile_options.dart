import 'profile_draft.dart';

/// 장르·포지션 칩 하나. [code]는 저장 API로 보내고 [label]은 화면에 보인다.
typedef ProfileOption = ({String code, String label});

/// 선호 장르 칩 (Figma 순서). 코드 목록은 docs/api/profile.md "장르·포지션 코드".
const genreOptions = <ProfileOption>[
  (code: 'ROCK', label: '록'),
  (code: 'INDIE', label: '인디'),
  (code: 'METAL', label: '메탈'),
  (code: 'PUNK', label: '펑크'),
  (code: 'POP', label: '팝'),
  (code: 'JAZZ', label: '재즈'),
  (code: ProfileDraft.genreCustomCode, label: '직접입력'),
];

/// 연주 포지션 칩 (Figma 순서). "기타"는 악기(`GUITAR`)다.
const positionOptions = <ProfileOption>[
  (code: 'VOCAL', label: '보컬'),
  (code: 'GUITAR', label: '기타'),
  (code: 'BASS', label: '베이스'),
  (code: 'DRUM', label: '드럼'),
  (code: 'KEYBOARD', label: '키보드'),
  (code: ProfileDraft.positionCustomCode, label: '직접입력'),
];
