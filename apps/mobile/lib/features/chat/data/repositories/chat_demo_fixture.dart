import '../../models/chat_room.dart';

/// 명세 없음: 실제 계정/밴드/공고와 연결되지 않는 고정 fake 식별자.
abstract final class ChatDemoFixture {
  static const applicant = ChatActor(
    id: 'fake-applicant-leader',
    teamId: 'fake-applicant',
    name: '소음공장 대표',
    role: ChatRole.leader,
  );
  static const host = ChatActor(
    id: 'fake-host-leader',
    teamId: 'fake-host',
    name: '오프비트 대표',
    role: ChatRole.leader,
  );
  static const member = ChatActor(
    id: 'fake-applicant-member',
    teamId: 'fake-applicant',
    name: '소음공장 팀원',
    role: ChatRole.member,
  );
  static const actors = [applicant, host, member];
  static const target = InquiryTarget(
    postId: 'fake-post',
    title: 'Loud Sunday 합동공연 공고',
    details: ['11.07(토)', '서울 마포구', '장소 미정'],
    host: InquiryTeam(id: 'fake-host', name: '오프비트'),
    applicant: InquiryTeam(id: 'fake-applicant', name: '소음공장'),
  );
}
