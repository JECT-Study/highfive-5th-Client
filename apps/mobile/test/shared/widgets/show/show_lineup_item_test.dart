import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/show/show_lineup_item.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('누르면 onTap을 부르고 버튼으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await _pump(tester, ShowLineupItem(name: '소음공장', onTap: () => taps++));

    await tester.tap(find.byType(ShowLineupItem));

    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(ShowLineupItem)),
      isSemantics(isButton: true),
    );
    semantics.dispose();
  });

  testWidgets('역할 태그는 roleLabel이 있을 때만 그린다', (tester) async {
    await _pump(tester, const ShowLineupItem(name: '소음공장'));
    expect(find.byType(AppTag), findsNothing);

    await _pump(tester, const ShowLineupItem(name: '소음공장', roleLabel: '주최'));
    expect(find.byType(AppTag), findsOneWidget);
  });

  testWidgets('셋리스트 곡마다 태그를 하나씩 그린다', (tester) async {
    await _pump(
      tester,
      const ShowLineupItem(name: '소음공장', setList: ['첫눈', '늦은 귀가', '정류장']),
    );

    expect(find.byType(AppTag), findsNWidgets(3));
  });
}
