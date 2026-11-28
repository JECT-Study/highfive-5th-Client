import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/chat_room.dart';
import '../providers/chat_providers.dart';

final chatCommandProvider =
    NotifierProvider.autoDispose<ChatCommandViewModel, AsyncValue<void>>(
      ChatCommandViewModel.new,
      dependencies: [chatRepositoryProvider],
    );

class ChatCommandViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    ref.watch(chatRepositoryProvider);
    return const AsyncData(null);
  }

  Future<T?> _run<T>(Future<T> Function() command) async {
    if (state.isLoading) return null;
    final repository = ref.read(chatRepositoryProvider);
    if (repository == null) {
      state = const AsyncError(
        ChatException(ChatFailure.unavailable),
        StackTrace.empty,
      );
      return null;
    }
    state = const AsyncLoading();
    try {
      final actorId = repository.actor.id;
      final result = await command();
      if (!ref.mounted ||
          !identical(repository, ref.read(chatRepositoryProvider))) {
        return null;
      }
      // 자식 scope 갱신 전에도 backing handle 폐기는 동기적으로 적용된다.
      if (repository.actor.id != actorId) return null;
      state = const AsyncData(null);
      return result;
    } catch (error, stack) {
      if (ref.mounted &&
          identical(repository, ref.read(chatRepositoryProvider))) {
        state = AsyncError(error, stack);
      }
      return null;
    }
  }

  Future<ChatRoom?> openInquiry(InquiryTarget target) =>
      _run(() => ref.read(chatRepositoryProvider)!.openInquiry(target));

  Future<bool> send(String roomId, String text) async =>
      await _run(() async {
        await ref.read(chatRepositoryProvider)!.send(roomId, text);
        return true;
      }) ??
      false;
}
