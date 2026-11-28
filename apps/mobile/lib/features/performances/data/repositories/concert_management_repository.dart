import 'concert_participants_repository.dart';
import 'concert_repository.dart';

/// DELETE 공연·참여 밴드 초안 계약. 배포 전까지 DI에는 fake만 연결한다.
abstract interface class ConcertManagementRepository
    implements ConcertRepository, ConcertParticipantsRepository {
  bool get active;
  Stream<void> get sessionEnded;
  void endSession();
  Future<void> deleteConcert(int concertId);
  Future<void> removeBand(int concertId, int bandId);
}
