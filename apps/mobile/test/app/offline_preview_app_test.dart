import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/offline_preview_app.dart';
import 'package:highfive/features/chat/presentation/views/chat_list_view.dart';
import 'package:highfive/features/home/presentation/views/home_view.dart';
import 'package:highfive/features/my_page/presentation/views/my_page_view.dart';
import 'package:highfive/features/recruitments/presentation/views/recruitment_list_view.dart';
import 'package:highfive/features/performances/presentation/views/concert_edit_view.dart';

void main() {
  test('dev/debug 명시 진입만 허용하고 prod·profile·release는 거절한다', () {
    requireOfflinePreview(flavor: Flavor.dev, debug: true);
    for (final config in [
      (flavor: Flavor.prod, debug: true),
      (flavor: Flavor.prod, debug: false),
      (flavor: Flavor.dev, debug: false),
    ]) {
      expect(
        () => requireOfflinePreview(flavor: config.flavor, debug: config.debug),
        throwsUnsupportedError,
      );
    }
  });

  testWidgets('실제 네 탭을 탐색하고 편집을 열어도 저장소·HTTP·실제 로그아웃을 사용하지 않는다', (
    tester,
  ) async {
    var storageCalls = 0;
    var httpClients = 0;
    const storage = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(storage, (
      call,
    ) async {
      storageCalls++;
      throw StateError('오프라인 앱이 실제 저장소를 사용함');
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        storage,
        null,
      ),
    );

    await HttpOverrides.runZoned(
      () async {
        await tester.pumpWidget(
          const ProviderScope(child: OfflinePreviewApp()),
        );
        await tester.pumpAndSettle();
        expect(find.byType(HomeView), findsOneWidget);
        for (final tab in [
          (label: '팀 모집', view: RecruitmentListView),
          (label: '메시지', view: ChatListView),
          (label: '마이페이지', view: MyPageView),
          (label: '홈', view: HomeView),
        ]) {
          await tester.tap(find.text(tab.label).last);
          await tester.pumpAndSettle();
          expect(find.byType(tab.view), findsOneWidget);
        }
        await tester.tap(
          find.byKey(const ValueKey('offlinePreview_concertEdit')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ConcertEditView), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('concertEdit_save')));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('닫기'));
        await tester.pumpAndSettle();
        expect(find.byType(HomeView), findsOneWidget);
        await tester.tap(find.text('마이페이지').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OutlinedButton));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextButton),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MyPageView), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
      createHttpClient: (_) {
        httpClients++;
        throw StateError('오프라인 앱이 HTTP 클라이언트를 생성함');
      },
    );
    expect(storageCalls, 0);
    expect(httpClients, 0);
  });
}
