import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/offline_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/models/concert_edit_failure.dart';
import 'package:highfive/features/performances/models/concert_edit_values.dart';
import 'package:highfive/features/performances/models/concert_failure.dart';

void main() {
  const draft = ConcertDraft(
    title: '저장소 공연',
    genres: {'ROCK'},
    recruitTeamCount: 2,
    startTime: ConcertTime(19, 0),
    endTime: ConcertTime(21, 30),
    place: '연습 공연장',
    address: '예시 주소',
    rentalFeeText: '12345',
  );

  test('다른 밴드 공연의 전체 값은 유지하고 오래된 버전의 저장을 거절한다', () async {
    final store = OfflineConcertRepository();
    final a = await store.create(store.hostBands.first, draft);
    final b = await store.create(store.hostBands.last, draft);
    expect(a, isNot(b));
    final first = await store.edit(a).reload();
    final edited = ConcertEditForm(first.values)..title = '수정된 첫 공연';
    await store.edit(a).save(edited.replace(first.values));

    final saved = await store.edit(a).reload();
    expect(saved.values.title, '수정된 첫 공연');
    expect(saved.values.version, 2);
    expect(saved.values.startTime, '19:00:00');
    expect(saved.values.endTime, '21:30:00');
    expect(saved.values.rentalFee, 12345);
    expect(saved.values.address, '예시 주소');
    expect(saved.values.region, isNull);
    expect(saved.values.posterImageUrl, isNull);
    expect(store.snapshot(b).values.title, '저장소 공연');
    expect(store.snapshot(b).values.version, 1);
    expect(store.hostOf(b), store.hostBands.last);
    await expectLater(
      store.edit(a).save(edited.replace(first.values)),
      throwsA(
        isA<ConcertEditFailure>().having(
          (e) => e.kind,
          'kind',
          ConcertEditFailureKind.conflict,
        ),
      ),
    );
    expect(store.snapshot(a).values.title, '수정된 첫 공연');
  });

  test('알 수 없는 밴드와 없는 공연은 데이터를 만들거나 대신 보여주지 않는다', () async {
    final store = OfflineConcertRepository();
    await expectLater(
      store.create(HostBand(id: 99, name: '알 수 없는 밴드'), draft),
      throwsA(isA<ConcertFailure>()),
    );
    expect(store.ids, isEmpty);
    expect(() => store.edit(1), throwsA(isA<ConcertEditFailure>()));
  });
}
