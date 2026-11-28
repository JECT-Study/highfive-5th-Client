/// 명세 없음: 티켓 API가 없어 dev 미리보기에서만 사용하는 역할이다.
enum TicketRole { organizer, accountOwner, member, outsider }

const ticketPreviewConcertId = 'demo-concert';
const ticketPreviewActorId = 'demo-host';
const ticketPageRequiredRole = TicketRole.organizer;

/// 명세 없음: 인증 계정과 연결하지 않는 고정 합성 사용자다.
const ticketPreviewRoles = {
  'demo-host': TicketRole.organizer,
  'demo-member-a': TicketRole.member,
  'demo-member-b': TicketRole.member,
  'demo-guest': TicketRole.outsider,
};

/// 명세 없음: 공연과 사용자 변경 시 미리보기 상태를 분리하는 로컬 키다.
typedef TicketPageScope = ({String concertId, String actorId, TicketRole role});
