import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_component_tokens.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_badge.dart';

void main() {
  testWidgets('99를 넘으면 99+로 줄여 보인다', (tester) async {
    for (final (count, shown) in [(7, '7'), (99, '99'), (120, '99+')]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(child: AppBadge(count: count)),
          ),
        ),
      );
      expect(find.text(shown), findsOneWidget, reason: '$count');
      expect(
        tester.getSize(find.byType(AppBadge)),
        const Size.square(AppBadgeTokens.size),
        reason: '숫자가 길어도 원 크기 그대로 ($count)',
      );
    }
  });
}
