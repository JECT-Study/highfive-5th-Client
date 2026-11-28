import '../../models/chat_room.dart';

/// 한 actor와 한 로그인 수명에 묶인 핸들. 인증 토큰에서 역할을 추론하지 않는다.
/// 서버 계약이 생기면 서버가 검증한 actor/권한을 제공하는 구현으로 교체한다.
abstract interface class ChatRepository {
  ChatActor get actor;
  Future<ChatRoom> openInquiry(InquiryTarget target);
  Stream<List<ChatRoom>> rooms();
  Stream<ChatRoom> watchRoom(String roomId);
  Future<void> send(String roomId, String text);

  /// 로그아웃·계정 전환 시 backing store와 함께 폐기한다.
  /// 보관된 이전 핸들의 읽기·쓰기·구독도 반드시 거부한다.
  void dispose();
}
