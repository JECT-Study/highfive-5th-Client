import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/home/home_list_row.dart';

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
    await _pump(
      tester,
      HomeListRow(
        title: '롹롹',
        memberLabel: '팀원 1',
        description: '방 코드를 공유하세요',
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(HomeListRow));

    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(HomeListRow)),
      isSemantics(isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });
}
