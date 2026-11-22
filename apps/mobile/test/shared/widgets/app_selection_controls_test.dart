import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_colors.dart';
import 'package:highfive/shared/theme/app_component_tokens.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_selection_controls.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('체크박스를 누르면 반대 값을 넘기고, 누르는 영역은 44다', (tester) async {
    bool? next;
    await _pump(
      tester,
      AppCheckbox(checked: false, onChanged: (v) => next = v),
    );

    await tester.tap(find.byType(AppCheckbox));

    expect(next, isTrue);
    expect(
      tester.getSize(find.byType(AppCheckbox)),
      const Size.square(AppSelectionTokens.touchSize),
    );
  });

  testWidgets('onChanged가 없으면 체크박스를 눌러도 아무 일도 없다', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, const AppCheckbox(checked: true, onChanged: null));

    expect(
      tester.getSemantics(find.byType(AppCheckbox)),
      isSemantics(
        hasCheckedState: true,
        isChecked: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
    semantics.dispose();
  });

  testWidgets('비활성 체크박스는 Figma Disabled 색(바탕·테두리)으로 그린다', (tester) async {
    await _pump(tester, const AppCheckbox(checked: false, onChanged: null));

    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppCheckbox),
        matching: find.byType(Container),
      ),
    );
    final decoration = box.decoration! as BoxDecoration;
    final colors = AppColors.light;
    expect(decoration.color, colors.interactionDisable);
    expect((decoration.border! as Border).top.color, colors.labelDisable);
  });

  testWidgets('라디오를 누르면 onTap을 부른다', (tester) async {
    var taps = 0;
    await _pump(tester, AppRadio(selected: false, onTap: () => taps++));

    await tester.tap(find.byType(AppRadio));

    expect(taps, 1);
  });

  testWidgets('토글을 누르면 반대 값을 넘긴다', (tester) async {
    bool? next;
    await _pump(tester, AppToggle(checked: true, onChanged: (v) => next = v));

    await tester.tap(find.byType(AppToggle));

    expect(next, isFalse);
  });
}
