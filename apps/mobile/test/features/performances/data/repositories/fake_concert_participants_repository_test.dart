import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';

void main() {
  test('기본 fake는 공연 12에 주최 밴드와 합류한 한 팀을 공연 순서대로 준다', () async {
    final participants = await FakeConcertParticipantsRepository()
        .fetchParticipants(12);

    expect(participants.map((p) => p.isHost), [true, false]);
    expect(
      participants.where((p) => !p.isHost),
      hasLength(FakeConcertRepository.sample.recruitment!.joinedTeamCount),
    );
  });

  test('주최 밴드는 공연 상세 fake의 주최 밴드이자 내 밴드다', () async {
    final participants = await FakeConcertParticipantsRepository()
        .fetchParticipants(12);
    final host = participants.singleWhere((p) => p.isHost);

    expect(host.bandId, FakeConcertRepository.sample.hostBandId);
    expect(FakeConcertRepository.sample.myBandIds, contains(host.bandId));
  });

  test('없는 공연은 예시 공연으로 바꾸지 않고 404를 돌려준다', () async {
    await expectLater(
      FakeConcertParticipantsRepository().fetchParticipants(99),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.code, 'code', 'CONCERT_001'),
      ),
    );
  });

  test('접근 금지 공연은 명세의 참여 권한 오류를 돌려준다', () async {
    await expectLater(
      FakeConcertParticipantsRepository(forbiddenConcertIds: {12})
          .fetchParticipants(12),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.code, 'code', 'AUTH_005'),
      ),
    );
  });

  test('입력 컬렉션을 바꿔도 저장소의 참여 밴드와 접근 권한은 그대로다', () async {
    final teams = [...FakeConcertParticipantsRepository.sample];
    final participants = {27: teams};
    final forbidden = <int>{};
    final repository = FakeConcertParticipantsRepository(
      participants: participants,
      forbiddenConcertIds: forbidden,
    );
    teams.add(const ConcertParticipant(bandId: 1, name: '추가', isHost: false));
    participants[28] = teams;
    forbidden.add(27);

    final result = await repository.fetchParticipants(27);

    expect(result, FakeConcertParticipantsRepository.sample);
    await expectLater(
      repository.fetchParticipants(28),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'CONCERT_001')),
    );
  });
}
