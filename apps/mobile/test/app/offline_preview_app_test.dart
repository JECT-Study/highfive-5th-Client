import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/offline_preview_app.dart';
import 'package:highfive/main_preview.dart' as preview;
import 'package:highfive/features/performances/presentation/views/concert_creation_view.dart';
import 'package:highfive/features/performances/presentation/views/concert_edit_view.dart';

const _captureKey = ValueKey('flow_capture');

Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextField),
);

Future<void> _capture(WidgetTester tester, String name) async {
  if (Platform.environment['CONCERT_FLOW_CAPTURE'] != '1') return;
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final directory = Directory('build/concert-flow-qa');
    await directory.create(recursive: true);
    await File('${directory.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Future<void> _create(WidgetTester tester, String title) async {
  await tester.tap(find.byKey(const ValueKey('offline_create')));
  await tester.pumpAndSettle();
  expect(find.byType(ConcertCreationView), findsOneWidget);
  await tester.enterText(_field('concert_title'), title);
  await tester.tap(find.byKey(const ValueKey('concert_genre_ROCK')));
  await _capture(tester, 'creation');
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('concert_submit')),
    300,
    scrollable: find
        .descendant(
          of: find.byKey(const ValueKey('concert_form')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.tap(find.byKey(const ValueKey('concert_submit')));
  await tester.pumpAndSettle();
  expect(
    tester.widget<Text>(find.byKey(const ValueKey('offline_detailTitle'))).data,
    title,
  );
}

void main() {
  setUpAll(() async {
    await (FontLoader('Pretendard')
          ..addFont(
            rootBundle.load('assets/fonts/pretendard/Pretendard-Regular.otf'),
          )
          ..addFont(
            rootBundle.load('assets/fonts/pretendard/Pretendard-Bold.otf'),
          ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  test('명시적 dev/debug 외의 시작점은 거절한다', () {
    requireOfflinePreview(flavor: Flavor.dev, debug: true);
    for (final config in [
      (Flavor.prod, true),
      (Flavor.prod, false),
      (Flavor.dev, false),
    ]) {
      expect(
        () => requireOfflinePreview(flavor: config.$1, debug: config.$2),
        throwsUnsupportedError,
      );
    }
  });

  testWidgets('실제 미리보기 시작점에서도 생성 폼은 실제 세션 없이 열린다', (tester) async {
    preview.main();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('offline_create')));
    await tester.pumpAndSettle();
    expect(find.byType(ConcertCreationView), findsOneWidget);
    expect(find.byKey(const ValueKey('concert_title')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('생성한 두 공연을 구분하고 같은 공연 수정 결과를 상세와 홈에 반영한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var storageCalls = 0;
    var httpClients = 0;
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      _,
    ) async {
      storageCalls++;
      throw StateError('오프라인 앱에서 실제 인증 저장소 접근');
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await HttpOverrides.runZoned(
      () async {
        await tester.pumpWidget(
          const RepaintBoundary(key: _captureKey, child: OfflinePreviewApp()),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('offline_concert_1')), findsNothing);
        await _capture(tester, 'home-empty');
        await _create(tester, '첫 번째 공연');
        await _capture(tester, 'created-detail');
        await tester.tap(find.byTooltip('홈으로'));
        await tester.pumpAndSettle();
        await _create(tester, '두 번째 공연');
        await tester.tap(find.byTooltip('홈으로'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('offline_concert_1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('offline_edit')));
        await tester.pumpAndSettle();
        expect(find.byType(ConcertEditView), findsOneWidget);
        expect(
          tester
              .widget<TextField>(_field('concertEdit_title'))
              .controller!
              .text,
          '첫 번째 공연',
        );
        await tester.enterText(_field('concertEdit_title'), '첫 번째 공연 수정 완료');
        await _capture(tester, 'edit-title');
        await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('offline_detailTitle')))
              .data,
          '첫 번째 공연 수정 완료',
        );
        await _capture(tester, 'saved-detail');
        await tester.tap(find.byKey(const ValueKey('offline_edit')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(_field('concertEdit_title'))
              .controller!
              .text,
          '첫 번째 공연 수정 완료',
        );
        await tester.tap(find.byTooltip('닫기'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('홈으로'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('offline_concert_1')),
            matching: find.text('첫 번째 공연 수정 완료'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('offline_concert_2')),
            matching: find.text('두 번째 공연'),
          ),
          findsOneWidget,
        );
        await _capture(tester, 'home-two-concerts');
        await tester.tap(find.byKey(const ValueKey('offline_concert_2')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('offline_detailTitle')))
              .data,
          '두 번째 공연',
        );
        expect(tester.takeException(), isNull);
      },
      createHttpClient: (_) {
        httpClients++;
        throw StateError('오프라인 앱에서 HTTP 클라이언트 생성');
      },
    );
    expect(httpClients, 0);
    expect(storageCalls, 0);
  });
}
