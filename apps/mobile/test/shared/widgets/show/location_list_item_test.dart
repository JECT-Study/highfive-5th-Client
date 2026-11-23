import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/location_list_item.dart';

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
      LocationListItem(
        name: '홍대 놀이터',
        address: '서울 마포구 와우산로 00길',
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(LocationListItem));

    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(LocationListItem)),
      isSemantics(isButton: true, isEnabled: true, hasEnabledState: true),
    );
    semantics.dispose();
  });
}
