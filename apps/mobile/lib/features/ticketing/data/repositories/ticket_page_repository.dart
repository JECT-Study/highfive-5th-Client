import 'dart:async';

import '../../models/ticket_application_page.dart';
import '../../models/ticket_role.dart';

/// 티켓 API 명세가 생기면 실제 저장소를 연결한다. 지금은 원격 호출이 없다.
abstract interface class TicketPageRepository {
  Future<TicketApplicationPage?> find(TicketPageScope scope);
  Future<TicketApplicationPage> create(TicketPageScope scope);
  Stream<TicketApplicationPage> watch(TicketPageScope scope);
}

/// 명세 없음: 앱이 열린 동안만 유효한 합성 공연의 생성 상태다.
/// 인증·영속 저장·관객 신청 페이지 발행을 수행하지 않는다.
class PreviewTicketPageRepository implements TicketPageRepository {
  final _pages = <String, TicketApplicationPage>{};
  final _changes = StreamController<TicketApplicationPage>.broadcast(
    sync: true,
  );

  Future<void> dispose() => _changes.close();

  void _authorize(TicketPageScope scope, {bool creating = false}) {
    if (scope.concertId != ticketPreviewConcertId ||
        ticketPreviewRoles[scope.actorId] != scope.role ||
        scope.role == TicketRole.outsider ||
        (creating && scope.role != ticketPageRequiredRole)) {
      throw const TicketPageFailure(TicketPageFailureReason.forbidden);
    }
  }

  @override
  Future<TicketApplicationPage?> find(TicketPageScope scope) async {
    _authorize(scope);
    return _pages[scope.concertId];
  }

  @override
  Future<TicketApplicationPage> create(TicketPageScope scope) async {
    _authorize(scope, creating: true);
    // await 전에 한 번만 기록한다. 다른 VM의 동시 명령도 같은 결과를 받는다.
    final existing = _pages[scope.concertId];
    if (existing != null) return existing;
    final page = TicketApplicationPage(concertId: scope.concertId);
    _pages[scope.concertId] = page;
    _changes.add(page);
    return page;
  }

  @override
  Stream<TicketApplicationPage> watch(TicketPageScope scope) {
    _authorize(scope);
    return _changes.stream.where((page) => page.concertId == scope.concertId);
  }
}
