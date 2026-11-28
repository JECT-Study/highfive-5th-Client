import '../../models/my_concert.dart';

/// 마이페이지 '내 공연' 목록의 계약.
///
/// 명세 없음: 목록 API가 아직 없어 메모리 구현(`FakeMyConcertsRepository`)만 있다.
/// API가 생기면 Service를 붙인 구현을 만들고 `app/di.dart`의 등록만 바꾼다.
abstract interface class MyConcertsRepository {
  /// 내 밴드가 주최하거나 참여하는 공연 전체. 진행 중·지난 공연을 함께 받는다.
  Future<List<MyConcert>> fetchMyConcerts();
}
