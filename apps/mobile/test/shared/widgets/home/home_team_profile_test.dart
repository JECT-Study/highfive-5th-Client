import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/home/home_team_profile.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('공유 버튼을 누르면 onSharePressed를 부른다', (tester) async {
    var shares = 0;
    await _pump(
      tester,
      HomeTeamProfile(
        name: '소음 공장',
        codeLabel: '초대코드',
        code: 'ABCDE123',
        shareLabel: '공유',
        onSharePressed: () => shares++,
      ),
    );

    await tester.tap(find.byType(AppButton));

    expect(shares, 1);
  });
}
