import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_tab_list.dart';

void main() {
  testWidgets('탭을 누르면 그 순번을 넘기고, 고른 탭을 접근성 정보로 알린다', (tester) async {
    final semantics = tester.ensureSemantics();
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppTabList(
            labels: const ['정보', '피드', '일정'],
            selectedIndex: 0,
            onSelected: (i) => selected = i,
          ),
        ),
      ),
    );

    await tester.tap(find.text('일정'));

    expect(selected, 2);
    expect(
      tester.getSemantics(find.text('정보')),
      isSemantics(isButton: true, hasSelectedState: true, isSelected: true),
    );
    semantics.dispose();
  });
}
