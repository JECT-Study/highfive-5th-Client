import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/dev_gallery/presentation/views/sections/list_gallery_section.dart';
import 'package:highfive/shared/theme/app_theme.dart';

void main() {
  testWidgets('폭 320에서 섹션 전체를 그려도 오류가 없다', (tester) async {
    tester.view.physicalSize = const Size(320, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: ListGallerySection()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
