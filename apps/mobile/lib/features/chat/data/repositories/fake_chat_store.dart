import 'dart:async';

import '../../models/chat_room.dart';
import 'chat_repository.dart';

/// 명세 없음: 네트워크·영속 저장 없이 한 로그인 동안만 쓰는 fake 저장소.
/// 두 팀의 독립 핸들이 같은 메시지 스트림을 관찰한다.
class FakeChatStore {
  FakeChatStore({required List<ChatActor> actors, DateTime Function()? clock})
    : _actors = {for (final actor in actors) actor.id: actor},
      _clock = clock ?? DateTime.now;

  final Map<String, ChatActor> _actors;
  final DateTime Function() _clock;
  final _targets = <String, InquiryTarget>{};
  final _roomIds = <(String, String, String), String>{};
  final _messages = <String, List<ChatMessage>>{};
  final _updates = StreamController<void>.broadcast(sync: true);
  final _handles = <_FakeChatRepository>{};
  bool _disposed = false;
  int _messageSequence = 0;

  ChatRepository bind(String actorId) {
    if (_disposed) throw const ChatException(ChatFailure.sessionEnded);
    if (!_actors.containsKey(actorId)) {
      throw const ChatException(ChatFailure.forbidden);
    }
    final handle = _FakeChatRepository(this, actorId);
    _handles.add(handle);
    return handle;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final handle in _handles.toList()) {
      handle.dispose();
    }
    _actors.clear();
    _targets.clear();
    _roomIds.clear();
    _messages.clear();
    unawaited(_updates.close());
  }
}

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository(this._store, this._actorId);
  final FakeChatStore _store;
  final String _actorId;
  final _subscriptions = <void Function()>{};
  bool _disposed = false;

  @override
  ChatActor get actor {
    if (_disposed || _store._disposed) {
      throw const ChatException(ChatFailure.sessionEnded);
    }
    return _store._actors[_actorId]!;
  }

  ChatRoom _room(String id) {
    final current = actor;
    final target = _store._targets[id];
    if (target == null) throw const ChatException(ChatFailure.roomMissing);
    if (current.teamId != target.host.id &&
        current.teamId != target.applicant.id) {
      throw const ChatException(ChatFailure.forbidden);
    }
    return ChatRoom(
      id: id,
      target: target,
      kind: ChatRoomKind.inquiry,
      messages: _store._messages[id]!,
      access: ChatRoomAccess(
        canSend: current.role == ChatRole.leader,
        canDecide:
            current.role == ChatRole.leader && current.teamId == target.host.id,
      ),
    );
  }

  @override
  Future<ChatRoom> openInquiry(InquiryTarget target) async {
    final current = actor;
    if (current.role != ChatRole.leader ||
        current.teamId != target.applicant.id ||
        target.host.id == target.applicant.id ||
        !_store._actors.values.any(
          (a) => a.teamId == target.host.id && a.role == ChatRole.leader,
        )) {
      throw const ChatException(ChatFailure.forbidden);
    }
    final existing = _store._roomIds[target.key];
    if (existing != null) return _room(existing);
    final id = 'fake-room-${_store._targets.length + 1}';
    _store._roomIds[target.key] = id;
    _store._targets[id] = InquiryTarget(
      postId: target.postId,
      title: target.title,
      details: List.unmodifiable(target.details),
      host: target.host,
      applicant: target.applicant,
    );
    _store._messages[id] = [];
    _store._updates.add(null);
    return _room(id);
  }

  Stream<T> _watch<T>(T Function() snapshot) => Stream<void>.multi((sink) {
    if (_disposed || _store._disposed) {
      sink.addError(const ChatException(ChatFailure.sessionEnded));
      sink.close();
      return;
    }
    // 대기열에는 데이터 대신 갱신 신호만 둔다. pause 뒤 resume 시에도
    // 아래 map에서 핸들 유효성을 다시 확인하여 이전 세션 데이터를 내보내지 않는다.
    final subscription = _store._updates.stream.listen((_) => sink.add(null));
    void invalidate() {
      sink.addError(const ChatException(ChatFailure.sessionEnded));
      sink.close();
      unawaited(subscription.cancel());
    }

    _subscriptions.add(invalidate);
    sink.onCancel = () {
      _subscriptions.remove(invalidate);
      return subscription.cancel();
    };
    sink.add(null);
  }).where((_) => !_disposed && !_store._disposed).map((_) => snapshot());

  @override
  Stream<List<ChatRoom>> rooms() => _watch(() {
    final current = actor;
    return List.unmodifiable([
      for (final entry in _store._targets.entries)
        if (entry.value.host.id == current.teamId ||
            entry.value.applicant.id == current.teamId)
          _room(entry.key),
    ]);
  });

  @override
  Stream<ChatRoom> watchRoom(String roomId) => _watch(() => _room(roomId));

  @override
  Future<void> send(String roomId, String text) async {
    final room = _room(roomId);
    if (!room.access.canSend) {
      throw const ChatException(ChatFailure.forbidden);
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw const ChatException(ChatFailure.emptyMessage);
    final current = actor;
    _store._messages[roomId]!.add(
      ChatMessage(
        id: 'fake-message-${++_store._messageSequence}',
        authorId: current.id,
        authorName: current.name,
        teamId: current.teamId,
        text: trimmed,
        sentAt: _store._clock(),
      ),
    );
    _store._updates.add(null);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final invalidate in _subscriptions.toList()) {
      invalidate();
    }
    _subscriptions.clear();
    _store._handles.remove(this);
  }
}
