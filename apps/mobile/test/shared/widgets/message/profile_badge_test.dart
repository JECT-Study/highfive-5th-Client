import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_badge.dart';
import 'package:highfive/shared/widgets/message/profile_badge.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('안 읽은 수가 있을 때만 숫자 동그라미를 보인다', (tester) async {
    await _pump(tester, const ProfileBadge());
    expect(find.byType(AppBadge), findsNothing);

    await _pump(tester, const ProfileBadge(count: 3));
    expect(find.byType(AppBadge), findsOneWidget);
  });

  testWidgets('숫자 동그라미가 생겨도 위젯 크기가 같아 옆 글자가 밀리지 않는다', (tester) async {
    await _pump(tester, const ProfileBadge());
    final withoutBadge = tester.getSize(find.byType(ProfileBadge));

    await _pump(tester, const ProfileBadge(count: 3));
    expect(tester.getSize(find.byType(ProfileBadge)), withoutBadge);
  });
}
