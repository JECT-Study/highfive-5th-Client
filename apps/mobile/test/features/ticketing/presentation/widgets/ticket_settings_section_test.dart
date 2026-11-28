import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/ticketing/data/repositories/ticket_settings_repository.dart';
import 'package:highfive/features/ticketing/models/ticket_role.dart';
import 'package:highfive/features/ticketing/models/ticket_schedule.dart';
import 'package:highfive/features/ticketing/models/ticket_settings.dart';
import 'package:highfive/features/ticketing/presentation/view_models/ticket_settings_view_model.dart';
import 'package:highfive/features/ticketing/presentation/widgets/ticket_settings_section.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_text_field.dart';

import '../../settings_fixture.dart';

Widget _app({
  TicketRole role = TicketRole.organizer,
  String actorId = ticketPreviewActorId,
  TicketSettingsRepository? repository,
  ValueChanged<TicketSchedule>? onSaved,
}) {
  final model = repository == null ? null : TicketSettingsViewModel(repository);
  if (model != null) addTearDown(model.dispose);
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        child: TicketSettingsSection(
          role: role,
          concert: TicketSettingsConcert.demo,
          actorId: actorId,
          viewModel: model,
          onSaved: onSaved,
        ),
      ),
    ),
  );
}

Finder _key(String name) => find.byKey(ValueKey('ticketSettings_$name'));

Future<void> _tap(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(_key(name));
  await tester.pumpAndSettle();
  await tester.tap(_key(name));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('R2 독립 폼 재저장은 확정 가격과 입력 표시를 일치시킨다', (tester) async {
    final repository = TicketSettingsRepository(
      role: TicketRole.organizer,
      concert: TicketSettingsConcert.demo,
      actorId: ticketPreviewActorId,
      now: () => settingsNow,
    )..save(validTicketSettings());
    await tester.pumpWidget(_app(repository: repository));
    await _tap(tester, 'save');
    await tester.ensureVisible(_key('price'));
    await tester.enterText(_key('price'), '20000');
    await _tap(tester, 'save');
    expect(repository.read()?.draft.price, '15000');
    expect(
      tester.widget<AppTextField>(_key('price')).controller?.text,
      '15000',
    );
    expect(_key('saved'), findsOneWidget);
  });
  testWidgets('빈 폼 저장은 완료 콜백 대신 필드별 검증 오류를 표시한다', (tester) async {
    var saves = 0;
    await tester.pumpWidget(_app(onSaved: (_) => saves++));

    await _tap(tester, 'save');

    expect(saves, 0);
    expect(_key('error_price'), findsOneWidget);
    expect(_key('error_account'), findsOneWidget);
    expect(_key('error_contact'), findsOneWidget);
    expect(_key('saved'), findsNothing);
  });

  testWidgets('계좌와 문의는 자유 입력 없이 데모 선택지로 채워진다', (tester) async {
    final repository = TicketSettingsRepository(
      role: TicketRole.organizer,
      concert: TicketSettingsConcert.demo,
      actorId: ticketPreviewActorId,
      now: () => settingsNow,
    );
    await tester.pumpWidget(_app(repository: repository));
    await _tap(tester, 'account');
    await _tap(tester, 'chooseDemo');
    await _tap(tester, 'contact');
    await _tap(tester, 'chooseDemo');
    // 가격/한도/규정만 편집 가능하고 계좌·전화번호 입력창은 없다.
    expect(find.byType(TextField), findsNWidgets(3));
    expect(
      tester.widgetList<AppTextField>(find.byType(AppTextField)).length,
      2,
    );
    await tester.ensureVisible(_key('price'));
    await tester.enterText(_key('price'), '15000');
    await tester.ensureVisible(_key('capacity'));
    await tester.enterText(_key('capacity'), '120');
    await tester.ensureVisible(_key('refundPolicy'));
    await tester.enterText(_key('refundPolicy'), '데모 환불 규정');
    await _tap(tester, 'save');

    expect(repository.read()?.draft.account, TicketDemoAccount.sample);
    expect(repository.read()?.draft.contact, TicketDemoContact.sample);
  });

  testWidgets('저장 콜백은 검증된 일정을 한 번 전달한다', (tester) async {
    final repository = TicketSettingsRepository(
      role: TicketRole.organizer,
      concert: TicketSettingsConcert.demo,
      actorId: ticketPreviewActorId,
      now: () => settingsNow,
    )..save(validTicketSettings());
    final saved = <TicketSchedule>[];
    await tester.pumpWidget(_app(repository: repository, onSaved: saved.add));

    await _tap(tester, 'save');
    await _tap(tester, 'save');

    expect(saved.length, 1);
    expect(saved.single.registrationClosesAt, DateTime(2027, 1, 12, 18));
    expect(saved.single.refundClosesAt, DateTime(2027, 1, 11, 23, 59));
    expect(_key('saved'), findsOneWidget);
  });

  testWidgets('행위자와 역할을 바꾸면 입력 초안과 저장 표시가 사라진다', (tester) async {
    await tester.pumpWidget(_app());
    await tester.enterText(_key('price'), '12345');

    await tester.pumpWidget(
      _app(role: TicketRole.member, actorId: 'demo-member-a'),
    );
    expect(_key('denied'), findsOneWidget);
    expect(_key('price'), findsNothing);

    await tester.pumpWidget(_app());
    expect(
      tester.widget<AppTextField>(_key('price')).controller?.text,
      isEmpty,
    );
    expect(_key('saved'), findsNothing);
  });

  testWidgets('다른 행위자의 저장소를 끼워 넣으면 설정을 표시하지 않는다', (tester) async {
    final repository = TicketSettingsRepository(
      role: TicketRole.organizer,
      concert: TicketSettingsConcert.demo,
      actorId: ticketPreviewActorId,
      now: () => settingsNow,
    )..save(validTicketSettings());

    await tester.pumpWidget(
      _app(actorId: 'demo-guest', repository: repository),
    );

    expect(_key('denied'), findsOneWidget);
    expect(_key('price'), findsNothing);
  });

  testWidgets('계좌 선택 중 역할이 바뀌면 늦은 선택 결과를 폐기한다', (tester) async {
    await tester.pumpWidget(_app());
    await _tap(tester, 'account');

    await tester.pumpWidget(
      _app(role: TicketRole.member, actorId: 'demo-member-a'),
    );
    await tester.pumpAndSettle();
    await _tap(tester, 'chooseDemo');

    expect(tester.takeException(), isNull);
    expect(_key('denied'), findsOneWidget);
    expect(_key('account'), findsNothing);
  });
}
