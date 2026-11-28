import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/presentation/providers/concert_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_creation_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';

import '../../concert_test_server.dart';

const _captureKey = ValueKey('concert_capture');
final _band = HostBand(id: 41, name: '테스트 주최 밴드');

Future<void> _open(
  WidgetTester tester,
  ConcertTestServer server, {
  required ValueChanged<int> onCreated,
  VoidCallback? onClose,
  double width = 390,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        concertRepositoryProvider.overrideWithValue(server.repository()),
        concertTodayProvider.overrideWithValue(() => DateTime(2026, 11, 26)),
      ],
      child: RepaintBoundary(
        key: _captureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: ConcertCreationView(
            hostBand: _band,
            onCreated: onCreated,
            onClose: onClose ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (Platform.environment['JECT149_CAPTURE'] != '1') return;
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final directory = Directory('build/ject149-evidence');
    await directory.create(recursive: true);
    await File('${directory.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Future<void> _fillRequired(WidgetTester tester) async {
  await _reveal(tester, 'concert_title', delta: -300);
  await tester.enterText(
    find.descendant(
      of: find.byKey(const ValueKey('concert_title')),
      matching: find.byType(TextField),
    ),
    '겨울 합동공연',
  );
  await _reveal(tester, 'concert_genre_SERVER_GENRE');
  await tester.tap(find.byKey(const ValueKey('concert_genre_SERVER_GENRE')));
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  final submit = find.byKey(const ValueKey('concert_submit'));
  await _reveal(tester, 'concert_submit');
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

Future<void> _reveal(
  WidgetTester tester,
  String key, {
  double delta = 300,
}) async {
  await tester.scrollUntilVisible(
    find.byKey(ValueKey(key)),
    delta,
    scrollable: find
        .descendant(
          of: find.byKey(const ValueKey('concert_form')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('Pretendard')
      ..addFont(
        rootBundle.load('assets/fonts/pretendard/Pretendard-Regular.otf'),
      )
      ..addFont(rootBundle.load('assets/fonts/pretendard/Pretendard-Bold.otf'));
    await loader.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets('입력부터 대기 및 서버 확인 후 성공 콜백까지 실제 폼을 통해 진행한다', (tester) async {
    final server = ConcertTestServer()..release = Completer<void>();
    final created = <int>[];
    await _open(tester, server, onCreated: created.add);
    await _capture(tester, '390-initial-top');
    await _fillRequired(tester);
    await _submit(tester);
    await server.posted.future;
    expect(created, isEmpty);
    final submit = tester.widget<AppButton>(
      find.byKey(const ValueKey('concert_submit')),
    );
    expect(submit.loading, isTrue);
    expect(submit.onPressed, isNull);
    await _capture(tester, '390-submitting-bottom');
    server.release!.complete();
    await tester.pumpAndSettle();
    expect(created, [72]);
    expect(server.posts, 1);
    expect(server.requests.last.data, containsPair('genres', ['SERVER_GENRE']));
    expect(server.requests.last.data, containsPair('performDate', null));
  });

  testWidgets('장르 오류는 다시 불러올 수 있고 빈 목록일 때 제출을 막는다', (tester) async {
    final server = ConcertTestServer()
      ..genreFailures = 1
      ..genres = [];
    await _open(tester, server, onCreated: (_) {});
    await _capture(tester, '390-genres-error');
    await tester.tap(find.byKey(const ValueKey('concert_genres_retry')));
    await tester.pumpAndSettle();
    await _capture(tester, '390-genres-empty');
    await _reveal(tester, 'concert_submit');
    final submit = tester.widget<AppButton>(
      find.byKey(const ValueKey('concert_submit')),
    );
    expect(submit.onPressed, isNull);
    expect(server.posts, 0);
    expect(server.requests.length, 2);
  });

  testWidgets('필수 오류는 입력 아래에 표시하고 응답 유실 후 재제출하지 않는다', (tester) async {
    final server = ConcertTestServer()
      ..networkFailure = DioExceptionType.receiveTimeout;
    final created = <int>[];
    await _open(tester, server, onCreated: created.add);
    await _submit(tester);
    expect(server.posts, 0);
    await _reveal(tester, 'concert_title', delta: -300);
    final titleField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('concert_title')),
        matching: find.byType(TextField),
      ),
    );
    expect(titleField.enabled, isTrue);
    await _capture(tester, '390-validation-top');
    await _fillRequired(tester);
    await _submit(tester);
    expect(created, isEmpty);
    expect(server.posts, 1);
    expect(
      tester
          .widget<AppButton>(find.byKey(const ValueKey('concert_submit')))
          .onPressed,
      isNull,
    );
    await _capture(tester, '390-uncertain-bottom');
  });

  testWidgets('권한 거절 후 안내를 보고 이전 화면으로 돌아갈 수 있다', (tester) async {
    final server = ConcertTestServer()
      ..status = 403
      ..body = {'code': 'AUTH_005'};
    var closed = false;
    await _open(
      tester,
      server,
      onCreated: (_) => fail('권한 거절을 성공으로 처리하면 안 됩니다.'),
      onClose: () => closed = true,
    );
    await _fillRequired(tester);
    await _submit(tester);
    final back = find.byKey(const ValueKey('concert_forbidden_back'));
    await _reveal(tester, 'concert_forbidden_back');
    await _capture(tester, '390-forbidden-bottom');
    await tester.tap(back);
    expect(closed, isTrue);
    expect(server.posts, 1);
  });

  testWidgets('날짜·시간 피커와 선택 입력값을 연결하고 확인된 성공 화면을 보여준다', (tester) async {
    final server = ConcertTestServer();
    final created = <int>[];
    await _open(tester, server, onCreated: created.add);
    await _fillRequired(tester);
    await _reveal(tester, 'concert_date');
    await tester.tap(find.byKey(const ValueKey('concert_date')));
    await tester.pumpAndSettle();
    final dateDialog = find.byType(DatePickerDialog);
    final dateConfirm = MaterialLocalizations.of(tester.element(dateDialog))
        .okButtonLabel;
    await tester.tap(find.widgetWithText(TextButton, dateConfirm));
    await tester.pumpAndSettle();
    for (final field in ['startTime', 'endTime']) {
      await _reveal(tester, 'concert_$field');
      await tester.tap(find.byKey(ValueKey('concert_$field')));
      await tester.pumpAndSettle();
      final confirm = MaterialLocalizations.of(
        tester.element(find.byType(TimePickerDialog)),
      ).okButtonLabel;
      await tester.tap(find.widgetWithText(TextButton, confirm));
      await tester.pumpAndSettle();
    }
    for (final (field, value) in [
      ('place', '검증 공연장'),
      ('address', '검증용 주소'),
      ('rentalFee', '0'),
    ]) {
      await _reveal(tester, 'concert_$field');
      await tester.enterText(
        find.descendant(
          of: find.byKey(ValueKey('concert_$field')),
          matching: find.byType(TextField),
        ),
        value,
      );
    }
    await _capture(tester, '390-optional-inputs-bottom');
    await _submit(tester);

    expect(created, [72]);
    final body = server.requests.last.data as Map<String, Object?>;
    expect(body['performDate'], '2026-11-26');
    expect(body['startTime'], '19:00:00');
    expect(body['endTime'], '19:00:00');
    expect(body['place'], '검증 공연장');
    expect(body['address'], '검증용 주소');
    expect(body['rentalFee'], 0);
    await _reveal(tester, 'concert_forbidden_back');
    await _capture(tester, '390-success-bottom');
  });

  for (final width in [320.0, 900.0]) {
    testWidgets('폭 $width 에서 입력과 하단 동작에 넘침이 없다', (tester) async {
      await _open(tester, ConcertTestServer(), onCreated: (_) {}, width: width);
      await _capture(tester, '${width.toInt()}-initial-top');
      await _reveal(tester, 'concert_submit');
      await _capture(tester, '${width.toInt()}-initial-bottom');
      expect(tester.takeException(), isNull);
    });
  }
}
