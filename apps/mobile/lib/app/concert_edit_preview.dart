import 'package:flutter/material.dart';

import '../features/performances/data/repositories/concert_edit_repository.dart';
import '../features/performances/models/concert_edit_values.dart';
import '../features/performances/presentation/view_models/concert_edit_view_model.dart';
import '../features/performances/presentation/views/concert_edit_view.dart';

/// dev 라우터에만 등록한다. ID, Dio, 실제 Repository를 전혀 만들지 않는다.
class ConcertEditPreview extends StatefulWidget {
  const ConcertEditPreview({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  State<ConcertEditPreview> createState() => _ConcertEditPreviewState();
}

class _ConcertEditPreviewState extends State<ConcertEditPreview> {
  late final _repository = _OfflineConcertEditRepository();
  late final _entry = ConcertEditEntry(
    initial: _repository.snapshot,
    repository: _repository,
    isSessionCurrent: () => true,
    offline: true,
  );

  @override
  Widget build(BuildContext context) => ConcertEditView(
    entry: _entry,
    onClose: widget.onClose,
    // 저장 후에도 안전한 미리보기에 남아 다시 읽어 볼 수 있다.
    onSaved: () {},
  );
}

class _OfflineConcertEditRepository implements ConcertEditRepository {
  ConcertEditSnapshot snapshot = ConcertEditSnapshot(
    values: ConcertEditValues(
      title: '겨울 합동공연 미리보기',
      genres: ['ROCK', 'INDIE'],
      recruitTeamCount: 3,
      performDate: null,
      startTime: '19:00:00',
      endTime: '21:00:00',
      place: '미리보기 공연장',
      address: '오프라인 예시 주소',
      region: null,
      rentalFee: 500000,
      posterImageUrl: null,
      version: 1,
    ),
    isParticipant: true,
    joinedTeamCount: 1,
    genres: [(code: 'ROCK', name: '록'), (code: 'INDIE', name: '인디')],
  );

  @override
  Future<void> save(ConcertEditValues values) async {
    snapshot = ConcertEditSnapshot(
      values: ConcertEditValues.fromJson({
        ...values.toJson(),
        'version': values.version + 1,
      }),
      isParticipant: snapshot.isParticipant,
      joinedTeamCount: snapshot.joinedTeamCount,
      genres: snapshot.genres,
    );
  }

  @override
  Future<ConcertEditSnapshot> reload() async => snapshot;
}
