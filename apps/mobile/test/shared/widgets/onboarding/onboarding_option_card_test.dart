import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_icon.dart';
import 'package:highfive/shared/widgets/onboarding/onboarding_option_card.dart';

final _lock = find.byWidgetPredicate(
  (widget) => widget is AppIcon && widget.icon == AppIcons.lock,
);

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
      OnboardingOptionCard(
        title: '밴드 만들기',
        description: '대표자라면 여기서 시작하세요.',
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(OnboardingOptionCard));

    expect(taps, 1);
  });

  testWidgets('create 변형은 더하기, code 변형은 자물쇠 아이콘을 보인다', (tester) async {
    await _pump(
      tester,
      const OnboardingOptionCard(title: '밴드 만들기', description: '설명'),
    );
    expect(tester.widget<AppIcon>(find.byType(AppIcon)).icon, AppIcons.add);
    expect(_lock, findsNothing);

    await _pump(
      tester,
      const OnboardingOptionCard(
        type: OnboardingOptionType.code,
        title: '코드로 합류하기',
        description: '설명',
      ),
    );
    expect(_lock, findsOneWidget);
    expect(find.byType(AppIcon), findsOneWidget);
  });

  testWidgets('codeField를 주면 카드 안에 그린다', (tester) async {
    const fieldKey = ValueKey('test_codeField');
    await _pump(
      tester,
      const OnboardingOptionCard(
        type: OnboardingOptionType.code,
        title: '코드로 합류하기',
        description: '설명',
        codeField: SizedBox(key: fieldKey, height: 10),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(OnboardingOptionCard),
        matching: find.byKey(fieldKey),
      ),
      findsOneWidget,
    );
  });
}
