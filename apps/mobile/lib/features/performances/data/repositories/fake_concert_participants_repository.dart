import '../../../../core/error/app_exception.dart';
import '../../models/concert_participant.dart';
import 'concert_participants_repository.dart';

/// 라인업 조회 미배포 동안 쓰는 메모리 구현. 네트워크·세션·저장소를 쓰지 않는다.
/// 기본 데이터는 `FakeConcertRepository.sample`과 같은 공연 12 하나다.
class FakeConcertParticipantsRepository
    implements ConcertParticipantsRepository {
  FakeConcertParticipantsRepository({
    Map<int, List<ConcertParticipant>> participants = const {12: sample},
    Set<int> forbiddenConcertIds = const {},
  }) : _participants = {
         for (final MapEntry(:key, :value) in participants.entries)
           key: List.unmodifiable(value),
       },
       _forbiddenConcertIds = Set.unmodifiable(forbiddenConcertIds);

  final Map<int, List<ConcertParticipant>> _participants;
  final Set<int> _forbiddenConcertIds;

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) async {
    final participants = _participants[concertId];
    if (participants == null) {
      throw const ApiException(statusCode: 404, code: 'CONCERT_001');
    }
    if (_forbiddenConcertIds.contains(concertId)) {
      throw const ApiException(statusCode: 403, code: 'AUTH_005');
    }
    return participants;
  }

  /// 공연 12의 참여 밴드. 주최 밴드 3은 라인업 명세 예시 그대로다(공연 상세의 `hostBandId`·`myBandIds`와 같다).
  /// 두 번째 팀은 합류 1팀(`recruitment.joinedTeamCount`)을 보이려고 만든 합성 데이터로, 실제 밴드가 아니다.
  static const sample = [
    ConcertParticipant(
      bandId: 3,
      name: '새벽세시',
      isHost: true,
      profileImageUrl: null,
      genres: ['ROCK', 'INDIE'],
      memberCount: 4,
    ),
    ConcertParticipant(
      bandId: 9001,
      name: '오프비트',
      isHost: false,
      profileImageUrl: null,
      genres: ['ROCK'],
      memberCount: 4,
    ),
  ];
}
