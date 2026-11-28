import 'concert_genre.dart';

/// 공연을 만들 수 있는 밴드(내가 대표자인 밴드). 고른 밴드가 주최 팀이 되고 [id]가 생성 요청의 `bandId`다.
///
/// 명세 없음: 밴드 조회 API가 아직 없다(밴드 기능 전). [genres]·[memberCount]는
/// Figma `마이페이지-공연추가_밴드선택시트`(2216:138580)가 보여 주는 항목에 맞춘 가정이다.
class HostBand {
  const HostBand({
    required this.id,
    required this.name,
    required this.genres,
    required this.memberCount,
  }) : isFixture = true;

  /// 인증된 서버 응답/밴드 프로필에서 현재 계정의 대표자임을 확인한 경우에만 쓴다.
  /// 임시 목록이나 임의의 숫자 ID를 이 생성자로 감싸면 안 된다.
  const HostBand.authenticated({
    required this.id,
    required this.name,
    required this.genres,
    required this.memberCount,
  }) : isFixture = false;

  /// 기본 생성자의 밴드는 모든 flavor에서 로컬 미리보기로만 만든다.
  final bool isFixture;
  final int id;
  final String name;
  final List<ConcertGenre> genres;
  final int memberCount;
}
