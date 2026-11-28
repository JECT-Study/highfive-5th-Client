import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/chat/data/repositories/chat_demo_fixture.dart';
import 'package:highfive/features/chat/data/repositories/fake_chat_store.dart';
import 'package:highfive/features/chat/models/chat_room.dart';

void main() {
  late FakeChatStore store;
  setUp(
    () => store = FakeChatStore(
      actors: [
        ...ChatDemoFixture.actors,
        const ChatActor(
          id: 'outsider',
          teamId: 'other',
          name: '다른 팀 대표',
          role: ChatRole.leader,
        ),
      ],
      clock: () => DateTime.utc(2026, 11, 28, 12),
    ),
  );
  tearDown(() => store.dispose());

  test('일시정지한 구독도 폐기 후 이전 메시지 snapshot을 전달하지 않는다', () async {
    final applicant = store.bind(ChatDemoFixture.applicant.id);
    final room = await applicant.openInquiry(ChatDemoFixture.target);
    final data = <ChatRoom>[];
    final errors = <ChatFailure>[];
    final done = Completer<void>();
    final subscription = applicant
        .watchRoom(room.id)
        .listen(
          data.add,
          onError: (Object error) =>
              errors.add((error as ChatException).reason),
          onDone: done.complete,
        );
    subscription.pause();
    await applicant.send(room.id, '이전 세션 데이터');
    store.dispose();
    subscription.resume();
    await done.future;
    expect(data, isEmpty);
    expect(errors, [ChatFailure.sessionEnded]);
  });

  test('같은 공고와 두 팀의 동시 문의는 하나의 방으로 재진입한다', () async {
    final applicant = store.bind(ChatDemoFixture.applicant.id);
    final rooms = await Future.wait([
      applicant.openInquiry(ChatDemoFixture.target),
      applicant.openInquiry(ChatDemoFixture.target),
    ]);
    expect(rooms[0].id, rooms[1].id);
    expect((await applicant.rooms().first).map((room) => room.id), [
      rooms[0].id,
    ]);
  });

  test('서로 다른 공고는 같은 팀이어도 독립된 방을 만든다', () async {
    final applicant = store.bind(ChatDemoFixture.applicant.id);
    final original = ChatDemoFixture.target;
    final first = await applicant.openInquiry(original);
    final second = await applicant.openInquiry(
      InquiryTarget(
        postId: 'another-post',
        title: original.title,
        details: original.details,
        host: original.host,
        applicant: original.applicant,
      ),
    );
    expect(first.id, isNot(second.id));
  });

  test('양 팀 대표자가 보낸 메시지가 상대 스트림에 작성자와 함께 도착한다', () async {
    final applicant = store.bind(ChatDemoFixture.applicant.id);
    final host = store.bind(ChatDemoFixture.host.id);
    final room = await applicant.openInquiry(ChatDemoFixture.target);
    final receivedByHost = host
        .watchRoom(room.id)
        .firstWhere((room) => room.messages.length == 1);
    await applicant.send(room.id, '  공연 순서가 궁금해요  ');
    final first = (await receivedByHost).messages.single;
    expect(
      (first.authorId, first.teamId, first.text, first.sentAt),
      (
        'fake-applicant-leader',
        'fake-applicant',
        '공연 순서가 궁금해요',
        DateTime.utc(2026, 11, 28, 12),
      ),
    );
    final receivedByApplicant = applicant
        .watchRoom(room.id)
        .firstWhere((room) => room.messages.length == 2);
    await host.send(room.id, '아직 미정이에요');
    final messages = (await receivedByApplicant).messages;
    expect(messages.map((m) => m.authorId), [
      'fake-applicant-leader',
      'fake-host-leader',
    ]);
    expect(messages[0].id, isNot(messages[1].id));
    expect(room.messages, isEmpty); // 이전 snapshot은 변경되지 않는다.
  });

  test('팀원은 내역을 읽지만 작성과 방 생성을 거부한다', () async {
    final applicant = store.bind(ChatDemoFixture.applicant.id);
    final member = store.bind(ChatDemoFixture.member.id);
    final room = await applicant.openInquiry(ChatDemoFixture.target);
    await applicant.send(room.id, '내역');
    expect((await member.watchRoom(room.id).first).messages.single.text, '내역');
    await expectLater(
      member.send(room.id, '위조'),
      throwsA(isA<ChatException>()),
    );
    await expectLater(
      member.openInquiry(ChatDemoFixture.target),
      throwsA(isA<ChatException>()),
    );
  });

  test('주최 대표자만 참가 결정 권한을 받는다', () async {
    final applicant = store.bind(ChatDemoFixture.applicant.id);
    final host = store.bind(ChatDemoFixture.host.id);
    final room = await applicant.openInquiry(ChatDemoFixture.target);
    expect(room.access.canDecide, isFalse);
    expect((await host.watchRoom(room.id).first).access.canDecide, isTrue);
  });

  test('제삼자는 방 식별자를 알아도 읽거나 쓸 수 없다', () async {
    final applicant = store.bind(ChatDemoFixture.applicant.id);
    final outsider = store.bind('outsider');
    final room = await applicant.openInquiry(ChatDemoFixture.target);
    expect(await outsider.rooms().first, isEmpty);
    await expectLater(
      outsider.watchRoom(room.id).first,
      throwsA(isA<ChatException>()),
    );
    await expectLater(
      outsider.send(room.id, '위조'),
      throwsA(isA<ChatException>()),
    );
  });

  test('빈 메시지를 저장하지 않는다', () async {
    final applicant = store.bind(ChatDemoFixture.applicant.id);
    final room = await applicant.openInquiry(ChatDemoFixture.target);
    await expectLater(
      applicant.send(room.id, ' \n '),
      throwsA(isA<ChatException>()),
    );
    expect((await applicant.watchRoom(room.id).first).messages, isEmpty);
  });

  test('폐기한 핸들의 구독은 종료되고 보관된 핸들도 재사용할 수 없다', () async {
    final applicant = store.bind(ChatDemoFixture.applicant.id);
    final room = await applicant.openInquiry(ChatDemoFixture.target);
    final states = applicant.watchRoom(room.id);
    final complete = expectLater(
      states,
      emitsInOrder([
        isA<ChatRoom>(),
        emitsError(isA<ChatException>()),
        emitsDone,
      ]),
    );
    // 첫 이벤트를 기다린 별도 구독으로 스트림 설치를 확인한다.
    await applicant.watchRoom(room.id).first;
    store.dispose();
    await complete;
    await expectLater(
      applicant.send(room.id, '늦은 전송'),
      throwsA(isA<ChatException>()),
    );
    await expectLater(
      applicant.openInquiry(ChatDemoFixture.target),
      throwsA(isA<ChatException>()),
    );
    expect(
      () => store.bind(ChatDemoFixture.applicant.id),
      throwsA(isA<ChatException>()),
    );
  });
}
