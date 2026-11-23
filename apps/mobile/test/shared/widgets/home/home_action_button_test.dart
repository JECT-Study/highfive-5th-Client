import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_icon.dart';
import 'package:highfive/shared/widgets/home/home_action_button.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('누르면 onPressed를 부른다', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      HomeActionButton(label: '공연 열기', onPressed: () => taps++),
    );

    await tester.tap(find.byType(HomeActionButton));

    expect(taps, 1);
  });

  testWidgets('onPressed가 없으면 비활성 버튼으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      const HomeActionButton(label: '공연 열기', onPressed: null),
    );

    expect(
      tester.getSemantics(find.byType(HomeActionButton)),
      isSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
    );
    semantics.dispose();
  });

  testWidgets('변형에 따라 더하기 또는 검색 아이콘을 보인다', (tester) async {
    for (final (type, icon) in [
      (HomeActionButtonType.add, AppIcons.add),
      (HomeActionButtonType.search, AppIcons.search),
    ]) {
      await _pump(
        tester,
        HomeActionButton(type: type, label: '바로가기', onPressed: () {}),
      );

      expect(
        tester.widget<AppIcon>(find.byType(AppIcon)).icon,
        icon,
        reason: '$type',
      );
    }
  });
}
