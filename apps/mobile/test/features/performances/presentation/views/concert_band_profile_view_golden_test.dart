import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_band_profile_view.dart';
import 'package:highfive/features/performances/presentation/views/concert_detail_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/theme/app_typography.dart';

// 기존 공연 골든과 같이 실제 Pretendard의 macOS 래스터 결과다.
// Linux CI의 구조·상태 검증은 concert_band_route_test.dart와 info_tab_test.dart가 맡는다.
const _screen = ValueKey('concertProfile_golden');

Future<void> _font() async {
  final loader = FontLoader(AppFontFamily.pretendard);
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(
      rootBundle.load('assets/fonts/pretendard/Pretendard-$weight.otf'),
    );
  }
  await loader.load();
}

Future<void> _capture(
  WidgetTester tester,
  Widget view, {
  required double width,
  required double height,
  required String file,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        concertRepositoryProvider.overrideWithValue(FakeConcertRepository()),
        concertParticipantsRepositoryProvider.overrideWithValue(
          FakeConcertParticipantsRepository(),
        ),
      ],
      child: RepaintBoundary(
        key: _screen,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: view,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await expectLater(find.byKey(_screen), matchesGoldenFile(file));
}

void main() {
  setUpAll(_font);

  for (final width in [320.0, 375.0]) {
    testWidgets('폭 $width 정보 상세가 기준 이미지와 같다', (tester) async {
      await _capture(
        tester,
        ConcertDetailView(
          concertId: 12,
          onBack: () {},
          onEdit: null,
          onBandTap: (bandId) {},
          clock: () => DateTime(2026, 11, 28),
        ),
        width: width,
        height: 1120,
        file: 'goldens/concert_info_detail_${width.toInt()}.png',
      );
    }, skip: !Platform.isMacOS);

    testWidgets('폭 $width 참여 밴드 프로필이 기준 이미지와 같다', (tester) async {
      await _capture(
        tester,
        ConcertBandProfileView(concertId: 12, bandId: 9001, onClose: () {}),
        width: width,
        height: 812,
        file: 'goldens/concert_band_profile_${width.toInt()}.png',
      );
    }, skip: !Platform.isMacOS);
  }
}
