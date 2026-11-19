import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/home/home_notice.dart';

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
      HomeNotice(
        tagLabel: '문의',
        message: '새 문의가 왔어요',
        timeLabel: '방금',
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(HomeNotice));

    expect(taps, 1);
  });
}
