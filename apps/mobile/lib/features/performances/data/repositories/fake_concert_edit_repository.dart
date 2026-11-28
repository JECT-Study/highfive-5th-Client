import '../../../../core/error/app_exception.dart';
import '../../models/concert_detail.dart';
import '../../models/concert_edit_failure.dart';
import '../../models/concert_edit_form.dart';
import '../../models/concert_update.dart';
import 'concert_edit_repository.dart';
import 'fake_concert_repository.dart';

/// 공연 GET이 미배포인 동안 쓰는 메모리 구현. 네트워크·세션·저장소를 쓰지 않는다.
///
/// [FakeConcertRepository]의 상세 위에 저장한 값을 덧씌워, 저장한 뒤 상세를 다시 읽으면
/// 바뀐 값과 1 올라간 version이 보인다. 상세가 가짜인 동안 실서버 PUT을 보내면 가짜 공연 ID·version이
/// 같은 ID의 다른 실제 공연을 덮어쓸 수 있어, GET과 PUT을 이 한 객체로 묶어 DI에 등록한다 (app/di.dart).
class FakeConcertEditRepository extends FakeConcertRepository
    implements ConcertEditRepository {
  FakeConcertEditRepository({super.concerts, super.forbiddenConcertIds});

  final _saved = <int, ConcertDetail>{};

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async =>
      _saved[concertId] ?? await super.fetchDetail(concertId);

  /// 서버 처리 순서(명세 1.3)대로 공연·참여 권한·version·합류 팀 수를 확인하고 바꾼다.
  /// 날짜 규칙(`CONCERT_002`·`CONCERT_011`)은 화면 검증에 맡기고 여기서는 보지 않는다.
  @override
  Future<void> update(int concertId, ConcertUpdate update) async {
    final ConcertDetail loaded;
    try {
      loaded = await fetchDetail(concertId);
    } on ApiException catch (error) {
      throw ConcertEditFailure(
        error.statusCode == 403
            ? ConcertEditFailureReason.forbidden
            : ConcertEditFailureReason.missing,
        cause: error,
      );
    }
    // 조회를 기다리는 사이 다른 저장이 끝날 수 있다. 비교와 기록 사이에는 await가 없다.
    final current = _saved[concertId] ?? loaded;
    if (update.version != current.version) {
      throw const ConcertEditFailure(ConcertEditFailureReason.conflict);
    }
    if (update.recruitTeamCount < (current.recruitment?.joinedTeamCount ?? 0)) {
      throw const ConcertEditFailure(
        ConcertEditFailureReason.invalid,
        issues: {
          ConcertEditField.recruitTeamCount: ConcertEditIssue.belowJoinedTeams,
        },
      );
    }
    _saved[concertId] = current.copyWith(
      title: update.title,
      // 서버처럼 중복 장르를 하나로 합친다.
      genres: List.unmodifiable(update.genres.toSet()),
      recruitTeamCount: update.recruitTeamCount,
      performDate: update.performDate,
      startTime: update.startTime,
      endTime: update.endTime,
      place: update.place,
      address: update.address,
      region: update.region,
      rentalFee: update.rentalFee,
      posterImageUrl: update.posterImageUrl,
      // 명세: 공연 정보 수정은 모집 공고에도 반영된다.
      recruitment: current.recruitment?.copyWith(
        recruitTeamCount: update.recruitTeamCount,
      ),
      version: current.version + 1,
    );
  }
}
