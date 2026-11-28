import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/chat/data/repositories/chat_demo_fixture.dart';
import 'package:highfive/features/chat/data/repositories/chat_repository.dart';
import 'package:highfive/features/chat/data/repositories/fake_chat_store.dart';
import 'package:highfive/features/chat/models/chat_room.dart';
import 'package:highfive/features/chat/presentation/providers/chat_providers.dart';
import 'package:highfive/features/chat/presentation/view_models/chat_command_view_model.dart';

class _HeldRepository implements ChatRepository {
  _HeldRepository(this.delegate);
  final ChatRepository delegate;
  final gate = Completer<void>();
  @override
  ChatActor get actor => delegate.actor;
  @override
  Future<ChatRoom> openInquiry(InquiryTarget target) async {
    final room = await delegate.openInquiry(target);
    await gate.future;
    return room;
  }

  @override
  Future<void> send(String roomId, String text) async {
    await gate.future;
    return delegate.send(roomId, text);
  }

  @override
  Stream<List<ChatRoom>> rooms() => delegate.rooms();
  @override
  Stream<ChatRoom> watchRoom(String id) => delegate.watchRoom(id);
  @override
  void dispose() => delegate.dispose();
}

void main() {
  test('자식 scope 갱신 전에도 폐기한 actor의 완료 응답을 버린다', () async {
    final store = FakeChatStore(actors: ChatDemoFixture.actors);
    addTearDown(store.dispose);
    final held = _HeldRepository(store.bind(ChatDemoFixture.applicant.id));
    final container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(held)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(chatCommandProvider, (_, _) {});
    addTearDown(subscription.close);
    final pending = container
        .read(chatCommandProvider.notifier)
        .openInquiry(ChatDemoFixture.target);
    held.dispose();
    held.gate.complete();
    expect(await pending, isNull);
    expect(container.read(chatCommandProvider).hasError, isTrue);
  });
  test('기본 연결은 방 생성과 전송을 차단한다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(chatCommandProvider, (_, _) {});
    addTearDown(subscription.close);
    final vm = container.read(chatCommandProvider.notifier);
    expect(await vm.openInquiry(ChatDemoFixture.target), isNull);
    expect(await vm.send('unknown', 'text'), isFalse);
    expect(container.read(chatCommandProvider).hasError, isTrue);
  });

  test('대기 중인 중복 전송은 버리고 성공하면 대기 상태를 끝낸다', () async {
    final store = FakeChatStore(actors: ChatDemoFixture.actors);
    addTearDown(store.dispose);
    final delegate = store.bind(ChatDemoFixture.applicant.id);
    final room = await delegate.openInquiry(ChatDemoFixture.target);
    final held = _HeldRepository(delegate);
    final container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(held)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(chatCommandProvider, (_, _) {});
    addTearDown(subscription.close);
    final vm = container.read(chatCommandProvider.notifier);
    final first = vm.send(room.id, 'first');
    expect(container.read(chatCommandProvider).isLoading, isTrue);
    expect(await vm.send(room.id, 'duplicate'), isFalse);
    held.gate.complete();
    expect(await first, isTrue);
    expect(container.read(chatCommandProvider).isLoading, isFalse);
    expect(
      (await delegate.watchRoom(room.id).first).messages.map((m) => m.text),
      ['first'],
    );
  });

  test('실패 후 재시도는 다시 실행되어 성공한다', () async {
    final store = FakeChatStore(actors: ChatDemoFixture.actors);
    addTearDown(store.dispose);
    final repository = store.bind(ChatDemoFixture.applicant.id);
    final room = await repository.openInquiry(ChatDemoFixture.target);
    final container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(chatCommandProvider, (_, _) {});
    addTearDown(subscription.close);
    final vm = container.read(chatCommandProvider.notifier);
    expect(await vm.send(room.id, '  '), isFalse);
    expect(container.read(chatCommandProvider).hasError, isTrue);
    expect(await vm.send(room.id, 'retry'), isTrue);
    expect(container.read(chatCommandProvider).hasError, isFalse);
    expect(
      (await repository.watchRoom(room.id).first).messages.single.text,
      'retry',
    );
  });

  test('계정 전환 뒤 도착한 방 생성 응답을 새 화면으로 전달하지 않는다', () async {
    final oldStore = FakeChatStore(actors: ChatDemoFixture.actors);
    final nextStore = FakeChatStore(actors: ChatDemoFixture.actors);
    addTearDown(oldStore.dispose);
    addTearDown(nextStore.dispose);
    final held = _HeldRepository(oldStore.bind(ChatDemoFixture.applicant.id));
    final container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(held)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(chatCommandProvider, (_, _) {});
    addTearDown(subscription.close);
    final pending = container
        .read(chatCommandProvider.notifier)
        .openInquiry(ChatDemoFixture.target);
    container.updateOverrides([
      chatRepositoryProvider.overrideWithValue(
        nextStore.bind(ChatDemoFixture.applicant.id),
      ),
    ]);
    await container.pump();
    held.gate.complete();
    expect(await pending, isNull);
    expect(container.read(chatCommandProvider).hasError, isFalse);
    expect(
      await container.read(chatRepositoryProvider)!.rooms().first,
      isEmpty,
    );
  });
}
