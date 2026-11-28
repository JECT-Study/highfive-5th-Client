import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/host_band_repository.dart';
import 'package:highfive/features/performances/models/concert_genre.dart';
import 'package:highfive/features/performances/models/host_band.dart';
import 'package:highfive/features/performances/presentation/providers/concert_creation_providers.dart';
import 'package:highfive/features/performances/presentation/widgets/host_band_picker_sheet.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';

import '../../../../support/capture.dart';

/// [responses]를 앞에서부터 하나씩 돌려준다. 예외면 던진다.
class _FakeBands implements HostBandRepository {
  _FakeBands(this.responses);

  final List<Object> responses;
  int calls = 0;

  @override
  Future<List<HostBand>> fetchHostBands() async => switch (responses[calls++]) {
    final Exception error => throw error,
    final Future<List<HostBand>> pending => await pending,
    final bands => bands as List<HostBand>,
  };
}

const _noise = HostBand(
  id: 1,
  name: '소음공장',
  genres: [ConcertGenre.rock, ConcertGenre.indie],
  memberCount: 4,
);
const _campus = HostBand(
  id: 2,
  name: '대학밴드',
  genres: [ConcertGenre.pop, ConcertGenre.jazz],
  memberCount: 3,
);
const _openKey = ValueKey('test_openSheet');

/// 시트를 띄우고, 시트가 돌려준 값을 모을 목록을 돌려준다.
Future<List<HostBand?>> _open(
  WidgetTester tester,
  HostBandRepository repository, {
  bool waitForLoad = true,
}) async {
  usePhoneSize(tester);
  final results = <HostBand?>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [hostBandRepositoryProvider.overrideWithValue(repository)],
      child: capturable(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  key: _openKey,
                  onPressed: () async =>
                      results.add(await showHostBandPickerSheet(context)),
                  child: const SizedBox.square(dimension: 44),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(_openKey));
  if (waitForLoad) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return results;
}

VoidCallback? _next(WidgetTester tester) =>
    tester.widget<AppButton>(find.byKey(HostBandPickerSheet.nextKey)).onPressed;

void main() {
  setUpAll(loadCaptureFonts);

  testWidgets('밴드를 고르기 전에는 다음을 누를 수 없고, 고른 밴드를 돌려준다', (tester) async {
    final results = await _open(
      tester,
      _FakeBands([
        [_noise, _campus],
      ]),
    );
    expect(_next(tester), isNull);
    await capture(tester, 'host-band-picker-1-initial');

    await tester.tap(find.byKey(HostBandPickerSheet.optionKey(_campus.id)));
    await tester.pumpAndSettle();
    expect(_next(tester), isNotNull);
    await capture(tester, 'host-band-picker-2-selected');
    await tester.tap(find.byKey(HostBandPickerSheet.nextKey));
    await tester.pumpAndSettle();

    expect(results, [_campus]);
    expect(find.byType(HostBandPickerSheet), findsNothing);
  });

  testWidgets('대표자인 밴드가 하나면 미리 골라 둔다', (tester) async {
    final results = await _open(
      tester,
      _FakeBands([
        [_noise],
      ]),
    );

    await tester.tap(find.byKey(HostBandPickerSheet.nextKey));
    await tester.pumpAndSettle();

    expect(results, [_noise]);
  });

  testWidgets('목록을 못 받으면 다시 시도해 받는다', (tester) async {
    final repository = _FakeBands([
      Exception('offline'),
      [_noise, _campus],
    ]);
    await _open(tester, repository);
    expect(_next(tester), isNull);
    await capture(tester, 'host-band-picker-3-error');

    await tester.tap(find.byKey(HostBandPickerSheet.retryKey));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(
      find.byKey(HostBandPickerSheet.optionKey(_noise.id)),
      findsOneWidget,
    );
  });

  testWidgets('목록을 기다리는 동안 로딩을 보이고 빈 결과면 안내와 비활성 버튼을 보인다', (tester) async {
    final pending = Completer<List<HostBand>>();
    await _open(tester, _FakeBands([pending.future]), waitForLoad: false);
    expect(find.byKey(HostBandPickerSheet.loadingKey), findsOneWidget);
    expect(find.byKey(HostBandPickerSheet.emptyKey), findsNothing);
    expect(_next(tester), isNull);

    pending.complete([]);
    await tester.pumpAndSettle();

    expect(find.byKey(HostBandPickerSheet.loadingKey), findsNothing);
    expect(find.byKey(HostBandPickerSheet.emptyKey), findsOneWidget);
    expect(_next(tester), isNull);
    await capture(tester, 'host-band-picker-4-empty');
  });

  testWidgets('고르지 않고 닫으면 아무 밴드도 돌려주지 않는다', (tester) async {
    final results = await _open(
      tester,
      _FakeBands([
        [_noise, _campus],
      ]),
    );

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(results, [null]);
  });
}
