import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_edit_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_edit_failure.dart';
import 'package:highfive/features/performances/models/concert_edit_form.dart';
import 'package:highfive/features/performances/models/concert_update.dart';

const _sample = FakeConcertRepository.sample;
final _original = ConcertUpdate.fromDetail(_sample);

Matcher _fails(ConcertEditFailureReason reason) => throwsA(
  isA<ConcertEditFailure>().having((e) => e.reason, 'reason', reason),
);

void main() {
  test('같은 version의 동시 저장은 하나만 성공하고 version을 한 번 올린다', () async {
    final repository = FakeConcertEditRepository();
    Future<Object?> save(String title) => repository
        .update(12, _original.copyWith(title: title))
        .then<Object?>((_) => null, onError: (Object error) => error);

    final results = await Future.wait([save('A'), save('B')]);

    expect(results.where((result) => result == null), hasLength(1));
    expect(
      results.whereType<ConcertEditFailure>().single.reason,
      ConcertEditFailureReason.conflict,
    );
    final detail = await repository.fetchDetail(12);
    expect(detail.version, _sample.version + 1);
    expect(detail.title, results.first == null ? 'A' : 'B');
  });

  test('저장한 값과 새 version이 상세 조회에 보인다', () async {
    final repository = FakeConcertEditRepository();
    await repository.update(
      12,
      _original.copyWith(
        title: '새 제목',
        recruitTeamCount: 4,
        genres: ['ROCK', 'ROCK', 'POP'],
      ),
    );

    final detail = await repository.fetchDetail(12);
    expect(detail.title, '새 제목');
    expect(detail.genres, ['ROCK', 'POP']);
    expect(detail.version, _sample.version + 1);
    expect(detail.recruitTeamCount, 4);
    expect(detail.recruitment!.recruitTeamCount, 4);
    expect(detail.myPermissions, _sample.myPermissions);
    expect(detail.myBandIds, _sample.myBandIds);
  });

  test('예전 version으로 저장하면 먼저 저장한 값을 덮어쓰지 않는다', () async {
    final repository = FakeConcertEditRepository();
    await repository.update(12, _original.copyWith(title: '먼저 저장'));

    await expectLater(
      repository.update(12, _original.copyWith(title: '늦게 저장')),
      _fails(ConcertEditFailureReason.conflict),
    );
    expect((await repository.fetchDetail(12)).title, '먼저 저장');
  });

  test('없는 공연과 볼 수 없는 공연은 저장하지 않는다', () async {
    await expectLater(
      FakeConcertEditRepository().update(99, _original),
      _fails(ConcertEditFailureReason.missing),
    );
    await expectLater(
      FakeConcertEditRepository(forbiddenConcertIds: {12})
          .update(12, _original),
      _fails(ConcertEditFailureReason.forbidden),
    );
  });

  test('합류한 팀 수보다 적은 모집 팀 수는 저장하지 않는다', () async {
    final repository = FakeConcertEditRepository();
    await expectLater(
      repository.update(12, _original.copyWith(recruitTeamCount: 0)),
      throwsA(
        isA<ConcertEditFailure>().having((e) => e.issues, 'issues', {
          ConcertEditField.recruitTeamCount: ConcertEditIssue.belowJoinedTeams,
        }),
      ),
    );
    expect((await repository.fetchDetail(12)).version, _sample.version);
  });
}
