import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_chip.dart';

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
      AppChip(label: '1~3년', selected: false, onTap: () => taps++),
    );

    await tester.tap(find.byType(AppChip));

    expect(taps, 1);
  });

  testWidgets('선택 여부를 접근성 정보로 알린다', (tester) async {
    final semantics = tester.ensureSemantics();
    for (final selected in [false, true]) {
      await _pump(
        tester,
        AppChip(label: '1~3년', selected: selected, onTap: () {}),
      );
      expect(
        tester.getSemantics(find.byType(AppChip)),
        isSemantics(
          isButton: true,
          isSelected: selected,
          hasSelectedState: true,
        ),
        reason: 'selected=$selected',
      );
    }
    semantics.dispose();
  });
}
