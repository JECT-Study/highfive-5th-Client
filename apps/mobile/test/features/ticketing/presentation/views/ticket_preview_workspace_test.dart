import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/ticketing/models/ticket_application_page.dart';
import 'package:highfive/features/ticketing/models/ticket_role.dart';
import 'package:highfive/features/ticketing/models/ticket_schedule.dart';
import 'package:highfive/features/ticketing/models/ticket_settings.dart';
import 'package:highfive/features/ticketing/presentation/providers/ticket_settings_providers.dart';
import 'package:highfive/features/ticketing/presentation/widgets/ticket_description_section.dart';
import 'package:highfive/features/ticketing/presentation/views/ticket_page_view.dart';
import 'package:highfive/features/ticketing/presentation/views/ticket_preview_workspace.dart';
import 'package:highfive/features/ticketing/presentation/widgets/ticket_settings_fields.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';

import '../../settings_fixture.dart';

Widget _app({
  TicketRole role = TicketRole.organizer,
  String actorId = 'demo-host',
}) => ProviderScope(
  overrides: [ticketSettingsClockProvider.overrideWithValue(() => settingsNow)],
  child: MaterialApp(
    theme: AppTheme.light,
    home: TicketPreviewWorkspace(role: role, actorId: actorId),
  ),
);

Future<void> _tap(WidgetTester tester, String name) async {
  final finder = find.byKey(ValueKey('ticketSettings_$name'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('생성 버튼에서 폼을 열고 취소하면 페이지를 만들지 않는다', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(TicketPageView.createKey));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ticketSettings_price')), findsOneWidget);
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();

    expect(find.byKey(TicketPageView.createdKey), findsNothing);
    expect(find.byKey(TicketPageView.createKey), findsOneWidget);
  });

  testWidgets('폼 팝과 dev 경로 재진입 후에도 같은 페이지와 저장 일정을 복원한다', (tester) async {
    final container = ProviderContainer(
      overrides: [
        ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
      ],
    );
    addTearDown(container.dispose);
    TicketScheduleSource? source;
    final pages = <TicketApplicationPage>[];
    Widget app() => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: TicketPreviewWorkspace(
          role: TicketRole.organizer,
          createdBuilder: (context, page, schedule) {
            source = schedule;
            pages.add(page);
            return const SizedBox(key: ValueKey('scheduleConsumer'));
          },
        ),
      ),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TicketPageView.createKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('ticketSettings_price')),
      '15000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('ticketSettings_capacity')),
      '120',
    );
    await _tap(tester, 'account');
    await _tap(tester, 'chooseDemo');
    await _tap(tester, 'contact');
    await _tap(tester, 'chooseDemo');
    final policy = find.byKey(const ValueKey('ticketSettings_refundPolicy'));
    await tester.ensureVisible(policy);
    await tester.enterText(policy, '데모 환불 규정');

    await _tap(tester, 'save');
    expect(find.byType(TicketDescriptionSection), findsOneWidget);
    final description = tester.widget<TicketDescriptionSection>(
      find.byType(TicketDescriptionSection),
    );
    expect(description.model.repository.read(), isNull);
    await tester.enterText(
      find.byKey(const ValueKey('ticketDescription_introduction')),
      '데모 합동공연 소개',
    );
    await tester.enterText(
      find.byKey(const ValueKey('ticketDescription_precautions')),
      '데모 공연 시작 전 입장',
    );
    await tester.pumpAndSettle();
    final finalSave = find.byKey(const ValueKey('ticketDescription_save'));
    await tester.ensureVisible(finalSave);
    await tester.pumpAndSettle();
    await tester.tap(finalSave);
    await tester.pumpAndSettle();
    expect(
      description.model.repository.read()?.draft.introduction,
      '데모 합동공연 소개',
    );
    expect(
      description.model.repository.read()?.draft.precautions,
      '데모 공연 시작 전 입장',
    );

    expect(find.byKey(const ValueKey('ticketSettings_price')), findsNothing);
    expect(find.byKey(const ValueKey('scheduleConsumer')), findsOneWidget);
    expect(
      source?.readSchedule()?.performanceStartsAt,
      DateTime(2027, 1, 12, 19),
    );
    final oldSource = source;
    final page = pages.last;
    await tester.pumpWidget(const SizedBox());
    expect(oldSource?.readSchedule, throwsA(isA<Exception>()));

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.byKey(TicketPageView.createKey), findsNothing);
    expect(pages.last, same(page));
    expect(
      source?.readSchedule()?.performanceStartsAt,
      DateTime(2027, 1, 12, 19),
    );
    expect(source, isNot(same(oldSource)));
  });

  testWidgets('설정 화면 중 역할이 바뀌면 이전 폼 경로도 폐기한다', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TicketPageView.createKey));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _app(role: TicketRole.member, actorId: 'demo-member-a'),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('ticketSettings_price')), findsNothing);
    expect(find.byKey(TicketPageView.deniedKey), findsOneWidget);
  });

  testWidgets('가변 actorScope 변경은 열린 폼을 폐기하고 주최자 복귀 시 새 초안을 연다', (tester) async {
    final actor = ValueNotifier<TicketPageScope>((
      concertId: ticketPreviewConcertId,
      actorId: ticketPreviewActorId,
      role: TicketRole.organizer,
    ));
    addTearDown(actor.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: TicketPreviewWorkspace(actorScope: actor),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TicketPageView.createKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('ticketSettings_price')),
      '19000',
    );

    actor.value = (
      concertId: ticketPreviewConcertId,
      actorId: 'demo-member-a',
      role: TicketRole.member,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ticketSettings_price')), findsNothing);
    expect(find.byKey(TicketPageView.deniedKey), findsOneWidget);

    actor.value = (
      concertId: ticketPreviewConcertId,
      actorId: ticketPreviewActorId,
      role: TicketRole.organizer,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TicketPageView.createKey));
    await tester.pumpAndSettle();
    final input = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('ticketSettings_price')),
        matching: find.byType(TextField),
      ),
    );
    expect(input.controller?.text, isEmpty);
  });

  testWidgets('actor 변경 직후 repaint 전 이전 폼의 저장과 읽기를 즉시 거부한다', (tester) async {
    final actor = ValueNotifier<TicketPageScope>((
      concertId: ticketPreviewConcertId,
      actorId: ticketPreviewActorId,
      role: TicketRole.organizer,
    ));
    addTearDown(actor.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: TicketPreviewWorkspace(actorScope: actor),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TicketPageView.createKey));
    await tester.pumpAndSettle();
    final model = tester
        .widget<TicketSettingsFields>(find.byType(TicketSettingsFields))
        .model;
    model.update(validTicketSettings());
    await tester.pump();
    final submit = tester
        .widget<AppButton>(find.byKey(const ValueKey('ticketSettings_save')))
        .onPressed;
    actor.value = (
      concertId: ticketPreviewConcertId,
      actorId: 'demo-member-a',
      role: TicketRole.member,
    );

    // pump 전에 실행: build/dispose 기반 방어만 있으면 여기서 저장된다.
    submit?.call();

    expect(model.repository.canEdit, isFalse);
    expect(model.saved, isFalse);
    expect(
      model.repository.readSchedule,
      throwsA(
        isA<TicketSettingsFailure>().having((e) => e.denied, 'denied', true),
      ),
    );
    actor.value = (
      concertId: ticketPreviewConcertId,
      actorId: ticketPreviewActorId,
      role: TicketRole.organizer,
    );
    expect(
      model.repository.readSchedule,
      throwsA(isA<TicketSettingsFailure>()),
    );
    await tester.pumpAndSettle();
  });
}
