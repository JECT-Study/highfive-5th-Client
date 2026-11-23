import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/home/home_show_card_small.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('누르면 onTap을 부른다', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      HomeShowCardSmall(
        title: '홍대 인디 나잇',
        details: const ['10.12(월)', '1팀 남음'],
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(HomeShowCardSmall));

    expect(taps, 1);
  });
}
