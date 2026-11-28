import '../../models/concert_draft.dart';
import '../../models/host_band.dart';

/// 임시 밴드의 로컬 미리보기. 네트워크·서버·기기 저장소에는 쓰지 않는다.
/// 음수 ID로 실제 서버 ID와 구분하며 앱을 종료하면 사라진다.
class LocalConcertCreationRepository {
  final _concerts = <int, ({HostBand band, ConcertDraft draft})>{};
  int _lastId = 0;

  Map<int, ({HostBand band, ConcertDraft draft})> get concerts =>
      Map.unmodifiable(_concerts);

  void clear() => _concerts.clear();

  Future<int> create(HostBand band, ConcertDraft draft) async {
    final id = --_lastId;
    _concerts[id] = (band: band, draft: draft);
    return id;
  }
}
