import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_detail_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/theme/app_typography.dart';

// 기준 PNG는 macOS에서 실제 Pretendard 글꼴로 그린 화면이다. 글꼴 래스터화가 OS마다 달라 픽셀이 어긋나므로
// CI(ubuntu)에서는 비교하지 않는다. 화면 구조와 상태는 concert_detail_view_test.dart가 모든 OS에서 확인한다.
// 다시 만들기(apps/mobile, macOS):
//   fvm flutter test --update-goldens test/features/performances/presentation/views/concert_detail_view_golden_test.dart
final _notMacOS = !Platform.isMacOS;

const _screenKey = ValueKey('golden_screen');

Future<void> _loadPretendard() async {
  final loader = FontLoader(AppFontFamily.pretendard);
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(
      rootBundle.load('assets/fonts/pretendard/Pretendard-$weight.otf'),
    );
  }
  await loader.load();
}

Future<void> _pumpScreen(
  WidgetTester tester,
  ConcertRepository concerts, {
  VoidCallback? onEdit,
}) async {
  // Figma 화면 크기 375 × 812를 2배 밀도로 그린다.
  tester.view.physicalSize = const Size(750, 1624);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        concertRepositoryProvider.overrideWithValue(concerts),
        concertParticipantsRepositoryProvider.overrideWithValue(
          FakeConcertParticipantsRepository(),
        ),
      ],
      child: RepaintBoundary(
        key: _screenKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: ConcertDetailView(
            concertId: 12,
            onBack: () {},
            onEdit: onEdit,
            clock: () => DateTime(2026, 11, 28),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadPretendard);

  testWidgets('정보 수정이 연결된 참여자의 정보 탭이 기준 이미지와 같다', (tester) async {
    await _pumpScreen(tester, FakeConcertRepository(), onEdit: () {});

    await expectLater(
      find.byKey(_screenKey),
      matchesGoldenFile('goldens/concert_detail_view_info.png'),
    );
  }, skip: _notMacOS);

  testWidgets('참여 팀 멤버가 아닐 때의 안내 화면이 기준 이미지와 같다', (tester) async {
    await _pumpScreen(tester, FakeConcertRepository(forbiddenConcertIds: {12}));

    await expectLater(
      find.byKey(_screenKey),
      matchesGoldenFile('goldens/concert_detail_view_forbidden.png'),
    );
  }, skip: _notMacOS);
}
