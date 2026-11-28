import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/concert_creation_repository.dart';
import 'package:highfive/features/performances/models/concert_creation_failure.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/models/concert_genre.dart';
import 'package:highfive/features/performances/models/host_band.dart';
import 'package:highfive/features/performances/presentation/providers/concert_creation_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_creation_view.dart';
import 'package:highfive/features/performances/presentation/widgets/perform_date_sheet.dart';
import 'package:highfive/shared/theme/app_colors.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_chip.dart';
import 'package:highfive/shared/widgets/app_dialog.dart';
import 'package:highfive/shared/widgets/app_selection_controls.dart';
import 'package:highfive/shared/widgets/app_stepper.dart';
import 'package:highfive/shared/widgets/app_text_field.dart';
import 'package:highfive/shared/widgets/app_top_bar.dart';
import 'package:highfive/shared/widgets/show/image_input.dart';

import '../../../../support/capture.dart';

/// 서버 대신 받은 값을 기록한다. [error]가 있으면 그 실패로, 없으면 [pending](없으면 12)으로 끝난다.
class _FakeRepository extends ConcertCreationRepository {
  _FakeRepository({this.error, this.pending, this.blockReason});

  final ConcertCreationFailure? error;
  final ConcertCreationFailureReason? blockReason;
  final Completer<int>? pending;
  final bands = <HostBand>[];
  final drafts = <ConcertDraft>[];

  @override
  ConcertCreationFailureReason? blockReasonFor(HostBand band) => blockReason;

  @override
  Future<int> create(
    HostBand band,
    ConcertDraft draft, {
    Future<void>? abandoned,
  }) async {
    bands.add(band);
    drafts.add(draft);
    if (error case final error?) throw error;
    return pending?.future ?? 12;
  }
}

const _pushKey = ValueKey('test_pushCreation');

const _band = HostBand(
  id: 3,
  name: '소음공장',
  genres: [ConcertGenre.rock],
  memberCount: 4,
);

Future<void> _open(
  WidgetTester tester,
  _FakeRepository repository, {
  ValueChanged<int>? onCreated,
  VoidCallback? onClose,
  double width = 390,
}) async {
  usePhoneSize(tester, width: width);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        concertCreationRepositoryProvider.overrideWithValue(repository),
        concertTodayProvider.overrideWithValue(() => DateTime(2026, 11, 28)),
      ],
      child: capturable(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: ConcertCreationView(
            hostBand: _band,
            onClose: onClose ?? () {},
            onCreated: onCreated ?? (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _reveal(
  WidgetTester tester,
  Finder finder, {
  double delta = 200,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find
        .descendant(
          of: find.byKey(ConcertCreationView.formKey),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _pickDate(WidgetTester tester, DateTime date) async {
  await tester.tap(find.byKey(ConcertCreationView.performDateKey));
  await tester.pumpAndSettle();
  if (date.month != 11) {
    await tester.tap(find.byKey(PerformDateSheet.nextMonthKey));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byKey(PerformDateSheet.dayKey(date)));
  await tester.pump();
  await tester.tap(find.byKey(PerformDateSheet.confirmKey));
  await tester.pumpAndSettle();
}

Future<void> _fillRequired(WidgetTester tester) async {
  await tester.enterText(find.byKey(ConcertCreationView.titleKey), '겨울 합동공연');
  await tester.tap(find.byType(AppChip).at(ConcertGenre.rock.index));
  await _pickDate(tester, DateTime(2026, 11, 30));
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.byKey(ConcertCreationView.submitKey));
  await tester.pumpAndSettle();
}

AppButton _submitButton(WidgetTester tester) =>
    tester.widget<AppButton>(find.byKey(ConcertCreationView.submitKey));

void main() {
  setUpAll(loadCaptureFonts);

  testWidgets('처음에는 대관비 미정으로 시작하고, 포스터·장소는 서버 계약 전이라 누를 수 없다', (tester) async {
    await _open(tester, _FakeRepository());
    await capture(tester, 'concert-creation-1-initial-top');

    expect(tester.widget<ImageInput>(find.byType(ImageInput)).onTap, isNull);
    await _reveal(tester, find.byKey(ConcertCreationView.rentalFeeKey));
    final checkboxes = tester
        .widgetList<AppCheckbox>(find.byType(AppCheckbox))
        .toList();
    // 장소(미정 고정) → 대관비 순서.
    expect(checkboxes.map((checkbox) => checkbox.checked), [true, true]);
    expect(checkboxes.first.onChanged, isNull);
    expect(checkboxes.last.onChanged, isNotNull);
    expect(
      tester
          .widget<AppTextField>(find.byKey(ConcertCreationView.rentalFeeKey))
          .enabled,
      isFalse,
    );
    await capture(tester, 'concert-creation-2-initial-bottom');
  });

  testWidgets('필수값 없이 만들면 보내지 않고 고칠 항목 아래에 안내한다', (tester) async {
    final repository = _FakeRepository();
    await _open(tester, repository);

    await _submit(tester);

    expect(repository.drafts, isEmpty);
    for (final key in [
      ConcertCreationView.titleKey,
      ConcertCreationView.performDateKey,
    ]) {
      expect(tester.widget<AppTextField>(find.byKey(key)).invalid, isTrue);
    }
    final colors = tester.element(find.byType(ConcertCreationView)).colors;
    // 제목·장르·날짜 아래 오류 안내 3개.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.style?.color == colors.statusDestructive,
      ),
      findsNWidgets(3),
    );
    await capture(tester, 'concert-creation-3-validation');
  });

  testWidgets('입력한 값으로 한 번만 보내고, 서버가 만든 공연 ID를 넘긴다', (tester) async {
    final pending = Completer<int>();
    final repository = _FakeRepository(pending: pending);
    final created = <int>[];
    await _open(tester, repository, onCreated: created.add);

    await tester.enterText(
      find.byKey(ConcertCreationView.titleKey),
      ' 겨울 합동공연 ',
    );
    await tester.tap(find.byType(AppChip).at(ConcertGenre.rock.index));
    await tester.tap(find.byType(AppChip).at(ConcertGenre.indie.index));
    await tester.pump();
    await tester.tap(find.byKey(ConcertCreationView.performDateKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PerformDateSheet.nextMonthKey));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(PerformDateSheet.dayKey(DateTime(2026, 12, 20))),
    );
    await tester.pump();
    await capture(tester, 'concert-creation-4-date-sheet');
    await tester.tap(find.byKey(PerformDateSheet.confirmKey));
    await tester.pumpAndSettle();
    final increment = find
        .descendant(
          of: find.byType(AppStepper),
          matching: find.byType(IconButton),
        )
        .last;
    await _reveal(tester, increment);
    await tester.tap(increment);
    await tester.tap(increment);
    await _reveal(tester, find.byKey(ConcertCreationView.rentalFeeKey));
    await tester.tap(find.byKey(ConcertCreationView.rentalFeeUndecidedKey));
    await tester.pump();
    await tester.enterText(
      find.byKey(ConcertCreationView.rentalFeeKey),
      '500000',
    );
    await tester.pump();
    await capture(tester, 'concert-creation-5-filled-bottom');

    await tester.tap(find.byKey(ConcertCreationView.submitKey));
    await tester.pump();
    expect(_submitButton(tester).loading, isTrue);
    expect(_submitButton(tester).onPressed, isNull);
    await tester.tap(find.byKey(ConcertCreationView.submitKey));
    await tester.pump();
    await capture(tester, 'concert-creation-6-submitting');

    pending.complete(21);
    await tester.pumpAndSettle();

    expect(created, [21]);
    expect(repository.bands.single.id, _band.id);
    final draft = repository.drafts.single;
    expect(draft.validate(today: DateTime(2026, 11, 28)), isEmpty);
    expect(draft.title.trim(), '겨울 합동공연');
    expect(draft.genres, {ConcertGenre.rock, ConcertGenre.indie});
    expect(draft.recruitTeamCount, 3);
    expect(draft.performDate, DateTime(2026, 12, 20));
    expect(draft.rentalFee, 500000);
  });

  testWidgets('권한이 없다는 응답이면 안내한 뒤 화면을 닫는다', (tester) async {
    final repository = _FakeRepository(
      error: const ConcertCreationFailure(
        ConcertCreationFailureReason.forbidden,
      ),
    );
    var closed = 0;
    await _open(tester, repository, onClose: () => closed++);
    await _fillRequired(tester);

    await _submit(tester);
    expect(find.byType(AppDialog), findsOneWidget);
    await capture(tester, 'concert-creation-7-forbidden');
    await tester.tap(
      find.descendant(
        of: find.byType(AppDialog),
        matching: find.byType(AppButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(closed, 1);
    expect(repository.drafts, hasLength(1));
  });

  testWidgets('서버가 받았는지 모르면 안내하고 만들기 버튼을 잠근다', (tester) async {
    final repository = _FakeRepository(
      error: const ConcertCreationFailure(
        ConcertCreationFailureReason.uncertain,
      ),
    );
    await _open(tester, repository);
    await _fillRequired(tester);

    await _submit(tester);
    expect(find.byType(AppDialog), findsOneWidget);
    await capture(tester, 'concert-creation-8-uncertain');
    await tester.tap(
      find.descendant(
        of: find.byType(AppDialog),
        matching: find.byType(AppButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(_submitButton(tester).onPressed, isNull);
    expect(repository.drafts, hasLength(1));
  });

  testWidgets('차단된 생성은 폼 입력 전에 안내하고 전송하지 않는다', (tester) async {
    for (final reason in [
      ConcertCreationFailureReason.unavailable,
      ConcertCreationFailureReason.uncertain,
    ]) {
      final repository = _FakeRepository(blockReason: reason);
      await _open(tester, repository);

      expect(find.byType(AppDialog), findsOneWidget);
      expect(repository.drafts, isEmpty);
      expect(_submitButton(tester).onPressed, isNull);
      if (reason == ConcertCreationFailureReason.unavailable) {
        await capture(tester, 'concert-creation-11-unavailable');
      }
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('대관비를 미정으로 바꾸면 비활성 입력의 오류 표시를 지운다', (tester) async {
    await _open(tester, _FakeRepository());
    final field = find.byKey(ConcertCreationView.rentalFeeKey);
    await _reveal(tester, field);
    await tester.tap(find.byKey(ConcertCreationView.rentalFeeUndecidedKey));
    await tester.pump();
    await _submit(tester);
    await _reveal(tester, field);
    expect(tester.widget<AppTextField>(field).invalid, isTrue);

    await tester.tap(find.byKey(ConcertCreationView.rentalFeeUndecidedKey));
    await tester.pumpAndSettle();

    final input = tester.widget<AppTextField>(field);
    expect(input.enabled, isFalse);
    expect(input.invalid, isFalse);
    final section = find
        .ancestor(of: field, matching: find.byType(Column))
        .first;
    expect(
      find.descendant(
        of: section,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.liveRegion == true,
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('보내는 중에는 닫기·시스템 뒤로 가기로 화면을 떠나지 않고 한 번만 보낸다', (tester) async {
    final pending = Completer<int>();
    final repository = _FakeRepository(pending: pending);
    usePhoneSize(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          concertCreationRepositoryProvider.overrideWithValue(repository),
          concertTodayProvider.overrideWithValue(() => DateTime(2026, 11, 28)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                key: _pushKey,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ConcertCreationView(
                      hostBand: _band,
                      onClose: () {},
                      onCreated: (_) {},
                    ),
                  ),
                ),
                child: const SizedBox.square(dimension: 44),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(_pushKey));
    await tester.pumpAndSettle();
    await _fillRequired(tester);

    await tester.tap(find.byKey(ConcertCreationView.submitKey));
    await tester.pump();
    expect(
      tester.widget<AppIconButton>(find.byType(AppIconButton)).onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();

    final route = ModalRoute.of(
      tester.element(find.byType(ConcertCreationView)),
    );
    expect(route?.isCurrent, isTrue);
    expect(repository.drafts, hasLength(1));
    pending.complete(1);
    await tester.pumpAndSettle();
  });

  testWidgets('아래에서 만들기를 눌러 막히면 첫 오류 칸(제목)까지 올려 보여 준다', (tester) async {
    await _open(tester, _FakeRepository());
    await _reveal(tester, find.byKey(ConcertCreationView.rentalFeeKey));
    expect(
      tester.getRect(find.byKey(ConcertCreationView.titleKey)).top,
      lessThan(0),
    );

    await _submit(tester);

    final title = tester.getRect(find.byKey(ConcertCreationView.titleKey));
    expect(title.top, greaterThanOrEqualTo(0));
    expect(title.bottom, lessThanOrEqualTo(844));
  });

  testWidgets('좁은 폭(320)에서도 넘치지 않고 끝까지 내려간다', (tester) async {
    await _open(tester, _FakeRepository(), width: 320);
    await capture(tester, 'concert-creation-9-320-top');

    await _reveal(tester, find.byKey(ConcertCreationView.rentalFeeKey));
    await capture(tester, 'concert-creation-10-320-bottom');
  });
}
