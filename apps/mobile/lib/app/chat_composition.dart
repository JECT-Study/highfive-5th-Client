import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/models/next_step.dart';
import '../features/auth/presentation/view_models/session_view_model.dart';
import '../features/auth/presentation/providers/session_providers.dart';
import '../features/chat/data/repositories/chat_demo_fixture.dart';
import '../features/chat/data/repositories/chat_repository.dart';
import '../features/chat/data/repositories/fake_chat_store.dart';
import '../features/chat/models/chat_room.dart';
import '../features/chat/presentation/providers/chat_providers.dart';
import '../shared/theme/app_spacing.dart';
import 'providers.dart';

/// 기능 간 화면 이동은 router composition에서 주입한다.
/// 공고 상세가 연결되기 전에는 null로 두며 가짜 경로를 만들지 않는다.
final chatPostNavigationProvider =
    Provider<void Function(BuildContext, InquiryTarget)?>((ref) => null);

/// 로그아웃 명령 시작부터 차단한다. 새 로그인 세션에서만 다시 활성화된다.
final chatSessionGateProvider = NotifierProvider<ChatSessionGate, bool>(
  ChatSessionGate.new,
);

class ChatSessionGate extends Notifier<bool> {
  @override
  bool build() {
    ref.watch(sessionProvider);
    final subscription = ref
        .watch(sessionExpiryProvider)
        .stream
        .listen((_) => close());
    ref.onDispose(subscription.cancel);
    return true;
  }

  void close() => state = false;
}

final chatFakeStoreProvider = Provider<FakeChatStore?>((ref) {
  final env = ref.watch(appEnvProvider);
  final session = ref.watch(sessionProvider);
  if (!env.isDev ||
      !env.chatFakeEnabled ||
      !ref.watch(chatSessionGateProvider) ||
      session.isLoading ||
      session.hasError ||
      session.value == null ||
      session.value!.nextStep == NextStep.terms) {
    return null;
  }
  final store = FakeChatStore(actors: ChatDemoFixture.actors);
  // ref의 재빌드/autoDispose를 기다리지 않고 이전 핸들을 즉시 폐기한다.
  ref.listen(sessionProvider, (_, _) => store.dispose());
  ref.listen(chatSessionGateProvider, (_, _) => store.dispose());
  ref.onDispose(store.dispose);
  return store;
});

final chatDemoActorProvider = NotifierProvider<ChatDemoActor, String>(
  ChatDemoActor.new,
);

class ChatDemoActor extends Notifier<String> {
  @override
  String build() {
    ref.watch(sessionProvider);
    return ChatDemoFixture.applicant.id;
  }

  void select(String actorId) => state = actorId;
}

final appChatRepositoryProvider = Provider<ChatRepository?>((ref) {
  final store = ref.watch(chatFakeStoreProvider);
  final actorId = ref.watch(chatDemoActorProvider);
  if (store == null) return null;
  final repository = store.bind(actorId);
  ref.listen(chatDemoActorProvider, (_, _) => repository.dispose());
  ref.onDispose(repository.dispose);
  return repository;
});

/// 인증은 기존 router redirect를 따른다. fake actor는 auth와 독립적이다.
class ChatComposition extends ConsumerWidget {
  const ChatComposition({super.key, required this.builder});
  final Widget Function(BuildContext, Widget?, InquiryTarget?) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(appChatRepositoryProvider);
    final controls = repository == null
        ? null
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
            child: Row(
              children: [
                const Expanded(child: Text('FAKE · 이 로그인 세션에서만 보관')),
                DropdownButton<String>(
                  key: const ValueKey('chat_demo_actor'),
                  value: repository.actor.id,
                  items: [
                    for (final actor in ChatDemoFixture.actors)
                      DropdownMenuItem(
                        value: actor.id,
                        child: Text(actor.name),
                      ),
                  ],
                  onChanged: (id) {
                    if (id != null) {
                      ref.read(chatDemoActorProvider.notifier).select(id);
                    }
                  },
                ),
              ],
            ),
          );
    return ProviderScope(
      overrides: [chatRepositoryProvider.overrideWithValue(repository)],
      child: Builder(
        builder: (context) => builder(
          context,
          controls,
          repository?.actor.id == ChatDemoFixture.applicant.id
              ? ChatDemoFixture.target
              : null,
        ),
      ),
    );
  }
}
