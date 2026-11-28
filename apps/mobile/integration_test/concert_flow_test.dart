import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/main_preview.dart' as preview;
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('기기에서 생성한 공연의 수정 결과와 다른 공연을 보존한다', (tester) async {
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      final bytes = await binding.takeScreenshot(name);
      final directory = Directory(
        '${Directory.systemTemp.path}/concert-flow-qa',
      );
      await directory.create(recursive: true);
      final file = File('${directory.path}/$name.png');
      await file.writeAsBytes(bytes);
      debugPrint('CONCERT_FLOW_CAPTURE=${file.path}');
    }

    Finder field(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );

    Future<void> create(String title) async {
      await tester.tap(find.byKey(const ValueKey('offline_create')));
      await tester.pumpAndSettle();
      await tester.enterText(field('concert_title'), title);
      await tester.tap(find.byKey(const ValueKey('concert_genre_ROCK')));
      await capture('iphone-creation');
      await tester.tap(find.byKey(const ValueKey('concert_submit')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('offline_detailTitle')))
            .data,
        title,
      );
    }

    preview.main();
    await tester.pumpAndSettle();
    await capture('iphone-home-empty');
    await create('Concert Alpha');
    await capture('iphone-created-detail');
    await tester.tap(find.byKey(const ValueKey('offline_edit')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(field('concertEdit_title')).controller!.text,
      'Concert Alpha',
    );
    await tester.enterText(field('concertEdit_title'), 'Concert Alpha Updated');
    await capture('iphone-edit');
    await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('offline_detailTitle')))
          .data,
      'Concert Alpha Updated',
    );
    await capture('iphone-saved-detail');
    await tester.tap(find.byTooltip('홈으로'));
    await tester.pumpAndSettle();
    await create('Concert Beta');
    await tester.tap(find.byTooltip('홈으로'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('offline_concert_1')),
        matching: find.text('Concert Alpha Updated'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('offline_concert_2')),
        matching: find.text('Concert Beta'),
      ),
      findsOneWidget,
    );
    await capture('iphone-home-two-concerts');
    await tester.tap(find.byKey(const ValueKey('offline_concert_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('offline_edit')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(field('concertEdit_title')).controller!.text,
      'Concert Alpha Updated',
    );
    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('홈으로'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
