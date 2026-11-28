import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/ticketing/data/repositories/ticket_page_repository.dart';
import 'package:highfive/features/ticketing/models/ticket_application_page.dart';
import 'package:highfive/features/ticketing/models/ticket_role.dart';
import 'package:highfive/features/ticketing/presentation/providers/ticket_page_providers.dart';
import 'package:highfive/features/ticketing/presentation/view_models/ticket_page_view_model.dart';

const _scope = (
  concertId: ticketPreviewConcertId,
  actorId: ticketPreviewActorId,
  role: TicketRole.organizer,
);
final _provider = ticketPageViewModelProvider(_scope);

class _HeldRepository implements TicketPageRepository {
  final creation = Completer<TicketApplicationPage>();
  TicketApplicationPage? page;
  int writes = 0;
  bool failRead = false;

  @override
  Stream<TicketApplicationPage> watch(TicketPageScope scope) =>
      const Stream.empty();

  @override
  Future<TicketApplicationPage?> find(TicketPageScope scope) async {
    if (failRead) {
      throw const TicketPageFailure(TicketPageFailureReason.unavailable);
    }
    return page;
  }

  @override
  Future<TicketApplicationPage> create(TicketPageScope scope) {
    writes++;
    return creation.future;
  }
}

class _DelayedReplyRepository extends PreviewTicketPageRepository {
  final reply = Completer<void>();
  int writes = 0;

  @override
  Future<TicketApplicationPage> create(TicketPageScope scope) async {
    writes++;
    final page = await super.create(scope);
    await reply.future;
    return page;
  }
}

ProviderContainer _container(TicketPageRepository repository) {
  final container = ProviderContainer(
    overrides: [ticketPageRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  container.listen(_provider, (_, _) {});
  return container;
}

void main() {
  test('비어 있는 상태를 읽고 생성 성공 뒤 다시 보내지 않는다', () async {
    final container = _container(PreviewTicketPageRepository());
    expect((await container.read(_provider.future)).page, isNull);
    final vm = container.read(_provider.notifier);
    await vm.create();
    final page = container.read(_provider).requireValue.page;
    expect(page?.concertId, ticketPreviewConcertId);
    await vm.create();
    expect(container.read(_provider).requireValue.page, same(page));
  });

  test('보류 중 중복 명령은 무시하고 완료 후 로딩을 끝낸다', () async {
    final repository = _HeldRepository();
    final container = _container(repository);
    await container.read(_provider.future);
    final vm = container.read(_provider.notifier);
    final pending = vm.create();
    expect(container.read(_provider).requireValue.creating, isTrue);
    await vm.create();
    expect(repository.writes, 1);
    repository.creation.complete(
      const TicketApplicationPage(concertId: ticketPreviewConcertId),
    );
    await pending;
    expect(container.read(_provider).requireValue.creating, isFalse);
    expect(container.read(_provider).requireValue.page, isNotNull);
  });

  test('확정 실패는 오류로 표시하고 다음 명령은 다시 허용한다', () async {
    final repository = _HeldRepository();
    final container = _container(repository);
    await container.read(_provider.future);
    repository.creation.completeError(
      const TicketPageFailure(TicketPageFailureReason.unavailable),
    );
    await container.read(_provider.notifier).create();
    expect(
      container.read(_provider).requireValue.failure,
      TicketPageFailureReason.unavailable,
    );
    expect(container.read(_provider).requireValue.canCreate, isTrue);
  });

  testWidgets('응답 기한 뒤 결과가 없으면 재생성하지 않고 결과만 확인한다', (tester) async {
    final repository = _HeldRepository();
    final container = _container(repository);
    await tester.runAsync(() => container.read(_provider.future));
    final vm = container.read(_provider.notifier);
    final pending = vm.create();
    await tester.pump(TicketPageViewModel.requestTimeout);
    await pending;
    expect(
      container.read(_provider).requireValue.failure,
      TicketPageFailureReason.outcomeUnknown,
    );
    vm.retryLoad();
    await vm.create();
    expect(repository.writes, 1);
    repository.page = const TicketApplicationPage(
      concertId: ticketPreviewConcertId,
    );
    await vm.checkOutcome();
    expect(container.read(_provider).requireValue.page, same(repository.page));
    repository.creation.complete(repository.page);
  });

  test('조회 실패를 생성 전 빈 상태로 표시하지 않는다', () async {
    final repository = _HeldRepository()..failRead = true;
    final container = _container(repository);
    await expectLater(
      container.read(_provider.future),
      throwsA(isA<TicketPageFailure>()),
    );
    await container.read(_provider.notifier).create();
    expect(container.read(_provider).hasError, isTrue);
    expect(repository.writes, 0);
  });

  test('공연과 사용자를 바꾼 Provider에 이전 생성 응답이 나타나지 않는다', () async {
    final repository = _HeldRepository();
    final container = _container(repository);
    await container.read(_provider.future);
    final pending = container.read(_provider.notifier).create();
    final other = ticketPageViewModelProvider((
      concertId: 'other-concert',
      actorId: 'demo-member-b',
      role: TicketRole.member,
    ));
    container.listen(other, (_, _) {});
    await container.read(other.future);
    repository.creation.complete(
      const TicketApplicationPage(concertId: ticketPreviewConcertId),
    );
    await pending;
    expect(container.read(other).requireValue.page, isNull);
  });

  test('Provider가 폐기된 뒤의 응답은 폐기된 상태를 갱신하지 않는다', () async {
    final repository = _HeldRepository();
    final container = ProviderContainer(
      overrides: [ticketPageRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(_provider, (_, _) {});
    await container.read(_provider.future);
    final pending = container.read(_provider.notifier).create();
    container.dispose();
    repository.creation.complete(
      const TicketApplicationPage(concertId: ticketPreviewConcertId),
    );
    await expectLater(pending, completes);
  });

  test('화면 재진입도 앱 메모리의 기존 생성 결과를 읽는다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(_provider, (_, _) {});
    await container.read(_provider.future);
    await container.read(_provider.notifier).create();
    final page = container.read(_provider).requireValue.page;
    subscription.close();
    await container.pump();
    container.listen(_provider, (_, _) {});
    expect((await container.read(_provider.future)).page, same(page));
  });

  test('멤버의 열린 화면은 같은 공연의 생성 결과를 즉시 받는다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final member = ticketPageViewModelProvider((
      concertId: ticketPreviewConcertId,
      actorId: 'demo-member-a',
      role: TicketRole.member,
    ));
    container.listen(_provider, (_, _) {});
    container.listen(member, (_, _) {});
    await container.read(_provider.future);
    expect((await container.read(member.future)).page, isNull);
    await container.read(_provider.notifier).create();
    expect(
      container.read(member).requireValue.page,
      same(container.read(_provider).requireValue.page),
    );
    expect(container.read(member).requireValue.page, isNotNull);
  });

  testWidgets('변경 알림은 보류 중 생성 명령을 다시 시작하지 않는다', (tester) async {
    final repository = _DelayedReplyRepository();
    addTearDown(repository.dispose);
    final container = _container(repository);
    await tester.runAsync(() => container.read(_provider.future));
    final vm = container.read(_provider.notifier);
    final pending = vm.create();
    await tester.pump();
    final page = container.read(_provider).requireValue.page;
    expect(page, isNotNull);
    await vm.create();
    await tester.pump(TicketPageViewModel.requestTimeout);
    await pending;
    expect(repository.writes, 1);
    expect(container.read(_provider).requireValue.page, same(page));
    expect(container.read(_provider).requireValue.failure, isNull);
    repository.reply.complete();
  });

  testWidgets('미확정 요청은 화면 재진입 뒤에도 다시 보내지 않는다', (tester) async {
    final repository = _HeldRepository();
    final container = ProviderContainer(
      overrides: [ticketPageRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(_provider, (_, _) {});
    await tester.runAsync(() => container.read(_provider.future));
    final pending = container.read(_provider.notifier).create();
    await tester.pump(TicketPageViewModel.requestTimeout);
    await pending;
    subscription.close();
    await tester.pump();
    container.listen(_provider, (_, _) {});
    await container.read(_provider.notifier).create();
    expect(
      container.read(_provider).requireValue.failure,
      TicketPageFailureReason.outcomeUnknown,
    );
    expect(repository.writes, 1);
    repository.creation.complete(
      const TicketApplicationPage(concertId: ticketPreviewConcertId),
    );
  });
}
