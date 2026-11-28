import '../../../../core/error/app_exception.dart';
import '../../models/concert_detail.dart';
import '../../models/concert_status.dart';
import '../../models/recruitment_status.dart';
import 'concert_repository.dart';

/// GET 미배포 동안 사용하는 메모리 구현. 네트워크·세션·저장소를 쓰지 않는다.
class FakeConcertRepository implements ConcertRepository {
  FakeConcertRepository({
    Iterable<ConcertDetail> concerts = const [sample],
    Set<int> forbiddenConcertIds = const {},
  }) : _concerts = {for (final concert in concerts) concert.concertId: concert},
       _forbiddenConcertIds = Set.unmodifiable(forbiddenConcertIds);

  final Map<int, ConcertDetail> _concerts;
  final Set<int> _forbiddenConcertIds;

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async {
    final concert = _concerts[concertId];
    if (concert == null) {
      throw const ApiException(statusCode: 404, code: 'CONCERT_001');
    }
    if (_forbiddenConcertIds.contains(concertId)) {
      throw const ApiException(statusCode: 403, code: 'AUTH_005');
    }
    return concert;
  }

  /// 명세 예시의 공연 12. 가짜 데이터가 관리 권한을 부여하지 않도록 두 값은 false.
  static const sample = ConcertDetail(
    concertId: 12,
    title: '겨울 합동공연',
    genres: ['ROCK', 'INDIE'],
    recruitTeamCount: 3,
    performDate: '2026-12-20',
    startTime: null,
    endTime: null,
    place: '홍대 롤링홀',
    address: '서울 마포구 어울마당로 35',
    region: 'SEOUL',
    rentalFee: 500000,
    posterImageUrl: null,
    status: ConcertStatus.recruiting,
    hostBandId: 3,
    myBandIds: [3],
    myPermissions: ConcertPermissions(isHostLeader: false, isTeamLeader: false),
    recruitment: ConcertRecruitment(
      recruitPostId: 5,
      status: RecruitmentStatus.recruiting,
      deadline: '2026-12-01',
      joinedTeamCount: 1,
      recruitTeamCount: 3,
      newInquiryCount: 2,
    ),
    version: 3,
    updatedAt: '2026-11-11T14:02:00',
  );
}
