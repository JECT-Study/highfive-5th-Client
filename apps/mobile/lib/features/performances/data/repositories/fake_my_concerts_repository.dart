import '../../../../core/error/app_exception.dart';
import '../../models/concert_detail.dart';
import '../../models/concert_participant.dart';
import '../../models/concert_status.dart';
import '../../models/my_concert.dart';
import '../../models/recruitment_status.dart';
import 'concert_repository.dart';
import 'fake_concert_participants_repository.dart';
import 'fake_concert_repository.dart';
import 'my_concerts_repository.dart';

/// 목록 API가 생기기 전 메모리 구현. 네트워크·세션·저장소를 쓰지 않는다.
///
/// 카드는 공연 상세 Repository에서 같은 ID로 읽어 만든다. `app/di.dart`가 [samples]와
/// [participantSamples]를 공연 페이지가 쓰는 상세·참여 밴드 fake에도 넣으므로,
/// 카드를 눌러 연 페이지가 그 카드의 공연을 보여 준다.
class FakeMyConcertsRepository implements MyConcertsRepository {
  FakeMyConcertsRepository(this._concerts, {Iterable<int>? concertIds})
    : _concertIds = List.unmodifiable(
        concertIds ?? samples.map((concert) => concert.concertId),
      );

  final ConcertRepository _concerts;
  final List<int> _concertIds;

  @override
  Future<List<MyConcert>> fetchMyConcerts() async {
    final concerts = await Future.wait(_concertIds.map(_fetchVisibleConcert));
    return concerts.nonNulls.toList();
  }

  /// 예시 ID 목록은 삭제·탈퇴 뒤에도 남을 수 있다. 확인된 두 코드만 건너뛰고,
  /// 네트워크·5xx·알 수 없는 오류는 실패로 남겨 재시도할 수 있게 한다.
  Future<MyConcert?> _fetchVisibleConcert(int concertId) async {
    try {
      final detail = await _concerts.fetchDetail(concertId);
      return detail.myBandIds.isEmpty ? null : _toMyConcert(detail);
    } on ApiException catch (error) {
      if ((error.statusCode == 404 && error.code == 'CONCERT_001') ||
          (error.statusCode == 403 && error.code == 'AUTH_005')) {
        return null;
      }
      rethrow;
    }
  }

  /// 내 공연 예시: 명세 예시 공연 12에 진행 중 공연(주최 대표자·참여 팀)과 지난 공연을 더한다.
  /// 내 밴드는 명세 예시의 3(새벽세시)을 재사용한다. 추가 공연·공고(99000x)와 밴드(9002)는
  /// 합성 데이터다. ID 크기는 실서버 쓰기 방어가 아니므로 수정도 메모리 저장소와 연결해야 한다.
  static final samples = <ConcertDetail>[
    FakeConcertRepository.sample,
    _hostSample,
    _participantSample,
    _pastSample,
  ];

  /// [samples]의 참여 밴드. 12는 참여 밴드 fake의 기본 데이터 그대로다.
  static final participantSamples = <int, List<ConcertParticipant>>{
    FakeConcertRepository.sample.concertId:
        FakeConcertParticipantsRepository.sample,
    _hostSample.concertId: const [
      _myBand,
      ConcertParticipant(bandId: 9001, name: '오프비트', isHost: false),
      ConcertParticipant(bandId: _otherHostBandId, name: '소음공장', isHost: false),
    ],
    _participantSample.concertId: const [_otherHostBand, _myBandAsGuest],
    _pastSample.concertId: const [
      _otherHostBand,
      _myBandAsGuest,
      ConcertParticipant(bandId: 9001, name: '오프비트', isHost: false),
    ],
  };

  static const _myBand = ConcertParticipant(
    bandId: 3,
    name: '새벽세시',
    isHost: true,
  );
  static const _myBandAsGuest = ConcertParticipant(
    bandId: 3,
    name: '새벽세시',
    isHost: false,
  );

  /// 예시용 합성 밴드 (실제 밴드가 아니다).
  static const _otherHostBandId = 9002;
  static const _otherHostBand = ConcertParticipant(
    bandId: _otherHostBandId,
    name: '소음공장',
    isHost: true,
  );

  /// 내 밴드(3)가 주최하고 내가 주최 대표자인 공연. 이 공연에만 대표자 권한이 있다.
  static final _hostSample = FakeConcertRepository.sample.copyWith(
    concertId: 990001,
    title: '새벽세시 신년 합동공연',
    recruitTeamCount: 2,
    performDate: '2027-01-15',
    startTime: '19:00:00',
    endTime: '22:00:00',
    status: ConcertStatus.selling,
    myPermissions: const ConcertPermissions(
      isHostLeader: true,
      isTeamLeader: true,
    ),
    recruitment: const ConcertRecruitment(
      recruitPostId: 990001,
      status: RecruitmentStatus.closed,
      deadline: '2026-12-10',
      joinedTeamCount: 2,
      recruitTeamCount: 2,
      newInquiryCount: 0,
    ),
  );

  /// 합성 밴드(9002)가 주최하고 내 밴드(3)가 참여한 공연. 장소가 아직 정해지지 않았다.
  static final _participantSample = FakeConcertRepository.sample.copyWith(
    concertId: 990002,
    title: '소음공장 합동공연',
    performDate: '2027-02-06',
    place: null,
    address: null,
    region: null,
    rentalFee: null,
    status: ConcertStatus.recruiting,
    hostBandId: _otherHostBandId,
    myPermissions: const ConcertPermissions(
      isHostLeader: false,
      isTeamLeader: true,
    ),
    recruitment: const ConcertRecruitment(
      recruitPostId: 990002,
      status: RecruitmentStatus.recruiting,
      deadline: '2027-01-20',
      joinedTeamCount: 1,
      recruitTeamCount: 3,
      newInquiryCount: 0,
    ),
  );

  /// 내 밴드(3)가 참여했던 지난 공연. '공연 이력'에 보인다.
  static final _pastSample = FakeConcertRepository.sample.copyWith(
    concertId: 990003,
    title: '홍대 인디나잇',
    recruitTeamCount: 2,
    performDate: '2026-10-02',
    startTime: '18:00:00',
    endTime: '21:00:00',
    status: ConcertStatus.saleClosed,
    hostBandId: _otherHostBandId,
    myPermissions: const ConcertPermissions(
      isHostLeader: false,
      isTeamLeader: true,
    ),
    recruitment: const ConcertRecruitment(
      recruitPostId: 990003,
      status: RecruitmentStatus.closed,
      deadline: '2026-09-01',
      joinedTeamCount: 2,
      recruitTeamCount: 2,
      newInquiryCount: 0,
    ),
  );
}

/// 상세 응답을 카드 값으로 바꾼다. 목록 API가 생기면 그 응답의 DTO가 이 일을 맡는다.
MyConcert _toMyConcert(ConcertDetail detail) => MyConcert(
  concertId: detail.concertId,
  title: detail.title,
  status: detail.status,
  performDate: detail.performDate,
  startTime: detail.startTime,
  area:
      _area(detail.address) ??
      switch (detail.place?.trim()) {
        null || '' => null,
        final place => place,
      },
  // 대표자 권한(myPermissions)이 아니라 내 밴드가 주최 팀인지로 본다.
  isHost: detail.myBandIds.contains(detail.hostBandId),
  posterImageUrl: detail.posterImageUrl,
);

/// 명세 없음: 카드의 지역 글자. 주소 앞 두 단어(시·구)로 만든다
/// (예: `서울 마포구 어울마당로 35` → `서울 마포구`).
String? _area(String? address) {
  final words =
      address?.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty) ??
      const <String>[];
  return words.isEmpty ? null : words.take(2).join(' ');
}
