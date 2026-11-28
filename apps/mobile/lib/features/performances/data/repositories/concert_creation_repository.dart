import '../../../../core/error/app_exception.dart';
import '../../models/concert_creation_failure.dart';
import '../../models/concert_draft.dart';
import '../../models/concert_genre.dart';
import '../../models/host_band.dart';
import '../dto/concert_create_dto.dart';
import '../services/concert_creation_service.dart';
import 'local_concert_creation_repository.dart';

/// 합동공연을 만든다. 서버 오류는 [ConcertCreationFailure]로 바꿔 던진다.
///
/// 결과 조회·멱등성 키 계약이 없어 실패한 요청을 스스로 다시 보내지 않는다. 다시 보낼지는 화면이 이유를 보고 정한다.
class ConcertCreationRepository {
  ConcertCreationRepository({LocalConcertCreationRepository? local})
    : _service = null,
      _local = local ?? LocalConcertCreationRepository();

  /// 로컬 HTTP 계약 테스트에서만 호출 어댑터를 명시적으로 주입한다.
  ConcertCreationRepository.forContractTest(
    ConcertCreationService service, {
    LocalConcertCreationRepository? local,
  }) : _service = service,
       _local = local ?? LocalConcertCreationRepository();

  final ConcertCreationService? _service;
  final LocalConcertCreationRepository _local;
  final _unconfirmedBands = <int>{};

  /// 세션이 끝나면 로컬 미리보기 입력을 보관하지 않는다.
  void clearLocalPreviews() => _local.clear();

  /// 폼을 열 때부터 전송 차단 이유를 표시한다. 임시 밴드의 로컬 생성은 허용한다.
  ConcertCreationFailureReason? blockReasonFor(HostBand band) {
    if (band.isFixture) return null;
    if (_service == null) return ConcertCreationFailureReason.unavailable;
    return _unconfirmedBands.contains(band.id)
        ? ConcertCreationFailureReason.uncertain
        : null;
  }

  /// [band]를 주최 팀으로 [draft] 공연을 만들고 공연 ID를 돌려준다. [draft]는 검증을 통과한 값이다.
  /// [abandoned]가 끝나면 보내는 중인 요청을 취소한다 (화면이 닫힘·로그아웃).
  Future<int> create(
    HostBand band,
    ConcertDraft draft, {
    Future<void>? abandoned,
  }) async {
    // 출처가 임시인 ID는 dev 서버에도 보내지 않는다.
    if (band.isFixture) return _local.create(band, draft);
    final service = _service;
    if (service == null) {
      throw const ConcertCreationFailure(
        ConcertCreationFailureReason.unavailable,
      );
    }
    // 결과 조회 계약이 생기기 전에는 재진입해도 같은 밴드의 원격 생성을 다시 보내지 않는다.
    if (_unconfirmedBands.contains(band.id)) {
      throw const ConcertCreationFailure(
        ConcertCreationFailureReason.uncertain,
      );
    }
    final request = ConcertCreateRequestDto(
      bandId: band.id,
      title: draft.title.trim(),
      genres: [
        for (final genre in ConcertGenre.values)
          if (draft.genres.contains(genre)) genre.code,
      ],
      recruitTeamCount: draft.recruitTeamCount,
      performDate: _isoDate(draft.performDate!),
      rentalFee: draft.rentalFee,
    );
    try {
      return (await service.create(request, abandoned: abandoned)).concertId;
    } catch (error) {
      // 네트워크 오류와 성공 응답 해석 오류를 이 외부 경계에서 같은 실패 모델로 바꾼다.
      final reason = error is AppException
          ? _reasonOf(error)
          : ConcertCreationFailureReason.uncertain;
      if (reason == ConcertCreationFailureReason.uncertain) {
        _unconfirmedBands.add(band.id);
      }
      throw ConcertCreationFailure(reason, error);
    }
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// 서버 오류 → 실패 이유 (docs/api/concert-create.md "에러").
  static ConcertCreationFailureReason _reasonOf(
    AppException error,
  ) => switch (error) {
    NetworkException() => ConcertCreationFailureReason.network,
    ApiException(statusCode: final status)
        when status == null || status < 400 || status >= 500 =>
      ConcertCreationFailureReason.uncertain,
    ApiException(code: 'CONCERT_002') => ConcertCreationFailureReason.pastDate,
    ApiException(code: 'COMMON_004' || 'COMMON_001' || 'CONCERT_010') =>
      ConcertCreationFailureReason.invalidInput,
    ApiException(code: 'AUTH_005') => ConcertCreationFailureReason.forbidden,
    ApiException() => ConcertCreationFailureReason.rejected,
    UnknownApiException() => ConcertCreationFailureReason.uncertain,
  };
}
