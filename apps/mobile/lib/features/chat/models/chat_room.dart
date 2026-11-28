/// 채팅 API 명세 없음: 아래 식별자와 필드는 로컬 fake 계약이다.
/// 실제 서버 DTO나 인증 사용자의 역할로 사용하지 않는다.
enum ChatRoomKind { inquiry, performance }

enum ChatRole { leader, member }

enum ChatFailure {
  unavailable,
  sessionEnded,
  forbidden,
  roomMissing,
  emptyMessage,
}

class ChatException implements Exception {
  const ChatException(this.reason);
  final ChatFailure reason;
}

class ChatActor {
  const ChatActor({
    required this.id,
    required this.teamId,
    required this.name,
    required this.role,
  });
  final String id;
  final String teamId;
  final String name;
  final ChatRole role;
}

class InquiryTeam {
  const InquiryTeam({required this.id, required this.name});
  final String id;
  final String name;
}

class InquiryTarget {
  const InquiryTarget({
    required this.postId,
    required this.title,
    required this.details,
    required this.host,
    required this.applicant,
  });
  final String postId;
  final String title;
  final List<String> details;
  final InquiryTeam host;
  final InquiryTeam applicant;

  /// 같은 공고·주최팀·참여희망팀은 방향과 무관하게 같은 문의방이다.
  (String, String, String) get key => (postId, host.id, applicant.id);
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.teamId,
    required this.text,
    required this.sentAt,
  });
  final String id;
  final String authorId;
  final String authorName;
  final String teamId;
  final String text;
  final DateTime sentAt;
}

class ChatRoomAccess {
  const ChatRoomAccess({required this.canSend, required this.canDecide});
  final bool canSend;

  /// JECT-156: 참가 수락·거절은 주최팀 대표자만 가능하다.
  final bool canDecide;
}

class ChatRoom {
  ChatRoom({
    required this.id,
    required this.target,
    required this.kind,
    required List<ChatMessage> messages,
    required this.access,
  }) : messages = List.unmodifiable(messages);
  final String id;
  final InquiryTarget target;
  final ChatRoomKind kind;
  final List<ChatMessage> messages;
  final ChatRoomAccess access;
}
