import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_chip.dart';
import 'package:highfive/shared/widgets/app_chip_group.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

const _labels = ['록', '인디', '메탈'];

void main() {
  testWidgets('칩을 누르면 그 칩의 위치로 onTap을 부른다', (tester) async {
    final tapped = <int>[];
    await _pump(
      tester,
      AppChipGroup(
        labels: _labels,
        selectedIndexes: const {},
        onTap: tapped.add,
      ),
    );

    await tester.tap(find.byType(AppChip).at(2));

    expect(tapped, [2]);
  });

  testWidgets('selectedIndexes에 든 칩만 선택됨으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      AppChipGroup(labels: _labels, selectedIndexes: const {1}, onTap: (_) {}),
    );

    for (var i = 0; i < _labels.length; i++) {
      expect(
        tester.getSemantics(find.byType(AppChip).at(i)),
        isSemantics(isButton: true, isSelected: i == 1, hasSelectedState: true),
        reason: 'index=$i',
      );
    }
    semantics.dispose();
  });
}
