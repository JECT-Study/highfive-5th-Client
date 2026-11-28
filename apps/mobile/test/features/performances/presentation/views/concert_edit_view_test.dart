import 'dart:async';
import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/concert_edit_repository.dart';
import 'package:highfive/features/performances/models/concert_edit_failure.dart';
import 'package:highfive/features/performances/models/concert_edit_values.dart';
import 'package:highfive/features/performances/presentation/view_models/concert_edit_view_model.dart';
import 'package:highfive/features/performances/presentation/views/concert_edit_view.dart';
import 'package:highfive/features/performances/presentation/widgets/concert_date_picker.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_text_field.dart';

import '../../edit_fixture.dart';

class _Repository implements ConcertEditRepository {
  ConcertEditValues? saved;
  ConcertEditFailureKind? fail;
  Future<void>? pending;
  @override
  Future<void> save(ConcertEditValues values) async {
    await pending;
    if (fail case final kind?) throw ConcertEditFailure(kind);
    saved = values;
  }

  @override
  Future<ConcertEditSnapshot> reload() async => editSnapshot(
    values: {...editJson(), 'title': '다른 멤버가 수정한 제목', 'version': 8},
  );
}

void main() {
  Future<void> open(
    WidgetTester tester,
    _Repository repository, {
    bool participant = true,
    VoidCallback? onClose,
    VoidCallback? onSaved,
    Map<String, dynamic>? values,
  }) async {
    final entry = ConcertEditEntry(
      initial: editSnapshot(participant: participant, values: values),
      repository: repository,
      isSessionCurrent: () => true,
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: ConcertEditView(
            entry: entry,
            onClose: onClose ?? () {},
            onSaved: onSaved ?? () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String name) => find.descendant(
    of: find.byKey(ValueKey('concertEdit_$name')),
    matching: find.byType(TextField),
  );

  testWidgets('기존 값을 채우고 제목 수정 저장 시 숨은 값까지 유지한다', (tester) async {
    final repository = _Repository();
    var saved = 0;
    await open(tester, repository, onSaved: () => saved++);
    expect(tester.widget<TextField>(field('title')).controller!.text, '기존 공연');
    await tester.enterText(field('title'), '제목만 변경');
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved!.toJson(), {...editJson(), 'title': '제목만 변경'});
    expect(saved, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('잘못된 제목은 입력칸 오류를 표시하고 저장하지 않는다', (tester) async {
    final repository = _Repository();
    await open(tester, repository);
    await tester.enterText(field('title'), ' ');
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AppTextField>(find.byKey(const ValueKey('concertEdit_title')))
          .invalid,
      isTrue,
    );
    expect(repository.saved, isNull);
  });

  testWidgets('비참여자에게 입력과 저장을 비활성화한다', (tester) async {
    final repository = _Repository();
    await open(tester, repository, participant: false);
    expect(tester.widget<TextField>(field('title')).enabled, isFalse);
    expect(tester.widget<TextField>(field('startTime')).enabled, isFalse);
    expect(tester.widget<TextField>(field('endTime')).enabled, isFalse);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    expect(
      tester
          .widget<AppButton>(find.byKey(const ValueKey('concertEdit_save')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('버전 충돌은 화면 입력도 최신 상세 값으로 다시 채운다', (tester) async {
    final repository = _Repository()..fail = ConcertEditFailureKind.conflict;
    await open(tester, repository);
    await tester.enterText(field('title'), '충돌한 옛 입력');
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(field('title')).controller!.text,
      '다른 멤버가 수정한 제목',
    );
    repository.fail = null;
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved!.version, 8);
  });

  testWidgets('공연 삭제 오류 안내를 확인하면 이전 화면으로 나간다', (tester) async {
    final repository = _Repository()..fail = ConcertEditFailureKind.missing;
    var closed = 0;
    await open(tester, repository, onClose: () => closed++);
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    final confirm = tester
        .widget<TextButton>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextButton),
          ),
        )
        .onPressed!;
    confirm();
    confirm();
    await tester.pumpAndSettle();
    expect(closed, 1);
  });

  testWidgets('저장 전 닫기는 확인 후에만 나가고 취소하면 입력을 유지한다', (tester) async {
    var closed = 0;
    await open(tester, _Repository(), onClose: () => closed++);
    await tester.enterText(field('title'), '저장 안 한 제목');
    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextButton),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(closed, 0);
    expect(
      tester.widget<TextField>(field('title')).controller!.text,
      '저장 안 한 제목',
    );
  });

  testWidgets('닫기 연속 탭은 이전 화면 이동을 한 번만 실행한다', (tester) async {
    var closed = 0;
    await open(tester, _Repository(), onClose: () => closed++);
    await tester.tap(find.byTooltip('닫기'));
    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    expect(closed, 1);
  });

  testWidgets('저장 완료 시 다른 화면이 위에 있으면 그 화면을 닫지 않는다', (tester) async {
    final completed = Completer<void>();
    final repository = _Repository()..pending = completed.future;
    var savedCallbacks = 0;
    await open(tester, repository, onSaved: () => savedCallbacks++);
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pump();
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(
      navigator.push<void>(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('위에 열린 화면')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    completed.complete();
    await tester.pumpAndSettle();
    expect(savedCallbacks, 0);
    expect(find.byType(ConcertEditView), findsNothing);
  });

  testWidgets('달력의 월 이동과 취소는 원래 지난 날짜를 변경하지 않는다', (tester) async {
    final repository = _Repository();
    await open(tester, repository);
    await tester.tap(find.byKey(const ValueKey('concertEdit_date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concertDate_next')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ConcertDateInput>(
            find.byKey(const ValueKey('concertEdit_date')),
          )
          .value,
      '2020-01-01',
    );
    final context = tester.element(
      find.byKey(const ValueKey('concertDate_sheet')),
    );
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved!.performDate, '2020-01-01');
  });

  testWidgets('날짜를 건드리지 않은 제목 수정은 API null을 유지한다', (tester) async {
    final repository = _Repository();
    await open(
      tester,
      repository,
      values: {...editJson(), 'performDate': null},
    );
    await tester.enterText(field('title'), '날짜 유지');
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved!.performDate, isNull);
    expect(repository.saved!.title, '날짜 유지');
  });

  testWidgets('시간 미정 체크를 되돌리면 초를 포함한 이전 범위를 복구한다', (tester) async {
    final semantics = tester.ensureSemantics();
    final repository = _Repository();
    await open(tester, repository);
    await tester.ensureVisible(find.byType(Checkbox));
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(
      tester
          .getSemantics(find.byType(Checkbox))
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isFalse,
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field('startTime')).enabled, isFalse);
    expect(tester.widget<TextField>(field('endTime')).enabled, isFalse);
    expect(
      tester
          .getSemantics(find.byType(Checkbox))
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isTrue,
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved!.startTime, editJson()['startTime']);
    expect(repository.saved!.endTime, editJson()['endTime']);
    semantics.dispose();
  });

  testWidgets('처음부터 미정인 시간은 다른 필드만 수정해도 null을 유지한다', (tester) async {
    final repository = _Repository();
    await open(
      tester,
      repository,
      values: {...editJson(), 'startTime': null, 'endTime': null},
    );
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    await tester.enterText(field('title'), '시간 유지');
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved!.startTime, isNull);
    expect(repository.saved!.endTime, isNull);
  });

  testWidgets('시간을 수정한 뒤 미정을 켰다 끄면 수정한 범위를 유지한다', (tester) async {
    final repository = _Repository();
    await open(tester, repository);
    await tester.ensureVisible(field('startTime'));
    await tester.enterText(field('startTime'), '18:30');
    await tester.enterText(field('endTime'), '22:10');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved!.startTime, '18:30:00');
    expect(repository.saved!.endTime, '22:10:00');
  });

  testWidgets('미정 체크는 이전 입력을 보관하고 API에는 시간 두 개를 함께 비운다', (tester) async {
    final repository = _Repository();
    await open(tester, repository);
    await tester.ensureVisible(field('startTime'));
    await tester.enterText(field('startTime'), '18:30');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(
      tester.widget<TextField>(field('startTime')).controller!.text,
      '18:30',
    );
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved!.startTime, isNull);
    expect(repository.saved!.endTime, isNull);
  });

  testWidgets('시간 API null은 체크된 상태이며 해제 후 반쪽 범위는 저장하지 않는다', (tester) async {
    final repository = _Repository();
    await open(
      tester,
      repository,
      values: {...editJson(), 'startTime': null, 'endTime': null},
    );
    await tester.ensureVisible(find.byType(Checkbox));
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(field('startTime'));
    await tester.enterText(field('startTime'), '18:30');
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved, isNull);
    expect(tester.widget<TextField>(field('startTime')).enabled, isTrue);
    await tester.enterText(field('endTime'), '21:15');
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(repository.saved!.startTime, '18:30:00');
    expect(repository.saved!.endTime, '21:15:00');
  });

  testWidgets('저장 중에는 날짜 시간 입력과 체크박스가 비활성화된다', (tester) async {
    final completion = Completer<void>();
    final repository = _Repository()..pending = completion.future;
    await open(tester, repository);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    expect(tester.widget<TextField>(field('startTime')).enabled, isFalse);
    expect(
      tester
          .widget<ConcertDateInput>(
            find.byKey(const ValueKey('concertEdit_date')),
          )
          .onTap,
      isNull,
    );
    completion.complete();
    await tester.pumpAndSettle();
  });

  for (final size in [const Size(320, 720), const Size(1024, 900)]) {
    testWidgets('긴 폼은 작은 화면과 넓은 화면에서 저장 영역을 유지한다 ($size)', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester, _Repository());
      await tester.drag(
        find.byKey(const ValueKey('concertEdit_scroll')),
        const Offset(0, -1500),
      );
      await tester.pumpAndSettle();
      expect(field('rentalFee'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('concertEdit_save')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
