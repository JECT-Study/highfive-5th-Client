import '../../models/concert_draft.dart';
import '../../models/concert_edit_failure.dart';
import '../../models/concert_edit_values.dart';
import '../../models/concert_failure.dart';
import 'concert_edit_repository.dart';
import 'concert_repository.dart';

/// 명시적 dev/debug 시작점 전용. 서버 데이터·권한·버전의 대체 계약이 아니다.
/// 공연은 빈 저장소에서 생성하며 ID별로 전체 값을 보관한다.
class OfflineConcertRepository implements ConcertCreationRepository {
  final hostBands = [
    HostBand(id: 1, name: '오프라인 주최 밴드 A'),
    HostBand(id: 2, name: '오프라인 주최 밴드 B'),
  ];
  static const _genres = [
    (code: 'ROCK', name: '록'),
    (code: 'INDIE', name: '인디'),
    (code: 'METAL', name: '메탈'),
    (code: 'PUNK', name: '펑크'),
    (code: 'POP', name: '팝'),
    (code: 'JAZZ', name: '재즈'),
  ];
  final _records = <int, ({HostBand host, ConcertEditSnapshot snapshot})>{};
  int _nextId = 1;

  List<int> get ids => List.unmodifiable(_records.keys);

  HostBand hostOf(int id) => _records[id]!.host;

  ConcertEditSnapshot snapshot(int id) {
    final record = _records[id];
    if (record == null) {
      throw const ConcertEditFailure(ConcertEditFailureKind.missing);
    }
    return record.snapshot;
  }

  @override
  bool hasUncertainCreation(HostBand band) => false;

  @override
  Future<List<ConcertGenre>> fetchGenres() async => [
    for (final genre in _genres)
      ConcertGenre(code: genre.code, name: genre.name),
  ];

  @override
  Future<int> create(HostBand band, ConcertDraft draft) async {
    if (!hostBands.contains(band)) {
      throw const ConcertFailure(ConcertFailureKind.forbidden);
    }
    final fields = draft.toJson(band)..remove('bandId');
    final id = _nextId++;
    _records[id] = (
      host: band,
      snapshot: ConcertEditSnapshot(
        // 이 버전은 메모리 저장소가 소유한다. POST 응답에서 추론하지 않는다.
        values: ConcertEditValues.fromJson({
          ...fields,
          'region': null,
          'version': 1,
        }),
        isParticipant: true,
        joinedTeamCount: 0,
        genres: _genres,
      ),
    );
    return id;
  }

  ConcertEditRepository edit(int id) {
    snapshot(id);
    return _OfflineConcertEditRepository(this, id);
  }

  void _save(int id, ConcertEditValues values) {
    final current = snapshot(id);
    if (values.version != current.values.version) {
      throw const ConcertEditFailure(ConcertEditFailureKind.conflict);
    }
    _records[id] = (
      host: hostOf(id),
      snapshot: ConcertEditSnapshot(
        values: ConcertEditValues.fromJson({
          ...values.toJson(),
          'version': values.version + 1,
        }),
        isParticipant: current.isParticipant,
        joinedTeamCount: current.joinedTeamCount,
        genres: current.genres,
      ),
    );
  }
}

class _OfflineConcertEditRepository implements ConcertEditRepository {
  const _OfflineConcertEditRepository(this.store, this.id);
  final OfflineConcertRepository store;
  final int id;

  @override
  Future<ConcertEditSnapshot> reload() async => store.snapshot(id);

  @override
  Future<void> save(ConcertEditValues values) async => store._save(id, values);
}
