import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/chat_repository.dart';
import '../../models/chat_room.dart';

/// app이 서버 검증 핸들 또는 명시적으로 활성화한 fake를 주입한다.
/// 기본은 fail closed이며 feature가 auth나 앱 설정을 읽지 않는다.
final chatRepositoryProvider = Provider<ChatRepository?>((ref) => null);

final chatRoomsProvider = StreamProvider.autoDispose<List<ChatRoom>>(
  (ref) {
    final repository = ref.watch(chatRepositoryProvider);
    if (repository == null) {
      throw const ChatException(ChatFailure.unavailable);
    }
    return repository.rooms();
  },
  dependencies: [chatRepositoryProvider],
  retry: (_, _) => null,
);

final chatRoomProvider = StreamProvider.autoDispose.family<ChatRoom, String>(
  (ref, id) {
    final repository = ref.watch(chatRepositoryProvider);
    if (repository == null) {
      throw const ChatException(ChatFailure.unavailable);
    }
    return repository.watchRoom(id);
  },
  dependencies: [chatRepositoryProvider],
  retry: (_, _) => null,
);
