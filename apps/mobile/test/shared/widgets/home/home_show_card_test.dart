import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/home/home_show_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets('변형마다 포스터·숫자 칸·밴드 목록 중 그 변형의 부품만 보인다', (tester) async {
    const List<HomeShowStat> stats = [(label: '신청', value: '30')];
    const List<HomeShowBand> bands = [(name: '오프비트', image: null)];
    final poster = find.byKey(const ValueKey('homeShowCard_poster'));

    for (final (type, showsPoster, showsStat, showsBand) in [
      (HomeShowCardType.summary, true, true, false),
      (HomeShowCardType.ticket, true, false, true),
      (HomeShowCardType.dDay, false, true, false),
    ]) {
      await _pump(
        tester,
        HomeShowCard(
          type: type,
          statusLabel: '상태',
          title: '공연',
          stats: stats,
          bands: bands,
        ),
      );

      expect(
        poster,
        showsPoster ? findsOneWidget : findsNothing,
        reason: '$type 포스터',
      );
      expect(
        find.text('신청'),
        showsStat ? findsOneWidget : findsNothing,
        reason: '$type 숫자 칸',
      );
      expect(
        find.text('오프비트'),
        showsBand ? findsOneWidget : findsNothing,
        reason: '$type 밴드',
      );
    }
  });

  testWidgets('아래 버튼은 각자의 콜백을 부르고, 나머지 자리를 누르면 onTap을 부른다', (tester) async {
    final calls = <String>[];
    await _pump(
      tester,
      HomeShowCard(
        type: HomeShowCardType.dDay,
        statusLabel: '공연 당일',
        title: '오늘 공연',
        secondaryLabel: 'QR',
        onSecondaryPressed: () => calls.add('secondary'),
        primaryLabel: '입장 시작',
        onPrimaryPressed: () => calls.add('primary'),
        onTap: () => calls.add('card'),
      ),
    );

    await tester.tap(find.widgetWithText(AppButton, 'QR'));
    await tester.tap(find.widgetWithText(AppButton, '입장 시작'));
    await tester.tap(find.text('오늘 공연'));

    expect(calls, ['secondary', 'primary', 'card']);
  });

  testWidgets('추가 카드는 누르면 onTap을 부르고, onTap이 없으면 비활성 버튼으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await _pump(tester, HomeShowAddCard(label: '공연 열기', onTap: () => taps++));

    await tester.tap(find.byType(HomeShowAddCard));
    expect(taps, 1);

    await _pump(tester, const HomeShowAddCard(label: '공연 열기', onTap: null));
    expect(
      tester.getSemantics(find.byType(HomeShowAddCard)),
      isSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
    );
    semantics.dispose();
  });
}
