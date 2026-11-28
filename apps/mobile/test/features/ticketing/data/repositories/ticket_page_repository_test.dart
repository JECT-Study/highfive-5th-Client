import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/ticketing/data/repositories/ticket_page_repository.dart';
import 'package:highfive/features/ticketing/models/ticket_application_page.dart';
import 'package:highfive/features/ticketing/models/ticket_role.dart';

const _host = (
  concertId: ticketPreviewConcertId,
  actorId: ticketPreviewActorId,
  role: TicketRole.organizer,
);

void main() {
  test('동시 생성과 이후 재생성도 공연 하나의 페이지를 반환한다', () async {
    final repository = PreviewTicketPageRepository();
    expect(await repository.find(_host), isNull);
    final pages = await Future.wait([
      repository.create(_host),
      repository.create(_host),
    ]);
    expect(identical(pages.first, pages.last), isTrue);
    expect(await repository.create(_host), same(pages.first));
    expect(await repository.find(_host), same(pages.first));
  });

  for (final entry in ticketPreviewRoles.entries) {
    if (entry.value == TicketRole.organizer) continue;
    test('${entry.value.name}는 저장소 생성 경계에서 거절된다', () async {
      final repository = PreviewTicketPageRepository();
      final scope = (
        concertId: ticketPreviewConcertId,
        actorId: entry.key,
        role: entry.value,
      );
      await expectLater(
        repository.create(scope),
        throwsA(isA<TicketPageFailure>()),
      );
      expect(await repository.find(_host), isNull);
    });
  }

  test('다른 공연과 위조한 합성 사용자 역할은 조회도 거절된다', () async {
    final repository = PreviewTicketPageRepository();
    await repository.create(_host);
    for (final scope in [
      (concertId: 'other-concert', actorId: _host.actorId, role: _host.role),
      (
        concertId: _host.concertId,
        actorId: 'demo-member-b',
        role: TicketRole.organizer,
      ),
      (
        concertId: _host.concertId,
        actorId: 'demo-guest',
        role: TicketRole.outsider,
      ),
    ]) {
      await expectLater(
        repository.find(scope),
        throwsA(isA<TicketPageFailure>()),
      );
    }
  });

  test('새 미리보기 저장소는 이전 실행의 생성 상태를 보관하지 않는다', () async {
    await PreviewTicketPageRepository().create(_host);
    expect(await PreviewTicketPageRepository().find(_host), isNull);
  });

  test('변경 알림에서 재진입해도 저장된 하나의 결과만 받는다', () async {
    final repository = PreviewTicketPageRepository();
    addTearDown(repository.dispose);
    Future<TicketApplicationPage>? repeated;
    var events = 0;
    final subscription = repository.watch(_host).listen((page) {
      events++;
      if (events == 1) repeated = repository.create(_host);
    });
    addTearDown(subscription.cancel);
    final page = await repository.create(_host);
    expect(await repeated, same(page));
    expect(events, 1);
  });
}
