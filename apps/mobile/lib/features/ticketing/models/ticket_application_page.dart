/// 명세 없음: 생성 여부만 보관한다. URL·결제·관객 데이터는 만들지 않는다.
class TicketApplicationPage {
  const TicketApplicationPage({required this.concertId});

  // 명세 없음: 합성 공연 식별자이며 서버 DTO가 아니다.
  final String concertId;
}

enum TicketPageFailureReason { forbidden, unavailable, outcomeUnknown }

class TicketPageFailure implements Exception {
  const TicketPageFailure(this.reason);

  final TicketPageFailureReason reason;
}

class TicketPageState {
  const TicketPageState({this.page, this.creating = false, this.failure});

  final TicketApplicationPage? page;
  final bool creating;
  final TicketPageFailureReason? failure;

  bool get canCreate =>
      page == null &&
      !creating &&
      failure != TicketPageFailureReason.outcomeUnknown &&
      failure != TicketPageFailureReason.forbidden;
}
