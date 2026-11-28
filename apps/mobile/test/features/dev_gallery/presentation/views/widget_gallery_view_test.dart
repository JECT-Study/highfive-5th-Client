import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/features/dev_gallery/presentation/views/sections/concert_gallery_section.dart';
import 'package:highfive/features/dev_gallery/presentation/views/sections/gallery_item.dart';
import 'package:highfive/features/dev_gallery/presentation/views/sections/qr_gallery_section.dart';
import 'package:highfive/features/dev_gallery/presentation/views/widget_gallery_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_chip.dart';

Future<void> _pumpApp(WidgetTester tester, Flavor flavor) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(
          AppEnv(
            flavor: flavor,
            apiBaseUrl: 'http://localhost',
            kakaoNativeAppKey: 'test',
            googleIosClientId: 'test',
            googleServerClientId: 'test',
          ),
        ),
      ],
      child: const HighfiveApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dev에서 DEV 띠를 길게 누르면 위젯 모음이 열린다', (tester) async {
    await _pumpApp(tester, Flavor.dev);

    await tester.longPress(find.byKey(const ValueKey('app_devGalleryEntry')));
    await tester.pumpAndSettle();

    expect(find.byType(WidgetGalleryView), findsOneWidget);
  });

  testWidgets('prod에는 위젯 모음 입구가 없다', (tester) async {
    await _pumpApp(tester, Flavor.prod);

    expect(find.byKey(const ValueKey('app_devGalleryEntry')), findsNothing);
  });

  testWidgets('폴더 칩을 누르면 그 폴더의 컴포넌트만 보여준다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const WidgetGalleryView()),
    );

    await tester.tap(find.widgetWithText(AppChip, 'qr'));
    await tester.pumpAndSettle();

    expect(find.byType(QrGallerySection), findsOneWidget);
    expect(
      find.widgetWithText(GalleryFolderHeader, 'shared/widgets/'),
      findsNothing,
    );
  });

  testWidgets('initialFolder로 처음 보여 줄 폴더를 정한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const WidgetGalleryView(initialFolder: 'qr'),
      ),
    );

    expect(find.byType(QrGallerySection), findsOneWidget);
    expect(find.byType(GalleryFolderHeader), findsOneWidget);
  });

  testWidgets('좁은 화면(320)에서 모든 폴더를 한 번에 그려도 넘침 오류가 없다', (tester) async {
    // 목록 전체가 한 번에 그려지도록 화면을 아주 길게 잡는다.
    tester.view.physicalSize = const Size(320, 60000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const WidgetGalleryView()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(GalleryFolderHeader), findsNWidgets(8));
  });

  testWidgets('concert 폴더는 라이트와 공연 다크를 각각 별도 테마로 보여준다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const WidgetGalleryView(initialFolder: 'concert'),
      ),
    );

    expect(find.byType(ConcertGallerySection), findsOneWidget);
    final light = tester.element(
      find.byKey(const ValueKey('concert_gallery_light')),
    );
    final dark = tester.element(
      find.byKey(const ValueKey('concert_gallery_dark')),
    );
    expect(Theme.of(light).brightness, Brightness.light);
    expect(Theme.of(dark).brightness, Brightness.dark);
    expect(
      Theme.of(tester.element(find.byType(WidgetGalleryView))).brightness,
      Brightness.light,
    );
  });
}
