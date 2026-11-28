import '../../models/concert_genre.dart';
import '../../models/host_band.dart';

/// 내가 대표자인 밴드 목록. 공연을 만들 때 주최 밴드를 고르는 데 쓴다.
abstract interface class HostBandRepository {
  Future<List<HostBand>> fetchHostBands();
}

/// 명세 없음: 밴드 조회 API가 아직 없어(밴드 기능 전) 고정된 임시 목록을 돌려준다.
/// API가 생기면 실제 구현을 만들고 `app/di.dart`의 등록 한 줄만 바꾼다.
class FakeHostBandRepository implements HostBandRepository {
  const FakeHostBandRepository({this.bands = devBands});

  /// dev 서버 임시 밴드 범위(1~5) 안의 ID와 Figma(2216:138580) 예시 이름·장르·팀원 수.
  /// 계정과 관계없이 같은 목록이며 모든 flavor에서 로컬 생성 구현하고만 짝지어 쓴다.
  static const devBands = [
    HostBand(
      id: 1,
      name: '소음공장',
      genres: [ConcertGenre.rock, ConcertGenre.indie],
      memberCount: 4,
    ),
    HostBand(
      id: 2,
      name: '대학밴드',
      genres: [ConcertGenre.pop, ConcertGenre.jazz],
      memberCount: 3,
    ),
  ];

  final List<HostBand> bands;

  @override
  Future<List<HostBand>> fetchHostBands() async => bands;
}
