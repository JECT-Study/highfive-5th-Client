import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_band_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

const _dot = ValueKey('appBandCard_dot');

void main() {
  testWidgets('누르면 onTap을 한 번 부르고 버튼으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await _pump(
      tester,
      AppBandCard(title: '소음공장 합동공연', date: '10.12(월)', onTap: () => taps++),
    );

    await tester.tap(find.byType(AppBandCard));

    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(AppBandCard)),
      isSemantics(isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('장소가 있을 때만 일정 뒤에 구분 점을 그린다', (tester) async {
    await _pump(
      tester,
      const AppBandCard(title: '소음공장 합동공연', date: '10.12(월)', time: '19:00'),
    );
    expect(find.byKey(_dot), findsNothing);

    await _pump(
      tester,
      const AppBandCard(title: '소음공장 합동공연', date: '10.12(월)', place: '서울 마포구'),
    );
    expect(find.byKey(_dot), findsOneWidget);
  });
}
