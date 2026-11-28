// 명세 없음: J162가 읽는 저장된 미리보기 일정. 서버 DTO가 아니다.
class TicketSchedule {
  const TicketSchedule({
    required this.registrationClosesAt,
    required this.performanceStartsAt,
    required this.performanceEndsAt,
    required this.refundClosesAt,
  });

  final DateTime registrationClosesAt;
  final DateTime performanceStartsAt;
  final DateTime performanceEndsAt;
  final DateTime refundClosesAt;
}

/// 같은 공연·행위자 범위의 저장된 일정만 제공한다.
abstract interface class TicketScheduleSource {
  TicketSchedule? readSchedule();
}
