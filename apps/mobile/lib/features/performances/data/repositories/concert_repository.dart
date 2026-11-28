import '../../models/concert_draft.dart';
import '../../models/concert_failure.dart';
import '../dto/concert_api_failure_dto.dart';
import '../services/concert_service.dart';

abstract interface class ConcertCreationRepository {
  bool hasUncertainCreation(HostBand band);
  Future<List<ConcertGenre>> fetchGenres();
  Future<int> create(HostBand band, ConcertDraft draft);
}

class ConcertRepository implements ConcertCreationRepository {
  ConcertRepository(this._service);

  final ConcertService _service;
  final _pendingBands = <int>{};
  final _uncertainBands = <int>{};

  @override
  bool hasUncertainCreation(HostBand band) => _uncertainBands.contains(band.id);

  @override
  Future<List<ConcertGenre>> fetchGenres() async => [
    for (final genre in await _service.fetchGenres())
      ConcertGenre(code: genre.code, name: genre.name),
  ];

  /// 같은 앱 실행 중 화면을 다시 열어도 불명확한 요청을 재전송하지 않는다.
  /// 해제하려면 향후 결과 조회 계약이 필요하다. 임의 재시도 버튼은 제공하지 않는다.
  @override
  Future<int> create(HostBand band, ConcertDraft draft) async {
    if (_pendingBands.contains(band.id) || hasUncertainCreation(band)) {
      throw const ConcertFailure(ConcertFailureKind.uncertain);
    }
    _pendingBands.add(band.id);
    try {
      return await _service.create(draft.toJson(band));
    } on ConcertApiFailureDto catch (error) {
      if (error.definitelyUnsent) {
        throw const ConcertFailure(ConcertFailureKind.notSent);
      }
      if (error.statusCode == 403 && error.code == 'AUTH_005') {
        throw const ConcertFailure(ConcertFailureKind.forbidden);
      }
      if (error.statusCode == 401 &&
          const {
            'AUTH_001',
            'AUTH_002',
            'AUTH_003',
            'AUTH_004',
          }.contains(error.code)) {
        throw const ConcertFailure(ConcertFailureKind.authentication);
      }
      if (error.statusCode == 400 &&
          const {
            'COMMON_004',
            'COMMON_001',
            'CONCERT_010',
            'CONCERT_002',
          }.contains(error.code)) {
        throw ConcertFailure(
          ConcertFailureKind.rejected,
          fields: switch (error.code) {
            'COMMON_004' => error.fields,
            'CONCERT_010' => {'startTime': '시작 시간과 종료 시간을 함께 선택해 주세요.'},
            'CONCERT_002' => {'performDate': '오늘 또는 이후 날짜를 선택해 주세요.'},
            _ => const {},
          },
        );
      }
      _uncertainBands.add(band.id);
      throw const ConcertFailure(ConcertFailureKind.uncertain);
    } finally {
      _pendingBands.remove(band.id);
    }
  }
}
