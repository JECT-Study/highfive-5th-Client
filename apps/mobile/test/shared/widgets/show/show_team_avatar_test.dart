import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/show_team_avatar.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('주최 배지는 hostLabel이 있을 때만 보인다', (tester) async {
    await _pump(tester, const ShowTeamAvatar(name: '소음공장', hostLabel: '주최'));
    expect(find.text('주최'), findsOneWidget);
    expect(find.text('소음공장'), findsOneWidget);

    await _pump(tester, const ShowTeamAvatar(name: '소음공장'));
    expect(find.text('주최'), findsNothing);
  });

  testWidgets('모집 중이면 hostLabel이 있어도 배지를 숨긴다', (tester) async {
    await _pump(
      tester,
      const ShowTeamAvatar(name: '모집 중', hostLabel: '주최', recruiting: true),
    );

    expect(find.text('주최'), findsNothing);
    expect(find.text('모집 중'), findsOneWidget);
  });
}
