import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_component_tokens.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('누르면 onPressed를 한 번 부른다', (tester) async {
    var taps = 0;
    await _pump(tester, AppButton(label: '다음', onPressed: () => taps++));

    await tester.tap(find.byType(AppButton));

    expect(taps, 1);
  });

  testWidgets('로딩 중에는 눌러도 onPressed를 부르지 않고 글자 대신 로딩 표시를 보인다', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      AppButton(label: '다음', onPressed: () => taps++, loading: true),
    );

    await tester.tap(find.byType(AppButton));

    expect(taps, 0);
    expect(find.byKey(const ValueKey('appButton_loader')), findsOneWidget);
    expect(find.text('다음'), findsNothing);
  });

  testWidgets('onPressed가 없으면 비활성으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, const AppButton(label: '다음', onPressed: null));

    expect(
      tester.getSemantics(find.byType(AppButton)),
      isSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
    );
    semantics.dispose();
  });

  testWidgets('크기별 높이는 컴포넌트 토큰을 따른다', (tester) async {
    final heights = {
      AppButtonSize.large: AppButtonTokens.largeHeight,
      AppButtonSize.medium: AppButtonTokens.mediumHeight,
      AppButtonSize.small: AppButtonTokens.smallHeight,
    };
    for (final MapEntry(key: size, value: height) in heights.entries) {
      await _pump(tester, AppButton(label: '확인', onPressed: () {}, size: size));
      expect(
        tester.getSize(find.byType(AppButton)).height,
        height,
        reason: '$size',
      );
    }
  });
}
