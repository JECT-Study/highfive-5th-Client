import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/ticketing/data/repositories/ticket_page_repository.dart';
import 'package:highfive/features/ticketing/models/ticket_application_page.dart';
import 'package:highfive/features/ticketing/models/ticket_role.dart';
import 'package:highfive/features/ticketing/models/ticket_settings.dart';
import 'package:highfive/features/ticketing/presentation/providers/ticket_settings_providers.dart';
import 'package:highfive/features/ticketing/presentation/providers/ticket_page_providers.dart';
import 'package:highfive/features/ticketing/presentation/view_models/ticket_settings_view_model.dart';
import 'package:highfive/features/ticketing/presentation/views/ticket_page_view.dart';
import 'package:highfive/features/ticketing/presentation/views/ticket_preview_workspace.dart';
import 'package:highfive/features/ticketing/presentation/widgets/ticket_description_section.dart';
import 'package:highfive/features/ticketing/presentation/widgets/ticket_settings_fields.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';

import '../../settings_fixture.dart';

const _host = (
  concertId: ticketPreviewConcertId,
  actorId: ticketPreviewActorId,
  role: TicketRole.organizer,
);
const _member = (
  concertId: ticketPreviewConcertId,
  actorId: 'demo-member-a',
  role: TicketRole.member,
);

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.pumpAndSettle();
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<TicketSettingsViewModel> _description(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(TicketPageView.createKey));
  await tester.pumpAndSettle();
  final model = tester
      .widget<TicketSettingsFields>(find.byType(TicketSettingsFields))
      .model;
  model.update(validTicketSettings());
  await tester.pump();
  await _tap(tester, 'ticketSettings_save');
  expect(find.byType(TicketDescriptionSection), findsOneWidget);
  expect(model.repository.read(), isNull);
  return model;
}

void main() {
  testWidgets('R2 잘못된 소개로 뒤로 가도 다시 소개를 열어 수정하고 저장한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TicketPreviewWorkspace(role: TicketRole.organizer),
        ),
      ),
    );
    final model = await _description(tester);
    await tester.enterText(
      find.byKey(const ValueKey('ticketDescription_introduction')),
      '000.0000.0000',
    );
    await _tap(tester, 'ticketDescription_save');
    expect(model.repository.read(), isNull);
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();
    await _tap(tester, 'ticketSettings_save');
    expect(find.byType(TicketDescriptionSection), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('ticketDescription_introduction')),
      '데모 소개',
    );
    await _tap(tester, 'ticketDescription_save');
    expect(model.repository.read()?.draft.introduction, '데모 소개');
  });

  for (final time in [false, true]) {
    testWidgets('R2 ${time ? '시간' : '날짜'} 선택창 시스템 뒤로가기는 null 취소한다', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const TicketPreviewWorkspace(role: TicketRole.organizer),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TicketPageView.createKey));
      await tester.pumpAndSettle();
      final model = tester
          .widget<TicketSettingsFields>(find.byType(TicketSettingsFields))
          .model;
      final before = model.draft;
      await _tap(tester, 'ticketSettings_performanceStartsAt');
      if (time) {
        final label = MaterialLocalizations.of(
          tester.element(find.byType(DatePickerDialog)),
        ).okButtonLabel;
        await tester.tap(find.widgetWithText(TextButton, label));
        await tester.pumpAndSettle();
      }
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.byType(TimePickerDialog), findsNothing);
      expect(find.byType(TicketSettingsFields), findsOneWidget);
      expect(model.draft, same(before));
    });
  }
  for (final system in [false, true]) {
    testWidgets('${system ? '시스템' : '상단'} 뒤로가기는 소개→설정→페이지→상위 순서다', (
      tester,
    ) async {
      final nav = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
          ],
          child: MaterialApp(
            navigatorKey: nav,
            theme: AppTheme.light,
            home: const Scaffold(body: Text('landing')),
          ),
        ),
      );
      nav.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const TicketPreviewWorkspace(role: TicketRole.organizer),
        ),
      );
      await tester.pumpAndSettle();
      final model = await _description(tester);
      await tester.enterText(
        find.byKey(const ValueKey('ticketDescription_introduction')),
        '데모 소개 초안',
      );
      Future<void> back() async {
        if (system) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byTooltip('뒤로가기'));
        }
        await tester.pumpAndSettle();
      }

      await back();
      expect(find.byType(TicketSettingsFields), findsOneWidget);
      expect(model.repository.read(), isNull);
      expect(model.draft.introduction, '데모 소개 초안');
      await _tap(tester, 'ticketSettings_save');
      expect(
        tester
            .widget<TicketDescriptionSection>(
              find.byType(TicketDescriptionSection),
            )
            .model
            .draft
            .introduction,
        '데모 소개 초안',
      );
      await back();
      await back();
      expect(find.byKey(TicketPageView.createKey), findsOneWidget);
      expect(find.byKey(TicketPageView.createdKey), findsNothing);
      await back();
      expect(find.text('landing'), findsOneWidget);
      expect(model.canEdit, isFalse);
    });
  }

  testWidgets('소개와 유의사항 UI는 200자로 제한하고 최종 다음에서만 저장한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TicketPreviewWorkspace(role: TicketRole.organizer),
        ),
      ),
    );
    final model = await _description(tester);
    await tester.enterText(
      find.byKey(const ValueKey('ticketDescription_introduction')),
      '가' * 201,
    );
    await tester.enterText(
      find.byKey(const ValueKey('ticketDescription_precautions')),
      '나' * 201,
    );
    expect(model.draft.introduction, '가' * 200);
    expect(model.draft.precautions, '나' * 200);
    expect(model.repository.read(), isNull);
    await _tap(tester, 'ticketDescription_save');
    expect(model.repository.read()?.draft.introduction, '가' * 200);
    expect(model.repository.read()?.draft.precautions, '나' * 200);
    expect(find.byKey(TicketPageView.createdKey), findsOneWidget);
  });

  testWidgets('소개 화면의 연락처 형태는 오류를 보이고 수정 후 저장한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TicketPreviewWorkspace(role: TicketRole.organizer),
        ),
      ),
    );
    final model = await _description(tester);
    await tester.enterText(
      find.byKey(const ValueKey('ticketDescription_precautions')),
      '000-0000-0000',
    );
    await _tap(tester, 'ticketDescription_save');
    expect(
      find.byKey(const ValueKey('ticketDescription_error_precautions')),
      findsOneWidget,
    );
    expect(model.repository.read(), isNull);
    await tester.enterText(
      find.byKey(const ValueKey('ticketDescription_precautions')),
      '데모 공연 시작 전 입장',
    );
    await _tap(tester, 'ticketDescription_save');
    expect(model.repository.read()?.draft.precautions, '데모 공연 시작 전 입장');
  });

  testWidgets('한 프레임 내 actor 왕복은 이전 최종 저장 핸들을 영구 폐기한다', (tester) async {
    final actor = ValueNotifier<TicketPageScope>(_host);
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
    final old = await _description(tester);
    final save = tester
        .widget<AppButton>(find.byKey(const ValueKey('ticketDescription_save')))
        .onPressed;
    actor.value = _member;
    actor.value = _host;
    save?.call();
    expect(old.saved, isFalse);
    expect(old.repository.read, throwsA(isA<TicketSettingsFailure>()));
    await tester.pumpAndSettle();
    expect(find.byKey(TicketPageView.createKey), findsOneWidget);
    await tester.tap(find.byKey(TicketPageView.createKey));
    await tester.pumpAndSettle();
    final fresh = tester
        .widget<TicketSettingsFields>(find.byType(TicketSettingsFields))
        .model;
    expect(fresh, isNot(same(old)));
    expect(fresh.repository.read(), isNull);
  });

  testWidgets('같은 값의 actorScope 원본 교체 후 새 폼을 열 수 있다', (tester) async {
    final first = ValueNotifier<TicketPageScope>(_host);
    final second = ValueNotifier<TicketPageScope>(_host);
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    final container = ProviderContainer(
      overrides: [
        ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
      ],
    );
    addTearDown(container.dispose);
    Widget app(ValueNotifier<TicketPageScope> actor) =>
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: TicketPreviewWorkspace(actorScope: actor),
          ),
        );
    await tester.pumpWidget(app(first));
    await tester.pumpAndSettle();
    await tester.pumpWidget(app(second));
    await tester.pumpAndSettle();
    final model = await _description(tester);
    expect(model.canEdit, isTrue);
  });

  testWidgets('페이지 생성 실패 뒤 같은 설정을 수정 없이 재시도할 수 있다', (tester) async {
    final repository = _FailOnceRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
          ticketPageRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TicketPreviewWorkspace(role: TicketRole.organizer),
        ),
      ),
    );
    await _description(tester);
    await _tap(tester, 'ticketDescription_save');
    expect(find.byKey(TicketPageView.createdKey), findsNothing);
    await _tap(tester, 'ticket_page_retry');
    expect(find.byType(TicketSettingsFields), findsOneWidget);
    await _tap(tester, 'ticketSettings_save');
    await _tap(tester, 'ticketDescription_save');
    expect(find.byKey(TicketPageView.createdKey), findsOneWidget);
    expect(repository.attempts, 2);
  });

  testWidgets('닫기 애니메이션 전 일정 핸들을 폐기한다', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketSettingsClockProvider.overrideWithValue(() => settingsNow),
        ],
        child: MaterialApp(
          navigatorKey: nav,
          theme: AppTheme.light,
          home: const Scaffold(body: Text('landing')),
        ),
      ),
    );
    nav.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const TicketPreviewWorkspace(role: TicketRole.organizer),
      ),
    );
    await tester.pumpAndSettle();
    final model = await _description(tester);
    await _tap(tester, 'ticketDescription_save');
    expect(model.scheduleSource.readSchedule(), isNotNull);
    nav.currentState!.pop();
    // dispose/pump 이전에도 pop 알림이 즉시 핸들을 폐기해야 한다.
    expect(
      model.scheduleSource.readSchedule,
      throwsA(isA<TicketSettingsFailure>()),
    );
    await tester.pumpAndSettle();
  });

  for (final time in [false, true]) {
    testWidgets('${time ? '시간' : '날짜'} 선택 중 actor 전환은 선택창과 폼을 함께 폐기한다', (
      tester,
    ) async {
      final actor = ValueNotifier<TicketPageScope>(_host);
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
      await _tap(tester, 'ticketSettings_performanceStartsAt');
      expect(find.byType(DatePickerDialog), findsOneWidget);
      if (time) {
        final label = MaterialLocalizations.of(
          tester.element(find.byType(DatePickerDialog)),
        ).okButtonLabel;
        await tester.tap(find.widgetWithText(TextButton, label));
        await tester.pumpAndSettle();
        expect(find.byType(TimePickerDialog), findsOneWidget);
      }
      actor.value = _member;
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.byType(TimePickerDialog), findsNothing);
      expect(find.byKey(TicketPageView.deniedKey), findsOneWidget);
    });
  }

  testWidgets('독립 J159 페이지는 onBack 없이도 원래 상단 뒤로가기를 유지한다', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorKey: nav,
          theme: AppTheme.light,
          home: const Scaffold(body: Text('landing')),
        ),
      ),
    );
    nav.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const TicketPageView(role: TicketRole.organizer),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();
    expect(find.text('landing'), findsOneWidget);
    expect(find.byType(TicketPageView), findsNothing);
  });
}

class _FailOnceRepository extends PreviewTicketPageRepository {
  int attempts = 0;

  @override
  Future<TicketApplicationPage> create(TicketPageScope scope) {
    attempts++;
    if (attempts == 1) {
      throw const TicketPageFailure(TicketPageFailureReason.unavailable);
    }
    return super.create(scope);
  }
}
