import '../../../../core/error/app_exception.dart';
import '../../models/lineup.dart';

/// 장르 코드의 화면 이름.
/// 명세 없음: 이름은 `GET /api/v1/codes?types=GENRE`(Swagger)가 주지만 앱에 코드 목록 연동이 아직 없다.
/// 록·인디·팝·재즈는 Figma 문구, 메탈·펑크·기타는 코드의 우리말 표기다. 연동하면 이 표를 지운다.
const _genreNames = {
  'ROCK': '록',
  'INDIE': '인디',
  'METAL': '메탈',
  'PUNK': '펑크',
  'POP': '팝',
  'JAZZ': '재즈',
  'ETC': '기타',
};

/// 장르 코드 여러 개를 "록, 인디"처럼 쉼표로 잇는다. 모르는 코드는 그대로 보인다.
String genreNames(List<String> codes) =>
    codes.map((code) => _genreNames[code] ?? code).join(', ');

/// 곡 길이(초)를 "4:12"로 바꾼다 (명세 1.7 FE 참고: 앱이 durationSeconds로 계산).
String formatDuration(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// 곡 제목 아래 줄. 검색한 곡은 아티스트, 자작곡은 "밴드 이름 (자작곡)" (명세 1.7 FE 참고).
String songSubtitle(LineupSong song, String bandName) => switch (song.type) {
  SongType.searched => song.artist ?? '',
  SongType.original => '$bandName (자작곡)',
};

/// 실패 안내 문구. 서버가 준 문구(명세의 message)가 있으면 그대로 쓰고,
/// 서버에 닿지 못했으면 공통 문구, 그 밖에는 [fallback]을 쓴다.
String failureMessage(Object? error, String fallback) => switch (error) {
  ApiException(:final message?) when message.isNotEmpty => message,
  NetworkException() => '네트워크 상태를 확인하고 다시 시도해 주세요.',
  _ => fallback,
};
