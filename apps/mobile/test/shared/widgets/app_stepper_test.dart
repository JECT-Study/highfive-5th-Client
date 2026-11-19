import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_stepper.dart';

void main() {
  testWidgets('콜백이 없는 쪽 버튼은 눌러도 반응하지 않는다', (tester) async {
    var increments = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: AppStepper(
              valueLabel: '1팀',
              onDecrement: null,
              onIncrement: () => increments++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('늘리기'));
    await tester.tap(find.byTooltip('줄이기'));

    expect(increments, 1);
    final decrement = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.remove),
        matching: find.byType(IconButton),
      ),
    );
    expect(decrement.onPressed, isNull);
  });
}
