import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/concert_edit_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_edit_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/models/concert_edit_failure.dart';
import 'package:highfive/features/performances/models/concert_edit_form.dart';
import 'package:highfive/features/performances/models/concert_update.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_edit_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_edit_view.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_date_sheet.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_chip.dart';
import 'package:highfive/shared/widgets/app_dialog.dart';
import 'package:highfive/shared/widgets/app_selection_controls.dart';
import 'package:highfive/shared/widgets/app_stepper.dart';
import 'package:highfive/shared/widgets/app_text_field.dart';
import 'package:highfive/shared/widgets/app_top_bar.dart';
import 'package:highfive/shared/widgets/show/show_confirm_popup.dart';

const _sample = FakeConcertRepository.sample;

class _Callbacks {
  int closed = 0;
  int saved = 0;
}

/// 상세 조회를 실패시키거나 다시 성공시킨다.
class _Details implements ConcertRepository {
  _Details(this.error);

  Object? error;

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async {
    if (error case final error?) throw error;
    return _sample;
  }
}

/// 저장 요청을 정해 둔 결과로 끝낸다.
class _Edits implements ConcertEditRepository {
  _Edits(this.respond);

  final Future<void> Function() respond;

  @override
  Future<void> update(int concertId, ConcertUpdate update) => respond();
}

class _HeldRefetch implements ConcertRepository {
  int reads = 0;
  final requested = Completer<void>();
  final response = Completer<ConcertDetail>();

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async {
    if (reads++ == 0) return _sample;
    if (!requested.isCompleted) requested.complete();
    return response.future;
  }
}

Future<_Callbacks> _open(
  WidgetTester tester, {
  FakeConcertEditRepository? repository,
  ConcertRepository? details,
  ConcertEditRepository? edits,
  double width = 375,
  int concertId = 12,
}) async {
  // 폼 전체가 한 화면에 들어오는 세로 길이. 넘침 검사는 폭으로 한다.
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = Size(width, 1800);
  addTearDown(tester.view.reset);
  final fake = repository ?? FakeConcertEditRepository();
  final callbacks = _Callbacks();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        concertRepositoryProvider.overrideWithValue(details ?? fake),
        concertEditRepositoryProvider.overrideWithValue(edits ?? fake),
        concertEditTodayProvider.overrideWithValue(
          () => DateTime(2026, 11, 28),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        navigatorObservers: [concertEditRouteObserver],
        home: ConcertEditView(
          concertId: concertId,
          onClose: () => callbacks.closed++,
          onSaved: () => callbacks.saved++,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return callbacks;
}

Finder _field(String name) => find.descendant(
  of: find.byKey(ValueKey('concertEdit_$name')),
  matching: find.byType(TextField),
);

TextField _text(WidgetTester tester, String name) =>
    tester.widget<TextField>(_field(name));

AppButton _save(WidgetTester tester) =>
    tester.widget<AppButton>(find.byKey(const ValueKey('concertEdit_save')));

Finder _undecided(String title) =>
    find.byKey(ValueKey('concertEdit_undecided_$title'));

Finder _popupButtons() => find.descendant(
  of: find.byType(ShowConfirmPopup),
  matching: find.byType(AppButton),
);

Finder _dialogButton() => find.descendant(
  of: find.byType(AppDialog),
  matching: find.byType(AppButton),
);

Finder _stepperButtons() => find.descendant(
  of: find.byKey(const ValueKey('concertEdit_recruitTeamCount')),
  matching: find.byType(IconButton),
);

/// 제목을 바꾸고 수정 완료 → 확인 팝업의 수정하기까지 누른다.
Future<void> _saveTitle(WidgetTester tester, String title) async {
  await tester.enterText(_field('title'), title);
  await tester.pump();
  await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
  await tester.pumpAndSettle();
  await tester.tap(_popupButtons().last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('미확인 중 상세가 갱신돼 깨끗한 폼이어도 나가기 확인을 거친다', (tester) async {
    final repository = FakeConcertEditRepository();
    final callbacks = await _open(
      tester,
      repository: repository,
      edits: _Edits(() async {
        throw const ConcertEditFailure(ConcertEditFailureReason.unconfirmed);
      }),
    );
    await _saveTitle(tester, '보낸 제목');
    await tester.tap(_dialogButton());
    await tester.pumpAndSettle();
    await repository.update(
      12,
      ConcertUpdate.fromDetail(_sample).copyWith(title: '보낸 제목'),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertEditView)),
    );
    container.invalidate(concertDetailProvider(12));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('concertEdit_close')));
    await tester.pumpAndSettle();

    expect(callbacks.closed, 0);
    expect(find.byType(ShowConfirmPopup), findsOneWidget);
    await tester.tap(_popupButtons().last);
    await tester.pumpAndSettle();
    expect(callbacks.closed, 1);
  });

  testWidgets('연도가 다른 날짜 변경은 확인창 양쪽에 연도를 표시한다', (tester) async {
    await _open(tester);
    await tester.tap(_field('performDate'));
    await tester.pumpAndSettle();
    for (var month = 0; month < 12; month++) {
      await tester.tap(find.byKey(const ValueKey('concertDate_next')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('concertDate_2027-12-20')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertDate_confirm')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();

    final change = tester
        .widget<ShowConfirmPopup>(find.byType(ShowConfirmPopup))
        .details
        .single
        .value;
    expect(change, contains('2026'));
    expect(change, contains('2027'));
  });

  testWidgets('대관비를 한 자리씩 입력해도 다섯 자리 정수를 그대로 저장한다', (tester) async {
    final repository = FakeConcertEditRepository();
    await _open(tester, repository: repository);
    await tester.enterText(_field('rentalFee'), '');
    for (final digit in '50000'.split('')) {
      final current = _text(tester, 'rentalFee').controller!.text;
      await tester.enterText(_field('rentalFee'), '$current$digit');
      await tester.pump();
    }

    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(find.byType(ShowConfirmPopup), findsOneWidget);
    await tester.tap(_popupButtons().last);
    await tester.pumpAndSettle();

    expect((await repository.fetchDetail(12)).rentalFee, 50000);
  });

  testWidgets('결과 미확인 화면은 입력을 막고 같은 버튼으로 PUT 없이 재확인한다', (tester) async {
    var writes = 0;
    await _open(
      tester,
      edits: _Edits(() async {
        writes++;
        throw const ConcertEditFailure(ConcertEditFailureReason.unconfirmed);
      }),
    );
    await _saveTitle(tester, '확인할 제목');
    await tester.tap(_dialogButton());
    await tester.pumpAndSettle();
    expect(_text(tester, 'title').enabled, isFalse);
    expect(_save(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();

    expect(writes, 1);
    expect(find.byType(ShowConfirmPopup), findsNothing);
    expect(find.byType(AppDialog), findsOneWidget);
  });

  testWidgets('충돌 재조회가 끝나기 전에는 이전 폼을 다시 편집할 수 없다', (tester) async {
    final details = _HeldRefetch();
    await _open(
      tester,
      details: details,
      edits: _Edits(() async {
        throw const ConcertEditFailure(ConcertEditFailureReason.conflict);
      }),
    );
    await tester.enterText(_field('title'), '내 수정');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    await tester.tap(_popupButtons().last);
    await tester.pump();
    await details.requested.future.timeout(const Duration(seconds: 5));

    expect(_field('title'), findsNothing);
    details.response.complete(_sample.copyWith(title: '최신 제목', version: 4));
    await tester.pumpAndSettle();
    await tester.tap(_dialogButton());
    await tester.pumpAndSettle();

    expect(_text(tester, 'title').controller!.text, '최신 제목');
  });

  testWidgets('같은 version의 다른 공연으로 바꾸면 캐시된 상세로 폼을 다시 만든다', (tester) async {
    final repository = FakeConcertEditRepository(
      concerts: [
        _sample,
        _sample.copyWith(concertId: 27, title: '다른 공연'),
      ],
    );
    await _open(tester, repository: repository);
    await tester.enterText(_field('title'), '이전 공연의 입력');
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertEditView)),
    );
    final cached = container.listen(concertDetailProvider(27), (_, _) {});
    addTearDown(cached.close);
    await container.read(concertDetailProvider(27).future);

    await _open(tester, repository: repository, concertId: 27);

    expect(_text(tester, 'title').controller!.text, '다른 공연');
    expect(_save(tester).onPressed, isNull);
  });

  testWidgets('대관비의 소수점과 부호를 지워 다른 금액으로 저장하지 않는다', (tester) async {
    final repository = FakeConcertEditRepository();
    await _open(tester, repository: repository);
    for (final input in ['500,000.00', '-100']) {
      await tester.enterText(_field('rentalFee'), input);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
      await tester.pumpAndSettle();
      expect(find.byType(ShowConfirmPopup), findsNothing);
      expect(
        find.byKey(const ValueKey('concertEdit_rentalFee_error')),
        findsOneWidget,
      );
      expect((await repository.fetchDetail(12)).rentalFee, _sample.rentalFee);
    }
  });

  testWidgets('다른 경로 위에서 끝난 저장은 복귀 후에만 한 번 완료 처리한다', (tester) async {
    final response = Completer<void>();
    final callbacks = await _open(tester, edits: _Edits(() => response.future));
    await _saveTitle(tester, '새 제목');
    final navigator = Navigator.of(
      tester.element(find.byType(ConcertEditView)),
    );
    final covered = navigator.push<void>(
      MaterialPageRoute(builder: (_) => const Scaffold(key: ValueKey('cover'))),
    );
    await tester.pumpAndSettle();

    response.complete();
    await tester.pumpAndSettle();
    expect(callbacks.saved, 0);
    navigator.pop();
    await tester.pumpAndSettle();
    await covered;

    expect(callbacks.saved, 1);
  });

  testWidgets('다른 경로 위에서 끝난 실패 안내는 편집 화면 복귀 후에만 보인다', (tester) async {
    final response = Completer<void>();
    await _open(
      tester,
      edits: _Edits(() async {
        await response.future;
        throw const ConcertEditFailure(ConcertEditFailureReason.forbidden);
      }),
    );
    await _saveTitle(tester, '새 제목');
    final navigator = Navigator.of(
      tester.element(find.byType(ConcertEditView)),
    );
    final covered = navigator.push<void>(
      MaterialPageRoute(builder: (_) => const Scaffold(key: ValueKey('cover'))),
    );
    await tester.pumpAndSettle();

    response.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsNothing);
    navigator.pop();
    await tester.pumpAndSettle();
    await covered;

    expect(find.byType(AppDialog), findsOneWidget);
  });

  testWidgets('상세 값으로 입력칸을 채우고, 바꾸기 전에는 저장할 수 없다', (tester) async {
    await _open(tester);

    expect(_text(tester, 'title').controller!.text, _sample.title);
    expect(
      _text(tester, 'performDate').controller!.text,
      concertDateLabel(_sample.performDate!),
    );
    expect(_text(tester, 'place').controller!.text, _sample.place);
    expect(_text(tester, 'address').controller!.text, _sample.address);
    expect(_text(tester, 'rentalFee').controller!.text, '500,000');
    // 상세의 시간이 미정(null)이라 체크된 채로 시작하고 입력칸은 꺼져 있다.
    expect(tester.widget<AppCheckbox>(_undecided('공연 시간')).checked, isTrue);
    expect(_text(tester, 'startTime').enabled, isFalse);
    expect(
      tester
          .widget<AppChip>(find.byKey(const ValueKey('concertEdit_genre_ROCK')))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<AppChip>(
            find.byKey(const ValueKey('concertEdit_genre_METAL')),
          )
          .selected,
      isFalse,
    );
    expect(_save(tester).onPressed, isNull);
  });

  testWidgets('제목을 바꾸고 확인 팝업에서 수정하면 저장하고 onSaved를 부른다', (tester) async {
    final repository = FakeConcertEditRepository();
    final callbacks = await _open(tester, repository: repository);

    await tester.enterText(_field('title'), '새 제목');
    await tester.pump();
    expect(_save(tester).onPressed, isNotNull);
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    final popup = tester.widget<ShowConfirmPopup>(
      find.byType(ShowConfirmPopup),
    );
    expect(popup.details.single.value, contains('새 제목'));
    await tester.tap(_popupButtons().last);
    await tester.pumpAndSettle();

    expect(callbacks.saved, 1);
    final saved = await repository.fetchDetail(12);
    expect((saved.title, saved.version), ('새 제목', _sample.version + 1));
  });

  testWidgets('확인 팝업에서 취소하면 저장하지 않고 입력을 그대로 둔다', (tester) async {
    final repository = FakeConcertEditRepository();
    final callbacks = await _open(tester, repository: repository);

    await tester.enterText(_field('title'), '새 제목');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    await tester.tap(_popupButtons().first);
    await tester.pumpAndSettle();

    expect(callbacks.saved, 0);
    expect((await repository.fetchDetail(12)).version, _sample.version);
    expect(_text(tester, 'title').controller!.text, '새 제목');
  });

  testWidgets('잘못된 입력은 칸 아래 오류를 보이고 확인 팝업 없이 멈춘다', (tester) async {
    final repository = FakeConcertEditRepository();
    await _open(tester, repository: repository);

    await tester.enterText(_field('title'), '   ');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();

    expect(find.byType(ShowConfirmPopup), findsNothing);
    expect(
      find.byKey(const ValueKey('concertEdit_title_error')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<AppTextField>(find.byKey(const ValueKey('concertEdit_title')))
          .invalid,
      isTrue,
    );
    expect((await repository.fetchDetail(12)).version, _sample.version);

    await tester.enterText(_field('title'), '고친 제목');
    await tester.pump();
    expect(find.byKey(const ValueKey('concertEdit_title_error')), findsNothing);
  });

  testWidgets('시간을 하나만 적으면 시간 칸 오류로 저장을 막는다', (tester) async {
    await _open(tester);

    await tester.tap(_undecided('공연 시간'));
    await tester.pump();
    await tester.enterText(_field('startTime'), '19:00');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('concertEdit_time_error')),
      findsOneWidget,
    );
    expect(find.byType(ShowConfirmPopup), findsNothing);
  });

  testWidgets('미정을 켜면 칸을 끄되 값은 남기고, 저장하면 null을 보낸다', (tester) async {
    final repository = FakeConcertEditRepository();
    await _open(tester, repository: repository);

    await tester.tap(_undecided('전체 대관비'));
    await tester.pump();
    expect(_text(tester, 'rentalFee').enabled, isFalse);
    expect(_text(tester, 'rentalFee').controller!.text, '500,000');

    await tester.tap(_undecided('전체 대관비'));
    await tester.pump();
    expect(_text(tester, 'rentalFee').enabled, isTrue);
    expect(_save(tester).onPressed, isNull);

    await tester.tap(_undecided('전체 대관비'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    await tester.tap(_popupButtons().last);
    await tester.pumpAndSettle();

    expect((await repository.fetchDetail(12)).rentalFee, isNull);
  });

  testWidgets('날짜 칸을 누르면 달력이 열리고 고른 날짜가 들어간다', (tester) async {
    await _open(tester);

    await tester.tap(_field('performDate'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('concertDate_sheet')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('concertDate_2026-12-24')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('concertDate_confirm')));
    await tester.pumpAndSettle();

    expect(
      _text(tester, 'performDate').controller!.text,
      concertDateLabel('2026-12-24'),
    );
    expect(_save(tester).onPressed, isNotNull);
  });

  testWidgets('주최 대표자가 아니면 모집 팀 수를 바꿀 수 없다', (tester) async {
    await _open(tester);

    expect(_stepperButtons(), findsNWidgets(2));
    expect(
      tester.widgetList<IconButton>(_stepperButtons()).map((b) => b.onPressed),
      everyElement(isNull),
    );
  });

  testWidgets('주최 대표자는 합류한 팀 수까지만 줄이고 늘린 값을 저장한다', (tester) async {
    final repository = FakeConcertEditRepository(
      concerts: [
        _sample.copyWith(
          recruitTeamCount: 1,
          myPermissions: const ConcertPermissions(
            isHostLeader: true,
            isTeamLeader: true,
          ),
        ),
      ],
    );
    await _open(tester, repository: repository);
    final buttons = tester.widgetList<IconButton>(_stepperButtons()).toList();
    // 합류 1팀이라 1팀보다 줄일 수 없다.
    expect(buttons.first.onPressed, isNull);
    expect(buttons.last.onPressed, isNotNull);

    await tester.tap(_stepperButtons().last);
    await tester.pump();
    expect(
      tester
          .widget<AppStepper>(
            find.byKey(const ValueKey('concertEdit_recruitTeamCount')),
          )
          .valueLabel,
      contains('2'),
    );
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    await tester.tap(_popupButtons().last);
    await tester.pumpAndSettle();

    expect((await repository.fetchDetail(12)).recruitTeamCount, 2);
  });

  testWidgets('바꾼 뒤 닫으면 나가기 팝업을 띄우고, 계속 수정이면 남고 나가기면 닫는다', (tester) async {
    final callbacks = await _open(tester);
    await tester.enterText(_field('title'), '새 제목');
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('concertEdit_close')));
    await tester.pumpAndSettle();
    expect(find.byType(ShowConfirmPopup), findsOneWidget);
    await tester.tap(_popupButtons().first);
    await tester.pumpAndSettle();
    expect(find.byType(ShowConfirmPopup), findsNothing);
    expect(callbacks.closed, 0);

    await tester.tap(find.byKey(const ValueKey('concertEdit_close')));
    await tester.pumpAndSettle();
    await tester.tap(_popupButtons().last);
    await tester.pumpAndSettle();
    expect(callbacks.closed, 1);
  });

  testWidgets('바꾸지 않았으면 팝업 없이 바로 닫는다', (tester) async {
    final callbacks = await _open(tester);

    await tester.tap(find.byKey(const ValueKey('concertEdit_close')));
    await tester.pumpAndSettle();

    expect(find.byType(ShowConfirmPopup), findsNothing);
    expect(callbacks.closed, 1);
  });

  testWidgets('다른 멤버가 먼저 수정했으면 안내하고 최신 상세로 다시 채운다', (tester) async {
    final repository = FakeConcertEditRepository();
    final callbacks = await _open(tester, repository: repository);
    // 화면을 연 뒤 다른 멤버가 먼저 저장했다.
    await repository.update(
      12,
      ConcertUpdate.fromDetail(_sample).copyWith(title: '다른 멤버 제목'),
    );

    await _saveTitle(tester, '내 제목');

    expect(find.byType(AppDialog), findsOneWidget);
    expect(callbacks.saved, 0);
    await tester.tap(_dialogButton());
    await tester.pumpAndSettle();
    expect(_text(tester, 'title').controller!.text, '다른 멤버 제목');
  });

  testWidgets('저장하려는데 참여 팀 멤버가 아니면 안내 뒤 이전 화면으로 간다', (tester) async {
    final callbacks = await _open(
      tester,
      edits: _Edits(
        () async =>
            throw const ConcertEditFailure(ConcertEditFailureReason.forbidden),
      ),
    );

    await _saveTitle(tester, '새 제목');
    expect(find.byType(AppDialog), findsOneWidget);
    await tester.tap(_dialogButton());
    await tester.pumpAndSettle();

    expect(callbacks.closed, 1);
    expect(callbacks.saved, 0);
  });

  testWidgets('서버가 입력칸 문제로 거절하면 그 칸 아래에 서버 문구를 보인다', (tester) async {
    await _open(
      tester,
      edits: _Edits(
        () async => throw const ConcertEditFailure(
          ConcertEditFailureReason.invalid,
          issues: {ConcertEditField.title: ConcertEditIssue.rejected},
          serverReasons: {ConcertEditField.title: '서버 사유'},
        ),
      ),
    );

    await _saveTitle(tester, '새 제목');

    expect(find.byType(AppDialog), findsNothing);
    final error = tester.widget<Text>(
      find.byKey(const ValueKey('concertEdit_title_error')),
    );
    expect(error.data, '서버 사유');
  });

  testWidgets('저장 중에는 입력과 닫기를 막고 버튼은 진행 중으로 보인다', (tester) async {
    final response = Completer<void>();
    final callbacks = await _open(tester, edits: _Edits(() => response.future));

    await _saveTitle(tester, '새 제목');

    expect(_save(tester).loading, isTrue);
    expect(_text(tester, 'title').enabled, isFalse);
    expect(
      tester
          .widget<AppIconButton>(
            find.byKey(const ValueKey('concertEdit_close')),
          )
          .onPressed,
      isNull,
    );
    response.complete();
    await tester.pumpAndSettle();
    expect(callbacks.saved, 1);
  });

  testWidgets('공연이 없거나 참여하지 않은 공연이면 안내하고 이전 화면으로 보낸다', (tester) async {
    for (final error in const [
      ApiException(statusCode: 404, code: 'CONCERT_001'),
      ApiException(statusCode: 403, code: 'AUTH_005'),
    ]) {
      final callbacks = await _open(tester, details: _Details(error));

      expect(find.byKey(const ValueKey('concertEdit_title')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('concertEdit_loadAction')));
      await tester.pumpAndSettle();
      expect(callbacks.closed, 1, reason: '${error.code}');
    }
  });

  testWidgets('그 밖의 이유로 상세를 읽지 못하면 다시 시도로 다시 읽는다', (tester) async {
    // Error는 공용 조회가 자동 재시도하지 않아 바로 실패 화면이 된다.
    final details = _Details(StateError('응답 해석 실패'));
    final callbacks = await _open(tester, details: details);
    expect(find.byKey(const ValueKey('concertEdit_title')), findsNothing);

    details.error = null;
    await tester.tap(find.byKey(const ValueKey('concertEdit_loadAction')));
    await tester.pumpAndSettle();

    expect(callbacks.closed, 0);
    expect(_text(tester, 'title').controller!.text, _sample.title);
  });

  testWidgets('320 폭에서도 넘치지 않는다', (tester) async {
    await _open(tester, width: 320);

    expect(tester.takeException(), isNull);
  });
}
